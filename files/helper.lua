dofile_once("data/scripts/lib/mod_settings.lua");

function pad_number(number, length)
	local output = tostring(number);
	for i = 1, length - #output do
		output = " " .. output;
	end
	return number;
end

function get_player_entity_id()
	return EntityGetWithTag("player_unit")[1];
end

function get_world_state_entity_id()
	return EntityGetWithTag("world_state")[1];
end

function get_player_stats_component()
	local world_state_children = EntityGetAllChildren(get_world_state_entity_id());
	if world_state_children ~= nil then
		for _, w_s_child_id in ipairs(world_state_children) do
			local player_stats_comp = EntityGetFirstComponentIncludingDisabled(w_s_child_id, "PlayerStatsComponent");
			if player_stats_comp ~= nil and player_stats_comp ~= 0 then
				return player_stats_comp;
			end
		end
	end
end

function get_player_gamestats_component()
	local gamestats_stats_comp = EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "GameStatsComponent");
	if gamestats_stats_comp ~= nil and gamestats_stats_comp ~= 0 then
		return gamestats_stats_comp;
	end
end

function get_wallet()
	return EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "WalletComponent");
end

function get_inventory_gui()
	return EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "InventoryGuiComponent");
end

function get_inventory2()
	return EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "Inventory2Component");
end

function get_controls_component()
	return EntityGetFirstComponentIncludingDisabled(get_player_entity_id(), "ControlsComponent");
end

function enable_edit_wands_in_lobby()
	EntityAddChild(get_player_entity_id(), EntityLoad("mods/persistence/files/edit_wands_in_lobby.xml", 0, 0));
end

function disable_edit_wands_in_lobby()
	local entity_id = EntityGetWithName("persistence_edit_wands_in_lobby");
	if entity_id ~= nil and entity_id ~= 0 then
		EntityKill(entity_id);
	end
end

function simple_string_hash(text) --don't use it for storing passwords...
	local sum = 0;
	for i = 1, #text do
		sum = sum + string.byte(text, i) * i * 2999;
	end
	return sum;
end

function aabb_check(x, y, min_x, min_y, max_x, max_y)
	return x > min_x and x < max_x and y > min_y and y < max_y;
end