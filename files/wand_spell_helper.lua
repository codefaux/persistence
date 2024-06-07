dofile_once("mods/persistence/config.lua");
dofile_once("mods/persistence/files/helper.lua");
dofile_once("data/scripts/gun/gun_actions.lua");
dofile_once("data/scripts/gun/procedural/gun_procedural.lua");

wands_by_type = {};

function load_wands_by_type()
	for _, wand_entry in pairs(wands) do
		wands_by_type[sprite_file_to_wand_type(wand_entry.file)] = wand_entry;
	end
end


function wand_type_to_sprite_file(wand_type)
	if string.sub(wand_type, 1, #"default") == "default" then
		local nr = tonumber(string.sub(wand_type, #"default" + 2));
		return mod_config.default_wands[nr].file;
	else
		if string.match(wand_type, "wand_%d%d%d%d") then
			return "data/items_gfx/wands/" .. wand_type .. ".png";
		else
			return "data/items_gfx/" .. wand_type .. ".png";
		end
	end
end

function wand_type_to_base_wand(wand_type)
	if string.sub(wand_type, 1, #"default") == "default" then
		local nr = tonumber(string.sub(wand_type, #"default" + 2));
		return mod_config.default_wands[nr];
	else
		return wands_by_type[wand_type];
	end
end

function get_wand_grip_offset(wand_type)
	local base_wand = wand_type_to_base_wand(wand_type);
	if base_wand ~= nil then
		return base_wand.grip_x, base_wand.grip_y;
	end
	return 0, 0;
end

function get_wand_rotated_offset(grip_x, grip_y, rot_degrees)
	return (grip_x)*math.cos(-rot_degrees) - (grip_y)*math.sin(-rot_degrees),
				 (grip_x)*math.sin(-rot_degrees) + (grip_y)*math.cos(-rot_degrees);
end


function sprite_file_to_wand_type(sprite_file)
	for i = 1, #mod_config.default_wands do
		if mod_config.default_wands[i].file == sprite_file then
			return "default_" .. i;
		end
	end
	return string.sub(sprite_file, string.find(sprite_file, "/[^/]*$") + 1, -5);
end

function read_wand(entity_id)
	local wand_data = {};

	local comp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent");

	if comp == nil then
		return wand_data;
	end

	wand_data["shuffle"] = ComponentObjectGetValue2(comp, "gun_config", "shuffle_deck_when_empty") == 1 and true or false;
	wand_data["spells_per_cast"] = ComponentObjectGetValue2(comp, "gun_config", "actions_per_round");
	wand_data["cast_delay"] = ComponentObjectGetValue2(comp, "gunaction_config", "fire_rate_wait");
	wand_data["recharge_time"] = ComponentObjectGetValue2(comp, "gun_config", "reload_time");
	wand_data["mana_max"] = ComponentGetValue2(comp, "mana_max");
	wand_data["mana_charge_speed"] = ComponentGetValue2(comp, "mana_charge_speed");
	wand_data["capacity"] = ComponentObjectGetValue2(comp, "gun_config", "deck_capacity");
	wand_data["spread"] = ComponentObjectGetValue2(comp, "gunaction_config", "spread_degrees");
	wand_data["wand_type"] = sprite_file_to_wand_type(ComponentGetValue2(comp, "sprite_file"));

	wand_data["spells"] = {};
	wand_data["always_cast_spells"] = {};
	local childs = EntityGetAllChildren(entity_id);
	if childs ~= nil then
		for _, child_id in ipairs(childs) do
			local item_action_comp = EntityGetFirstComponentIncludingDisabled(child_id, "ItemActionComponent");
			if item_action_comp ~= nil and item_action_comp ~= 0 then
				local action_id = ComponentGetValue2(item_action_comp, "action_id");
				if ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(child_id, "ItemComponent"), "permanently_attached") == true then
					table.insert(wand_data["always_cast_spells"], action_id);
				else
					table.insert(wand_data["spells"], action_id);
				end
			end
		end
	end
	wand_data["capacity"] = wand_data["capacity"] - #wand_data["always_cast_spells"];
	return wand_data;
end

function get_spell_entity_action_id(entity_id)
	return ComponentGetValue2( EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent"), "action_id");
end

function delete_wand_entity(entity_id)
	if not EntityHasTag(entity_id, "wand") then
		return;
	end
	EntityKill(entity_id);
end

function delete_spell_entity(entity_id)
	if not EntityHasTag(entity_id, "card_action") then
		return;
	end
	EntityKill(entity_id);
end

function create_wand_price(wand_data)
	local price = 0;
	if not wand_data["shuffle"] then
		price = price + 100;
	end
	price = price + math.max(wand_data["spells_per_cast"] - 1, 0) * 500;
	price = price + (0.01 ^ (wand_data["cast_delay"] / 60 - 1.8) + 200) * 0.1;
	price = price + (0.01 ^ (wand_data["recharge_time"] / 60 - 1.8) + 200) * 0.1;
	price = price + wand_data["mana_max"];
	price = price + wand_data["mana_charge_speed"] * 2;
	price = price + math.max(wand_data["capacity"] - 1, 0) * 50;
	price = price + math.abs(5 - wand_data["spread"]) * 5;
	if wand_data["always_cast_spells"] ~= nil and #wand_data["always_cast_spells"] > 0 then
		for _, always_cast_id in ipairs(wand_data["always_cast_spells"]) do
				price = price + actions_by_id[always_cast_id].price * 5;
		end
	end
	return math.ceil(price * ModSettingGet("persistence.buy_wand_price_multiplier"));
end

function create_wand(wand_data)
	local price = create_wand_price(wand_data);
	if get_player_money() < price then
		return false;
	end

	local x, y = EntityGetTransform(get_player_id());
	local entity_id = EntityLoad("mods/persistence/files/wand_empty.xml", x, y);
	local ability_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent");
	local wand = wand_type_to_base_wand(wand_data["wand_type"]);

	if wand == nil then
		return false;
	end

	ComponentSetValue2(ability_comp, "ui_name", wand.name);
	ComponentObjectSetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty", wand_data["shuffle"] and true or false);
	ComponentObjectSetValue2(ability_comp, "gun_config", "actions_per_round", wand_data["spells_per_cast"]);
	ComponentObjectSetValue2(ability_comp, "gunaction_config", "fire_rate_wait", wand_data["cast_delay"]);
	ComponentObjectSetValue2(ability_comp, "gun_config", "reload_time", wand_data["recharge_time"]);
	ComponentSetValue2(ability_comp, "mana_max", wand_data["mana_max"]);
	ComponentSetValue2(ability_comp, "mana", wand_data["mana_max"]);
	ComponentSetValue2(ability_comp, "mana_charge_speed", wand_data["mana_charge_speed"]);
	ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", wand_data["capacity"]);
	ComponentObjectSetValue2(ability_comp, "gunaction_config", "spread_degrees", wand_data["spread"]);
	ComponentObjectSetValue2(ability_comp, "gunaction_config", "speed_multiplier", 1);
	ComponentSetValue2(ability_comp, "item_recoil_recovery_speed", 15);
	if #wand_data["always_cast_spells"] > 0 then
		for i = 1, #wand_data["always_cast_spells"] do
			AddGunActionPermanent(entity_id, wand_data["always_cast_spells"][i]);
		end
	end
	SetWandSprite(entity_id, ability_comp, wand.file, wand.grip_x, wand.grip_y, (wand.tip_x - wand.grip_x), (wand.tip_y - wand.grip_y));

	set_player_money(get_player_money() - price);
	return true;
end

function create_spell_price(action_id)
	return math.ceil(actions_by_id[action_id].price * ModSettingGet("persistence.buy_spell_price_multiplier"));
end

function create_spell(action_id)
	local price = create_spell_price(action_id);
	if get_player_money() < price then
		return false;
	end

	local x, y = EntityGetTransform(get_player_id());
	CreateItemActionEntity(action_id, x, y);

	set_player_money(get_player_money() - price);
	return true;
end

function get_all_wands()
	local wands = {};
	if EntityGetWithName("inventory_quick") == nil then
		return wands;
	end
	local inventory_quick_childs = EntityGetAllChildren(EntityGetWithName("inventory_quick"));
	if inventory_quick_childs ~=nil then
		for _, item in ipairs(inventory_quick_childs) do
			if EntityHasTag(item, "wand") then
				local inventory_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent");
				local x, _ = ComponentGetValue2(inventory_comp, "inventory_slot");
				wands[x] = item;
			end
		end
	end
	return wands;
end

function get_all_inv_spells()
	local spells = {};
	if EntityGetWithName("inventory_full") == nil then
		return spells;
	end
	local inventory_full_childs = EntityGetAllChildren(EntityGetWithName("inventory_full"));
	if inventory_full_childs ~=nil then
		for _, item in ipairs(inventory_full_childs) do
			table.insert(spells, item);
		end
	end
	return spells;
end