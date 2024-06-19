-- dofile_once( "data/scripts/lib/utilities.lua" )
---mod files dir. ALSO UPDATE IN XMLs
mod_dir = "mods/persistence_staging/";

---Player entity ID, populated by OnPlayerSpawned(_)
player_e_id=0;
wallet_e_id=0;
persistence_active=false;

local function do_lobby_effect_entities()
	local lobby_effect_e_id=EntityCreateNew("persistence_lobby_effect_entity");
	local lobby_effect_gameeffect_c_id = EntityAddComponent2(lobby_effect_e_id, "GameEffectComponent", { effect="EDIT_WANDS_EVERYWHERE", _enabled=false });
	local lobby_effect_lua_c_id = EntityAddComponent2(lobby_effect_e_id, "LuaComponent", {script_source_file=mod_dir .. "files/entity/lobby_effect.lua", execute_every_n_frame=10, _enabled=true });
	GlobalsSetValue("persistence_lobby_effect_component", tostring(lobby_effect_gameeffect_c_id));
	GlobalsSetValue("persistence_lobby_effect_entity", tostring(lobby_effect_e_id));
	EntityAddChild(player_e_id, lobby_effect_e_id);
end




function OnWorldPostUpdate()
	dofile(mod_dir .. "files/actions_by_id.lua");
	dofile(mod_dir .. "files/entity_mgr.lua");

	persistence_active = GlobalsGetValue("persistence_active", "false")=="true";
	if persistence_active then dofile(mod_dir .. "files/gui.lua"); end

	GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) );
	OnEndFrame();
end


local spawn_run_once=true;
function OnPlayerSpawned(entity_id)
	if player_e_id~=0 then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and player_e_id~=nil"); return; end
	player_e_id = entity_id;
	wallet_e_id = EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent");

	if GameGetFrameNum() < 60 and spawn_run_once then
		once=false;
		GlobalsSetValue("persistence_active", "true");

		if ModSettingGet("persistence.enable_edit_wands_in_lobby")==true then
			do_lobby_effect_entities();
		end
	
		x_loc, y_loc = EntityGetTransform(player_e_id);
		GlobalsSetValue("first_spawn_x", tostring(x_loc));
		GlobalsSetValue("first_spawn_y", tostring(y_loc));
	end
end


function OnPlayerDied(entity_id)
	if entity_id~=player_e_id then return; end
	player_e_id = 0;
end