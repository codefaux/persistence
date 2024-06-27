dofile_once("data/scripts/lib/mod_settings.lua");
---mod files dir. ALSO UPDATE IN XMLs
mod_dir = "mods/persistence_staging/";

dofile_once(mod_dir .. "files/meta.lua");

mod_flag_name = "persistence";

mod_disabled = false;

---Player entity ID, populated by OnPlayerSpawned(_)

player_e_id=0;
wallet_c_id=0;
inventorygui_c_id=0;
inventory2_c_id=0
controls_c_id=0;

last_known_money=0;
persistence_active=false;

local function do_lobby_effect_entities()
	local lobby_effect_e_id=EntityCreateNew("persistence_lobby_effect_entity");
	local lobby_effect_gameeffect_c_id = EntityAddComponent2(lobby_effect_e_id, "GameEffectComponent", { effect="EDIT_WANDS_EVERYWHERE", _enabled=false });
	local lobby_effect_lua_c_id = EntityAddComponent2(lobby_effect_e_id, "LuaComponent", {script_source_file=mod_dir .. "files/entity/lobby_effect.lua", execute_every_n_frame=10, _enabled=true });
	EntityAddChild(player_e_id, lobby_effect_e_id);
	GlobalsSetValue("persistence_lobby_effect_component", tostring(lobby_effect_gameeffect_c_id));
	GlobalsSetValue("persistence_lobby_effect_entity", tostring(lobby_effect_e_id));
end

function teleport_back_to_lobby()
	local lobby_x = tonumber(GlobalsGetValue("first_spawn_x", "0")) or 0;
	local lobby_y = tonumber(GlobalsGetValue("first_spawn_y", "0")) or 0;

	EntitySetTransform(player_e_id, lobby_x, lobby_y);
end

function OnModPreInit()
	mod_disabled = ModSettingGet("persistence.always_choose_save_id")==0;
end


function OnWorldPostUpdate()
	if mod_disabled then return; end

	dofile(mod_dir .. "files/actions_by_id.lua");
	dofile(mod_dir .. "files/entity_mgr.lua");

	persistence_active = GlobalsGetValue("persistence_active", "false")=="true";

	if persistence_active and (wallet_c_id==0 or inventorygui_c_id==0 or inventory2_c_id==0 or controls_c_id==0) then
		if wallet_c_id==0 then wallet_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent") or 0; end
		if inventorygui_c_id==0 then inventorygui_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent") or 0; end
		if inventory2_c_id==0 then inventory2_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component") or 0; end
		if controls_c_id==0 then controls_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent") or 0; end
		return;
	end

	if persistence_active then
		local _money = ComponentGetValue2(wallet_c_id, "money")
		if _money~=nil and _money>0 then last_known_money=_money; end

		dofile(mod_dir .. "files/gui.lua");
	end

	-- GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) );
	OnModEndFrame();
end


local spawn_run_once=true;

function OnPlayerSpawned(entity_id)
	if mod_disabled then return; end

	if player_e_id~=0 then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and player_e_id~=nil"); return; end
	if entity_id==0 then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and entity_id==0"); return; end
	player_e_id = entity_id;

	if GameGetFrameNum() < 60 and spawn_run_once then
		---Player spawned within 60 frames, this is a new game

		wallet_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent");
		inventorygui_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent");
		inventory2_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component");
		controls_c_id=EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent");

		GlobalsSetValue("persistence_active", "true"); persistence_active=true; ---latter is mostly for ide annotations

		if ModSettingGet("persistence.enable_edit_wands_in_lobby")==true then do_lobby_effect_entities(); end

		x_loc, y_loc = EntityGetTransform(player_e_id);
		GlobalsSetValue("first_spawn_x", tostring(x_loc));
		GlobalsSetValue("first_spawn_y", tostring(y_loc));

		once=false;  ---set late so function repeats if not successful aka early exit
	end
end


function OnPlayerDied(entity_id)
	if mod_disabled then return; end
	if entity_id~=player_e_id then return; end

	local money_to_save = math.floor(last_known_money * ModSettingGet("persistence.money_saved_on_death") );
	GamePrintImportant("You died", " $ " .. money_to_save .. " was saved.");
	set_stash_money(math.abs(get_stash_money() + money_to_save));
	player_e_id = 0;
end
