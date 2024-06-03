dofile_once("mods/persistence/files/helper.lua");
dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local is_in_lobby = false;
local inventory_open = false;
-- local screen_size_x, screen_size_y;
local lobby_collider; ---type: @entity_id
local lobby_collider_enabled = false;
local lobby_x, lobby_y;

local menu_open = false;
local function enter_lobby()
	if ModSettingGet("persistence.enable_edit_wands_in_lobby") then
		enable_edit_wands_in_lobby();
	end
	show_lobby_gui();
end

local function exit_lobby()
	disable_edit_wands_in_lobby();
	hide_lobby_gui();
end

function teleport_back_to_lobby()
	disable_edit_wands_in_lobby();
	EntitySetTransform(get_player_id(), lobby_x, lobby_y);
end

function disable_controls()
	local player_id = get_player_id();
	EntitySetComponentIsEnabled(player_id, get_inventory_gui(), false);
	EntitySetComponentIsEnabled(player_id, get_inventory2(), false);
	EntitySetComponentIsEnabled(player_id, get_controls_component(), false);
end

function enable_controls()
	local player_id = get_player_id();
	EntitySetComponentIsEnabled(player_id, get_controls_component(), true);
	EntitySetComponentIsEnabled(player_id, get_inventory2(), true);
	EntitySetComponentIsEnabled(player_id, get_inventory_gui(), true);
end

function update_screen_size()
	teleport_component = EntityGetFirstComponentIncludingDisabled(get_player_id(), "TeleportComponent");
	if teleport_component ~= nil and teleport_component ~= 0 then
		EntitySetComponentIsEnabled(get_player_id(), teleport_component, true);
	else
		EntityAddComponent2(get_player_id(), "TeleportComponent", {});
	end
end

-- function get_screen_size()
-- 	return screen_size_x, screen_size_y;
-- end

local is_post_player_spawned = false;
local is_in_workshop = false;


-- GAME ENGINE EVENTS

function OnWorldPostUpdate()
	if #actions_by_id < 1 then
		load_actions_by_id();
	end

	if lobby_collider == nil or lobby_collider == 0 then
		local controls_mouse = EntityGetWithTag("controls_mouse")[1];
		if controls_mouse ~= nil and controls_mouse ~= 0 then
			local x, y = EntityGetTransform(controls_mouse);
			lobby_collider = EntityLoad("mods/persistence/files/lobby_collider.xml", x - 50, y + 30);
			lobby_x, lobby_y = EntityGetTransform(lobby_collider);
		end
	end

	if get_player_id() == nil or get_player_id() == 0 or not EntityGetIsAlive(get_player_id()) then
		return;
	end

	teleport_component = EntityGetFirstComponentIncludingDisabled(get_player_id(), "TeleportComponent");
	if teleport_component ~= nil and teleport_component ~= 0 then
		local a, b, c, d = ComponentGetValue2(teleport_component, "source_location_camera_aabb");
		if a ~= 0 or b ~= 0 or c ~= 0 or d ~= 0 then
			-- screen_size_x = math.floor(c - a + 0.5);
			-- screen_size_y = math.floor(d - b + 0.5);
			EntitySetComponentIsEnabled(get_player_id(), teleport_component, false);
			ComponentSetValue2(teleport_component, "source_location_camera_aabb", 0, 0, 0, 0);
		end
	end

	if not is_post_player_spawned then
		OnPostPlayerSpawned();
		is_post_player_spawned = true;
	end

	if get_selected_save_id == nil or get_selected_save_id() == 0 then
		return;
	end

	if not lobby_collider_enabled then
		if lobby_collider ~= nil and lobby_collider ~= 0 then
			for _, comp in ipairs(EntityGetAllComponents(lobby_collider)) do
				EntitySetComponentIsEnabled(lobby_collider, comp, true);
			end
			lobby_collider_enabled = true;
		end
	end

	if gui_update ~= nil then
		gui_update();
	end

	if get_selected_save_id() == nil then
		return;
	end

	local workshop_list = EntityGetWithTag("workshop");

	-- for _, workshop in ipairs(EntityGetWithTag("workshop")) do
	-- if #workshop_list > #persistence_list then
		for _, workshop in ipairs(workshop_list) do
			local shop_x, shop_y = EntityGetTransform(workshop);
			local custom_workshop = EntityGetClosestWithTag(shop_x, shop_y, "persistence_workshop");
			local custom_x, custom_y = EntityGetTransform(custom_workshop);
			if custom_workshop == nil or custom_workshop == 0 or (shop_x - custom_x) * (shop_y - custom_y) > 10 then
				GamePrint("Updating workshop " .. custom_workshop .. " for " .. workshop )
				custom_workshop = EntityLoad("mods/persistence/files/workshop_collider.xml", shop_x, shop_y);
				local workshop_hitbox_comp = EntityGetFirstComponentIncludingDisabled(workshop, "HitboxComponent"); 
				local custom_workshop_hitbox_comp = EntityGetFirstComponentIncludingDisabled(custom_workshop, "HitboxComponent");
				ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_min_x", ComponentGetValue2(workshop_hitbox_comp, "aabb_min_x"));
				ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_min_y", ComponentGetValue2(workshop_hitbox_comp, "aabb_min_y"));
				ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_max_x", ComponentGetValue2(workshop_hitbox_comp, "aabb_max_x"));
				ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_max_y", ComponentGetValue2(workshop_hitbox_comp, "aabb_max_y"));
			end
		end
	-- end

	local plr_x, plr_y = EntityGetTransform(get_player_id());
	local is_in_workshop_before = is_in_workshop;
	is_in_workshop = false;
	-- for _, qualified_workshop in ipairs(EntityGetWithTag(ModSettingGet("persistence.reusable_holy_mountain") and "persistence_workshop" or "workshop")) do
	if ModSettingGet("persistence_reusable_holy_mountain") then
		local persistence_list = EntityGetWithTag("persistence_workshop");
    for _, persistence_item in ipairs(persistence_list) do
			workshop_list[#workshop_list+1] = persistence_item;
		end
	end

	for _, qualified_workshop in ipairs(workshop_list) do
		local qshop_x, qshop_y = EntityGetTransform(qualified_workshop);
		local qshop_hitbox_comp = EntityGetFirstComponentIncludingDisabled(qualified_workshop, "HitboxComponent");
		local qshop_hit_min_x = tonumber(ComponentGetValue2(qshop_hitbox_comp, "aabb_min_x")) + qshop_x;
		local qshop_hit_min_y = tonumber(ComponentGetValue2(qshop_hitbox_comp, "aabb_min_y")) + qshop_y;
		local qshop_hit_max_x = tonumber(ComponentGetValue2(qshop_hitbox_comp, "aabb_max_x")) + qshop_x;
		local qshop_hit_max_y = tonumber(ComponentGetValue2(qshop_hitbox_comp, "aabb_max_y")) + qshop_y;
		if aabb_check(plr_x, plr_y, qshop_hit_min_x, qshop_hit_min_y, qshop_hit_max_x, qshop_hit_max_y) then
			is_in_workshop = true;
			if is_in_workshop and not is_in_workshop_before then
				if ModSettingGet("persistence.enable_teleport_back_up") then
					show_teleport_gui();
				end
			end
		end
	end


	if (is_in_workshop and ModSettingGet("persistence.enable_menu_in_holy_mountain")) or (GlobalsGetValue("lobby_collider_triggered") ~= nil and GlobalsGetValue("lobby_collider_triggered") == "1") then
		if not is_in_lobby then
			is_in_lobby = true;
			enter_lobby();
			if inventory_open then
				hide_lobby_gui();
			end
		end
		GlobalsSetValue("lobby_collider_triggered", "0");
	else
		if is_in_lobby then
			is_in_lobby = false;
			exit_lobby();
		end
	end

	if not is_in_workshop and is_in_workshop_before then
		disable_edit_wands_in_lobby();
		hide_teleport_gui();
		exit_lobby();
	end

	if ComponentGetValue2(get_inventory_gui(), "mActive") then
		if not inventory_open then
			inventory_open = true;
			if menu_open then
				hide_lobby_gui();
			end
		end
	else
		if inventory_open then
			inventory_open = false;
			if menu_open then
				show_lobby_gui();
			end
		end
	end
end



function OnPlayerSpawned(player_entity)
	dofile_once("mods/persistence/config.lua");
	lobby_collider = EntityGetWithName("persistence_lobby_collider");
	if lobby_collider == nil or lobby_collider == 0 then
		if ModSettingGet("persistence.move_lobby_to_spawn") then
			local x, y = EntityGetTransform(get_player_id());
			lobby_collider = EntityLoad("mods/persistence/files/lobby_collider.xml", x, y);
			lobby_x, lobby_y = EntityGetTransform(lobby_collider);
		end
	else
		lobby_x, lobby_y = EntityGetTransform(lobby_collider);
	end

	update_screen_size();
end

function OnPostPlayerSpawned()
	dofile_once("mods/persistence/files/data_store.lua");
	dofile_once("mods/persistence/files/gui.lua");

	if GameGetFrameNum() < 20 then
		set_run_created_with_mod();
	end

	local selected_save_id = get_selected_save_id();
	if selected_save_id == nil then
		if not get_run_created_with_mod() then
			set_selected_save_id(0);
		else
			load_save_ids();
			local load_slot_id = tonumber(ModSettingGet("persistence.always_choose_save_id"))
			if load_slot_id >= 0 then
				if load_slot_id == 0 then
					set_selected_save_id(0);
				else
					if get_save_ids()[load_slot_id] == nil then
						set_selected_save_id(load_slot_id);
						create_new_save(load_slot_id);
						OnSaveAvailable(load_slot_id);
					else
						set_selected_save_id(load_slot_id);
						load(load_slot_id);
						OnSaveAvailable(load_slot_id);
					end
				end
			else
				disable_controls();
				show_save_selector_gui();
			end
		end
	else
		if selected_save_id ~= 0 then
			load(selected_save_id);
			OnSaveAvailable(selected_save_id);
		end
	end
end

function OnSaveAvailable(save_id)

end

function OnPlayerDied(player_entity)
	hide_all_gui();
	if get_selected_save_id() == nil or get_selected_save_id() == 0 then
		return;
	end

	local money = get_player_money();
	local money_to_save = math.floor(money * ModSettingGet("persistence.money_saved_on_death") );
	GamePrintImportant("You died", " $ " .. tostring(money_to_save) .. " was saved.");
	set_safe_money(get_selected_save_id(), math.abs(get_safe_money(get_selected_save_id()) + money_to_save));
end

function GameOnCompleted()

end