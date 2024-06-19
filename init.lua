-- dofile_once( "data/scripts/lib/utilities.lua" )

---Player entity ID, populated by OnPlayerSpawned(_)
player_e_id = nil;
lobby_e_id = nil;

persistence_active = nil;
---mod files dir. ALSO UPDATE IN XMLs
mod_dir = "mods/persistence_staging/";

---get x, y from full transform element
---@param x number transform x element
---@param y number transform y element
---@param ... number transform discarded elements
---@return number x transform x element
---@return number y transform y element
local function clip_transform(x, y, ...) return x, y; end


function OnWorldPostUpdate()
	dofile(mod_dir .. "files/actions_by_id.lua");
	dofile(mod_dir .. "files/entity_mgr.lua");
	persistence_active = GlobalsGetValue("persistence_active", "false")=="true";

	dofile(mod_dir .. "files/gui.lua");

	GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) );
	if GlobalsGetValue("lobby_collider_triggered", "x")=="1" then
		GlobalsSetValue("lobby_collider_triggered", "0");
	end
	if GlobalsGetValue("workshop_collider_triggered", "x")=="1" then
		GlobalsSetValue("workshop_collider_triggered", "0");
	end
end


function OnPlayerSpawned(entity_id)
	if player_e_id~=nil then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and player_e_id~=nil"); return; end
	player_e_id = entity_id;

	if GameGetFrameNum() < 60 then
		GlobalsSetValue("persistence_active", "true");
		x_loc, y_loc = EntityGetTransform(player_e_id);
		GlobalsSetValue("first_spawn_x", tostring(x_loc));
		GlobalsSetValue("first_spawn_y", tostring(y_loc));
	end
	-- if ModSettingGet("persistence.move_lobby_to_spawn") and lobby_e_id~=nil then
	-- 	EntitySetTransform(entity_id, clip_transform(EntityGetTransform(player_e_id)));
	-- end
end


function OnPlayerDied(entity_id)
	if entity_id~=player_e_id then return; end
	player_e_id = -1;
end