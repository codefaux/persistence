dofile_once("data/scripts/lib/mod_settings.lua");
dofile_once("data/scripts/gun/gun_actions.lua");

actions_by_id = {};

function load_actions_by_id()
	for i = 1, #actions do
		actions_by_id[actions[i].id] = actions[i];
		actions_by_id[actions[i].id].actions_index = i;
	end
end

function pad_number(number, length)
	local output = tostring(number);
	for i = 1, length - #output do
		output = " " .. output;
	end
	return number;
end

function get_player_id()
	return EntityGetWithTag("player_unit")[1];
end

function get_wallet()
	return EntityGetFirstComponentIncludingDisabled(get_player_id(), "WalletComponent");
end

function get_inventory_gui()
	return EntityGetFirstComponentIncludingDisabled(get_player_id(), "InventoryGuiComponent");
end

function get_inventory2()
	return EntityGetFirstComponentIncludingDisabled(get_player_id(), "Inventory2Component");
end

function get_controls_component()
	return EntityGetFirstComponentIncludingDisabled(get_player_id(), "ControlsComponent");
end

function enable_edit_wands_in_lobby()
	EntityAddChild(get_player_id(), EntityLoad("mods/persistence/files/edit_wands_in_lobby.xml", 0, 0));
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