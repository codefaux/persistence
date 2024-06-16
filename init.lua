dofile_once("mods/persistence/files/helper.lua");
dofile_once("data/scripts/lib/mod_settings.lua");

local is_in_lobby = false;
local inventory_open = false;
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
	EntitySetTransform(get_player_entity_id(), lobby_x, lobby_y);
end

function disable_controls()
	local player_id = get_player_entity_id();
	EntitySetComponentIsEnabled(player_id, get_inventory_gui(), false);
	EntitySetComponentIsEnabled(player_id, get_inventory2(), false);
	EntitySetComponentIsEnabled(player_id, get_controls_component(), false);
end

function enable_controls()
	local player_id = get_player_entity_id();
	EntitySetComponentIsEnabled(player_id, get_controls_component(), true);
	EntitySetComponentIsEnabled(player_id, get_inventory2(), true);
	EntitySetComponentIsEnabled(player_id, get_inventory_gui(), true);
end

function update_screen_size()
	teleport_component = EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "TeleportComponent");
	if teleport_component ~= nil and teleport_component ~= 0 then
		EntitySetComponentIsEnabled(get_player_entity_id(), teleport_component, true);
	else
		-- EntityAddComponent2(get_player_entity_id(), "TeleportComponent", {});
	end
end

local is_post_player_spawned = false;
local is_in_workshop = false;


-- GAME ENGINE EVENTS

function OnModPreInit()
end

function OnWorldPostUpdate()
	dofile("mods/persistence/files/actions_by_id.lua");

	if lobby_collider == nil or lobby_collider == 0 then
		local controls_mouse = EntityGetWithTag("controls_mouse")[1];
		if controls_mouse ~= nil and controls_mouse ~= 0 then
			local x, y = EntityGetTransform(controls_mouse);
			lobby_collider = EntityLoad("mods/persistence/files/lobby_collider.xml", x - 50, y + 30);
			lobby_x, lobby_y = EntityGetTransform(lobby_collider);
		end
	end

	if get_player_entity_id() == nil or get_player_entity_id() == 0 or not EntityGetIsAlive(get_player_entity_id()) then
		return;
	end

	teleport_component = EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "TeleportComponent");
	if teleport_component ~= nil and teleport_component ~= 0 then
		local a, b, c, d = ComponentGetValue2(teleport_component, "source_location_camera_aabb");
		if a ~= 0 or b ~= 0 or c ~= 0 or d ~= 0 then
			EntitySetComponentIsEnabled(get_player_entity_id(), teleport_component, false);
			ComponentSetValue2(teleport_component, "source_location_camera_aabb", 0, 0, 0, 0);
		end
	end

	if not is_post_player_spawned then
		OnPostPlayerSpawned();
		is_post_player_spawned = true;
	end

	if get_selected_profile_id == nil or get_selected_profile_id() == 0 then
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

	if get_selected_profile_id() == nil then
		return;
	end

	local workshop_list = EntityGetWithTag("workshop");
	local workshop_count = #workshop_list;

	-- for idx, workshop in ipairs(workshop_list) do
	for idx = 1, workshop_count do
		local workshop = workshop_list[idx];
		local shop_x, shop_y = EntityGetTransform(workshop);
		local custom_workshop = EntityGetClosestWithTag(shop_x, shop_y, "persistence_workshop");
		local custom_x, custom_y = EntityGetTransform(custom_workshop);
		if custom_workshop == nil or custom_workshop == 0 or (shop_x - custom_x) * (shop_y - custom_y) > 10 then
			-- GamePrint("Updating workshop " .. custom_workshop .. " for " .. workshop .. " from idx " .. idx .. " to " .. workshop_count + idx );
			custom_workshop = EntityLoad("mods/persistence/files/workshop_collider.xml", shop_x, shop_y);
			local workshop_hitbox_comp = EntityGetFirstComponentIncludingDisabled(workshop, "HitboxComponent"); 
			local custom_workshop_hitbox_comp = EntityGetFirstComponentIncludingDisabled(custom_workshop, "HitboxComponent");
			ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_min_x", ComponentGetValue2(workshop_hitbox_comp, "aabb_min_x"));
			ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_min_y", ComponentGetValue2(workshop_hitbox_comp, "aabb_min_y"));
			ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_max_x", ComponentGetValue2(workshop_hitbox_comp, "aabb_max_x"));
			ComponentSetValue2(custom_workshop_hitbox_comp, "aabb_max_y", ComponentGetValue2(workshop_hitbox_comp, "aabb_max_y"));
			workshop_list[workshop_count + idx] = custom_workshop;
		end
	end

	local plr_x, plr_y = EntityGetTransform(get_player_entity_id());
	local is_in_workshop_before = is_in_workshop;
	is_in_workshop = false;
	-- for _, qualified_workshop in ipairs(EntityGetWithTag(ModSettingGet("persistence.reusable_holy_mountain") and "persistence_workshop" or "workshop")) do
	if ModSettingGet("persistence.reusable_holy_mountain") == true then
		local persistence_list = EntityGetWithTag("persistence_workshop");
    for _, persistence_item in ipairs(persistence_list) do
			-- GamePrint("Adding workshop " .. persistence_item .. " at " .. #workshop_list + 1 );
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
				close_menus();
			end
		end
	end
end



function OnPlayerSpawned(player_entity)
	dofile_once("mods/persistence/config.lua");
	lobby_collider = EntityGetWithName("persistence_lobby_collider");
	if lobby_collider == nil or lobby_collider == 0 then
		if ModSettingGet("persistence.move_lobby_to_spawn") then
			local x, y = EntityGetTransform(get_player_entity_id());
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

	if GameGetFrameNum() < 60 then
		set_run_created_with_mod();
	end

	local selected_profile_id = get_selected_profile_id();
	if selected_profile_id == nil then
		if not get_run_created_with_mod() then
			set_selected_profile_id(0);
		else
			load_profile_ids();
			local load_slot_id = tonumber(ModSettingGet("persistence.always_choose_save_id"))
			if load_slot_id >= 0 then
				if load_slot_id == 0 then
					set_selected_profile_id(0);
				else
					if get_profile_ids()[load_slot_id] == nil then
						set_selected_profile_id(load_slot_id);
						create_new_profile(load_slot_id);
						OnProfileAvailable(load_slot_id);
					else
						set_selected_profile_id(load_slot_id);
						load_profile(load_slot_id);
						OnProfileAvailable(load_slot_id);
					end
				end
			else
				show_profile_selector_gui();
			end
		end
	else
		if selected_profile_id ~= 0 then
			load_profile(selected_profile_id);
			OnProfileAvailable(selected_profile_id);
		end
	end
end

function OnProfileAvailable(profile_id)

end

function OnPlayerDied(player_entity)
	hide_all_gui();
	if get_selected_profile_id() == nil or get_selected_profile_id() == 0 then
		return;
	end

	-- local stat_dead = StatsGetValue("dead");
	-- local stat_death_count = StatsGetValue("death_count");
	-- local stat_streaks = StatsGetValue("streaks");
	-- local stat_world_seed = StatsGetValue("world_seed");
	-- local stat_killed_by = StatsGetValue("killed_by");
	-- local stat_killed_by_extra = StatsGetValue("killed_by_extra");
	-- local stat_playtime = StatsGetValue("playtime");
	-- local stat_playtime_str = StatsGetValue("playtime_str");
	-- local stat_places_visited = StatsGetValue("places_visited");
	-- local stat_enemies_killed = StatsGetValue("enemies_killed");
	-- local stat_heart_containers = StatsGetValue("heart_containers");
	-- local stat_hp = StatsGetValue("hp");
	-- local stat_gold = StatsGetValue("gold");
	-- local stat_gold_all = StatsGetValue("gold_all");
	-- local stat_gold_infinite = StatsGetValue("gold_infinite");
	-- local stat_items = StatsGetValue("items");
	-- local stat_projectiles_shot = StatsGetValue("projectiles_shot");
	-- local stat_kicks = StatsGetValue("kicks");
	-- local stat_damage_taken = StatsGetValue("damage_taken");
	-- local stat_healed = StatsGetValue("healed");
	-- local stat_teleports = StatsGetValue("teleports");
	-- local stat_wands_edited = StatsGetValue("wands_edited");
	-- local stat_biomes_visited_with_wands = StatsGetValue("biomes_visited_with_wands");
	-- local stat_death_pos = StatsGetValue("death_pos");

	-- GamePrint("stat_dead " .. stat_dead);
	-- GamePrint("stat_death_count " .. stat_death_count);
	-- GamePrint("stat_streaks " .. stat_streaks);
	-- GamePrint("stat_world_seed " .. stat_world_seed);
	-- GamePrint("stat_killed_by " .. stat_killed_by);
	-- GamePrint("stat_killed_by_extra " .. stat_killed_by_extra);
	-- GamePrint("stat_playtime " .. stat_playtime);
	-- GamePrint("stat_playtime_str " .. stat_playtime_str);
	-- GamePrint("stat_places_visited " .. stat_places_visited);
	-- GamePrint("stat_enemies_killed " .. stat_enemies_killed);
	-- GamePrint("stat_heart_containers " .. stat_heart_containers);
	-- GamePrint("stat_hp " .. stat_hp);
	-- GamePrint("stat_gold " .. stat_gold);
	-- GamePrint("stat_gold_all " .. stat_gold_all);
	-- GamePrint("stat_gold_infinite " .. stat_gold_infinite);
	-- GamePrint("stat_items " .. stat_items);
	-- GamePrint("stat_projectiles_shot " .. stat_projectiles_shot);
	-- GamePrint("stat_kicks " .. stat_kicks);
	-- GamePrint("stat_damage_taken " .. stat_damage_taken);
	-- GamePrint("stat_healed " .. stat_healed);
	-- GamePrint("stat_teleports " .. stat_teleports);
	-- GamePrint("stat_wands_edited " .. stat_wands_edited);
	-- GamePrint("stat_biomes_visited_with_wands " .. stat_biomes_visited_with_wands);
	-- GamePrint("stat_death_pos " .. stat_death_pos);

	local money = get_player_money();
	local money_to_save = math.floor(money * ModSettingGet("persistence.money_saved_on_death") );
	GamePrintImportant("You died", " $ " .. money_to_save .. " was saved.");
	set_stash_money(get_selected_profile_id(), math.abs(get_stash_money(get_selected_profile_id()) + money_to_save));
end

function GameOnCompleted()

end