dofile_once("mods/persistence/config.lua");
dofile_once("data/scripts/gun/gun_actions.lua");
dofile_once("data/scripts/gun/procedural/wands.lua");
dofile_once("mods/persistence/files/wand_spell_helper.lua");

local spells_per_cast_min = 1;
local mana_max_min = 1;
local mana_charge_speed_min = 1;
local capacity_min = 1;

local data_store = {};
local flag_prefix = "persistence";
local selected_profile_id;

function get_profile_count()
	return 5;
end

function get_template_count()
	return 5;
end

local function number_to_hex(number)
	if number == nil then
		return nil;
	end
	local positive = math.abs(number);
	return (positive == number and "" or "-") .. string.format("%x", positive);
end

local function hex_to_number(hex)
	if hex == nil then
		return nil;
	end
	if string.sub(hex, 1, 1) == "-" then
		return tonumber(string.sub(hex, 2), 16) * -1;
	else
		return tonumber(hex, 16);
	end
end

local hex_chars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "-" }
local function write_hex(name, hex)
	if hex == nil then
		for j = 1, #hex_chars do
			RemoveFlagPersistent(flag_prefix .. "_" .. name .. "_" .. 1 .. "_" .. hex_chars[j]);
		end
		return;
	end
	for i = 1, #hex do
		for j = 1, #hex_chars do
			RemoveFlagPersistent(flag_prefix .. "_" .. name .. "_" .. i .. "_" .. hex_chars[j]);
		end
		AddFlagPersistent(flag_prefix .. "_" .. name .. "_" .. i .. "_" .. string.sub(hex, i, i));
	end
	for j = 1, #hex_chars do
		RemoveFlagPersistent(flag_prefix .. "_" .. name .. "_" .. #hex + 1 .. "_" .. hex_chars[j]);
	end
end

local function load_hex(name)
	local output = "";
	local i = 1;
	repeat
		local hex_found = false;
		for j = 1, #hex_chars do
			if HasFlagPersistent(flag_prefix .. "_" .. name .. "_" .. i .. "_" .. hex_chars[j]) then
				output = output .. hex_chars[j];
				hex_found = true;
				break;
			end
		end
		i = i + 1;
	until not hex_found
	return (output == "" and nil or output);
end

function set_run_created_with_mod()
	GameAddFlagRun(flag_prefix .. "_using_mod");
end

function get_run_created_with_mod()
	return GameHasFlagRun(flag_prefix .. "_using_mod");
end


-- spells
function get_spells(profile_id)
	return data_store[profile_id]["spells"], data_store[profile_id]["spells_known"]~=nil and data_store[profile_id]["spells_known"] or 0;
end

local function update_spells_known_count(profile_id)
	local spells_known = 0;
	for _, known in pairs(data_store[profile_id]["spells"]) do
		if known then
			spells_known = spells_known + 1;
		end
	end
	write_hex(tostring(profile_id) .. "_spells_known", number_to_hex(spells_known));
	return spells_known;
end

local function add_spells(profile_id, spells)
	if spells == nil or #spells == 0 then
		return;
	end
	for i = 1, #spells do
		data_store[profile_id]["spells"][spells[i]] = true;
		AddFlagPersistent(flag_prefix .. "_" .. tostring(profile_id) .. "_spell_" .. string.lower(spells[i]));
	end
	update_spells_known_count(profile_id);
end

-- always cast spells
function get_always_cast_spells(profile_id)
	return data_store[profile_id]["always_cast_spells"], data_store[profile_id]["always_cast_spells_known"]~=nil and data_store[profile_id]["always_cast_spells_known"] or 0;
end

---Update profile stored always_cast_spells_known key
---@param profile_id integer profile id
---@return integer always_casts_known quantity known always cast spells
local function update_always_cast_spells_known_count(profile_id)
	local always_casts_known = 0;
	for _, known in pairs(data_store[profile_id]["always_cast_spells"]) do
		if known then
			always_casts_known = always_casts_known + 1;
		end
	end
	write_hex(tostring(profile_id) .. "_always_cast_spells_known", number_to_hex(always_casts_known));
	return always_casts_known;
end

local function add_always_cast_spells(profile_id, ac_spells)
	if ac_spells == nil or #ac_spells == 0 then
		return;
	end
	for i = 1, #ac_spells do
		data_store[profile_id]["always_cast_spells"][ac_spells[i]] = true;
		AddFlagPersistent(flag_prefix .. "_" .. tostring(profile_id) .. "_always_cast_spell_" .. string.lower(ac_spells[i]));
	end
	update_always_cast_spells_known_count(profile_id);
end

-- wand types
function get_wand_types(profile_id)
	return data_store[profile_id]["wand_types"],
				data_store[profile_id]["wand_types_known"]~=nil and data_store[profile_id]["wand_types_known"] or 0;
end

function get_wand_types_idx(profile_id)
	return data_store[profile_id]["wand_types_idx"],
				data_store[profile_id]["wand_types_known"]~=nil and data_store[profile_id]["wand_types_known"] or 0;
end

local function update_wand_types_known_count(profile_id)
	local wand_types_known = 0;
	for _, known in pairs(data_store[profile_id]["wand_types"]) do
		if known then
			wand_types_known = wand_types_known + 1;
		end
	end
	write_hex(tostring(profile_id) .. "_wand_types_known", number_to_hex(wand_types_known));
	return wand_types_known;
end

local function add_wand_types(profile_id, wand_types)
	for i = 1, #wand_types do
		if string.sub(wand_types[i], 1, #"default") ~= "default" then
			data_store[profile_id]["wand_types"][wand_types[i]] = true;
			AddFlagPersistent(flag_prefix .. "_" .. tostring(profile_id) .. "_wand_type_" .. string.lower(wand_types[i]));
		end
	end
	update_wand_types_known_count(profile_id);
end



-- PROFILES

function load_profile_ids()
	for i = 1, get_profile_count() do
		if HasFlagPersistent(flag_prefix .. "_" .. tostring(i)) then
			if data_store[i] == nil then
				data_store[i] = {};
			end
		end
	end
	return get_profile_ids();
end

function get_profile_ids()
	local output = {};
	for i = 1, get_profile_count() do
		if data_store[i] ~= nil then
			output[i] = true;
		end
	end
	return output;
end

function get_selected_profile_id()
	if selected_profile_id == nil then
		for i = 0, get_profile_count() do
			if GameHasFlagRun(flag_prefix .. "_selected_profile_" .. tostring(i)) then
				selected_profile_id = i;
				return i;
			end
		end
		return nil;
	else
		return selected_profile_id;
	end
end

function set_selected_profile_id(profile_id)
	for i = 0, get_profile_count() do
		GameRemoveFlagRun(flag_prefix .. "_selected_profile_" .. tostring(i));
	end
	GameAddFlagRun(flag_prefix .. "_selected_profile_" .. tostring(profile_id));
end

function create_new_profile(profile_id)
	delete_profile(profile_id);
	local retval = load_profile(profile_id);
	AddFlagPersistent(flag_prefix .. "_" .. tostring(profile_id));
end

function delete_profile(profile_id)
	local profile_id_string = tostring(profile_id);

	write_hex(profile_id_string .. "_spells_per_cast", nil);
	write_hex(profile_id_string .. "_cast_delay_min", nil);
	write_hex(profile_id_string .. "_cast_delay_max", nil);
	write_hex(profile_id_string .. "_recharge_time_min", nil);
	write_hex(profile_id_string .. "_recharge_time_max", nil);
	write_hex(profile_id_string .. "_mana_max", nil);
	write_hex(profile_id_string .. "_capacity", nil);
	write_hex(profile_id_string .. "_spread_min", nil);
	write_hex(profile_id_string .. "_spread_max", nil);
	write_hex(profile_id_string .. "_money", nil);
	write_hex(profile_id_string .. "_always_cast_spells_known", nil);
	write_hex(profile_id_string .. "_spells_known", nil);
	write_hex(profile_id_string .. "_wand_types_known", nil);
	for i = 1, #actions do
		RemoveFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_spell_" .. string.lower(actions[i].id));
		RemoveFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_always_cast_spell_" .. string.lower(actions[i].id));
	end
	for i = 1, #wands do
		RemoveFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_wand_type_" .. sprite_file_to_wand_type(wands[i].file));
	end

	for i = 1, get_template_count() do
		delete_template(profile_id, i);
	end

	RemoveFlagPersistent(flag_prefix .. "_" .. profile_id_string);
	data_store[profile_id] = nil;
end

function get_player_money()
	local money = tonumber(ComponentGetValue2(get_wallet(), "money"));
	return money == nil and 0 or money;
end

function set_player_money(value)
	ComponentSetValue2(get_wallet(), "money", value);
end


local function load_all_spells(profile_id)
	local profile_id_string = tostring(profile_id);
	if data_store ~= nil and data_store[profile_id] ~= nil then
		data_store[profile_id]["always_cast_spells"] = {};
		data_store[profile_id]["spells"] = {};
		for i = 1, #actions do
			if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_spell_" .. string.lower(actions[i].id)) then
				data_store[profile_id]["spells"][actions[i].id] = true;
			end
			if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_always_cast_spell_" .. string.lower(actions[i].id)) then
				data_store[profile_id]["always_cast_spells"][actions[i].id] = true;
			end
		end
	end
end

local function load_wand_types(profile_id)
	local profile_id_string = tostring(profile_id);
	local idx = 1;
	data_store[profile_id]["wand_types"] = {};
	data_store[profile_id]["wand_types_idx"] = {};
	for i = 1, #mod_config.default_wands do
		data_store[profile_id]["wand_types"]["default_" .. tostring(i)] = true;
		data_store[profile_id]["wand_types_idx"][idx] = "default_" .. tostring(i);
		idx = idx + 1;
	end
	for i = 1, #wands do
		local wand_type = sprite_file_to_wand_type(wands[i].file);
		if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_wand_type_" .. string.lower(wand_type)) then
			data_store[profile_id]["wand_types"][wand_type] = true;
			data_store[profile_id]["wand_types_idx"][idx] = wand_type;
			idx = idx + 1;
		end
	end
end


---Load a profile quick-view
---@param profile_id integer profile id
---@return integer|nil money stashed money
---@return integer|nil always_cast quantity known always cast spells
---@return integer|nil spells quantity known spells
---@return integer|nil wand_types quantity known wand types
function load_profile_quick(profile_id)
	local profile_id_string = tostring(profile_id);

	local money = hex_to_number(load_hex(profile_id_string .. "_money"));
	local always_cast = hex_to_number(load_hex(profile_id_string .. "_always_cast_spells_known"));
	local spells = hex_to_number(load_hex(profile_id_string .. "_spells_known"));
	local wand_types = hex_to_number(load_hex(profile_id_string .. "_wand_types_known"));

	if always_cast==nil or spells==nil then
		load_all_spells(profile_id);
		if always_cast==nil then
			always_cast = update_always_cast_spells_known_count(profile_id);
		end
		if spells==nil then
			spells = update_spells_known_count(profile_id);
		end
		-- data_store[profile_id] = {};
	end
	if wand_types==nil then
		load_wand_types(profile_id);
		wand_types = update_wand_types_known_count(profile_id);
		-- data_store[profile_id] = {};
	end

	return money, always_cast, spells, wand_types;
end



function load_profile(profile_id)
	local profile_id_string = tostring(profile_id);
	for to_clear = 0, get_profile_count() do
		data_store[to_clear] = {}
	end

	data_store[profile_id]["spells_per_cast"] = hex_to_number(load_hex(profile_id_string .. "_spells_per_cast"));
	data_store[profile_id]["cast_delay_min"] = hex_to_number(load_hex(profile_id_string .. "_cast_delay_min"));
	data_store[profile_id]["cast_delay_max"] = hex_to_number(load_hex(profile_id_string .. "_cast_delay_max"));
	data_store[profile_id]["recharge_time_min"] = hex_to_number(load_hex(profile_id_string .. "_recharge_time_min"));
	data_store[profile_id]["recharge_time_max"] = hex_to_number(load_hex(profile_id_string .. "_recharge_time_max"));
	data_store[profile_id]["mana_max"] = hex_to_number(load_hex(profile_id_string .. "_mana_max"));
	data_store[profile_id]["mana_charge_speed"] = hex_to_number(load_hex(profile_id_string .. "_mana_charge_speed"));
	data_store[profile_id]["capacity"] = hex_to_number(load_hex(profile_id_string .. "_capacity"));
	local spread_min = hex_to_number(load_hex(profile_id_string .. "_spread_min"));
	if spread_min ~= nil then
		spread_min = spread_min / 10;
	end
	data_store[profile_id]["spread_min"] = spread_min;
	local spread_max = hex_to_number(load_hex(profile_id_string .. "_spread_max"));
	if spread_max ~= nil then
		spread_max = spread_max / 10;
	end
	data_store[profile_id]["spread_max"] = spread_max;
	data_store[profile_id]["money"],
	data_store[profile_id]["always_cast_spells_known"],
	data_store[profile_id]["spells_known"],
	data_store[profile_id]["wand_types_known"] = load_profile_quick(profile_id);

	load_all_spells(profile_id);
	load_wand_types(profile_id);

	data_store[profile_id]["templates"] = {};
	for i = 1, get_template_count() do
    load_template(profile_id, i);
	end
end

function data_store_safe(profile_id)
	if data_store[profile_id] == nil then
		return false;
	end
	return true;
end

function wand_types_safe(profile_id)
	if data_store[profile_id]["wand_types"] == nil then
		return false;
	end
	return true;
end

function always_cast_safe(profile_id)
	if data_store[profile_id]["always_cast_spells"] == nil then
		return false;
	end
	return true;
end

function spells_safe(profile_id)
	if data_store[profile_id]["spells"] == nil then
		return false;
	end
	return true;
end

function templates_safe(profile_id)
	if data_store[profile_id]["templates"] == nil then
		return false;
	end
	return true;
end

function data_store_section_safe(profile_id, section)
	if data_store[profile_id] == nil then
		return false;
	end
	if data_store[profile_id][section] == nil then
		return false;
	end
	return true;
end


-- spells per cast
function get_spells_per_cast(profile_id)
	return data_store[profile_id]["spells_per_cast"] == nil and spells_per_cast_min or data_store[profile_id]["spells_per_cast"];
end

local function set_spells_per_cast(profile_id, value)
	data_store[profile_id]["spells_per_cast"] = value;
	write_hex(tostring(profile_id) .. "_spells_per_cast", number_to_hex(data_store[profile_id]["spells_per_cast"]));
end

-- cast delay min
function get_cast_delay_min(profile_id)
	return data_store[profile_id]["cast_delay_min"];
end

local function set_cast_delay_min(profile_id, value)
	data_store[profile_id]["cast_delay_min"] = value;
	write_hex(tostring(profile_id) .. "_cast_delay_min", number_to_hex(data_store[profile_id]["cast_delay_min"]));
end

-- cast delay max
function get_cast_delay_max(profile_id)
	return data_store[profile_id]["cast_delay_max"];
end

local function set_cast_delay_max(profile_id, value)
	data_store[profile_id]["cast_delay_max"] = value;
	write_hex(tostring(profile_id) .. "_cast_delay_max", number_to_hex(data_store[profile_id]["cast_delay_max"]));
end

-- recharge time min
function get_recharge_time_min(profile_id)
	return data_store[profile_id]["recharge_time_min"];
end

local function set_recharge_time_min(profile_id, value)
	data_store[profile_id]["recharge_time_min"] = value;
	write_hex(tostring(profile_id) .. "_recharge_time_min", number_to_hex(data_store[profile_id]["recharge_time_min"]));
end

-- recharge time max
function get_recharge_time_max(profile_id)
	return data_store[profile_id]["recharge_time_max"];
end

local function set_recharge_time_max(profile_id, value)
	data_store[profile_id]["recharge_time_max"] = value;
	write_hex(tostring(profile_id) .. "_recharge_time_max", number_to_hex(data_store[profile_id]["recharge_time_max"]));
end

-- mana max
function get_mana_max(profile_id)
	return data_store[profile_id]["mana_max"] == nil and mana_max_min or data_store[profile_id]["mana_max"];
end

local function set_mana_max(profile_id, value)
	data_store[profile_id]["mana_max"] = value;
	write_hex(tostring(profile_id) .. "_mana_max", number_to_hex(data_store[profile_id]["mana_max"]));
end

-- mana charge speed
function get_mana_charge_speed(profile_id)
	return data_store[profile_id]["mana_charge_speed"] == nil and mana_charge_speed_min or data_store[profile_id]["mana_charge_speed"];
end

local function set_mana_charge_speed(profile_id, value)
	data_store[profile_id]["mana_charge_speed"] = value;
	write_hex(tostring(profile_id) .. "_mana_charge_speed", number_to_hex(data_store[profile_id]["mana_charge_speed"]));
end

-- capacity
function get_capacity(profile_id)
	return data_store[profile_id]["capacity"] == nil and capacity_min or data_store[profile_id]["capacity"];
end

local function set_capacity(profile_id, value)
	data_store[profile_id]["capacity"] = value;
	write_hex(tostring(profile_id) .. "_capacity", number_to_hex(data_store[profile_id]["capacity"]));
end

-- spread min
function get_spread_min(profile_id)
	return data_store[profile_id]["spread_min"];
end

local function set_spread_min(profile_id, value)
	data_store[profile_id]["spread_min"] = value;
	write_hex(tostring(profile_id) .. "_spread_min", number_to_hex(data_store[profile_id]["spread_min"] == nil and nil or math.floor(data_store[profile_id]["spread_min"] * 10)));
end

-- spread max
function get_spread_max(profile_id)
	return data_store[profile_id]["spread_max"];
end

local function set_spread_max(profile_id, value)
	data_store[profile_id]["spread_max"] = value;
	write_hex(tostring(profile_id) .. "_spread_max", number_to_hex(data_store[profile_id]["spread_max"] == nil and nil or math.ceil(data_store[profile_id]["spread_max"] * 10)));
end

-- money
function get_stash_money(profile_id)
	return data_store[profile_id]["money"] == nil and 0 or data_store[profile_id]["money"];
end

function set_stash_money(profile_id, value)
	data_store[profile_id]["money"] = value;
	write_hex(tostring(profile_id) .. "_money", number_to_hex(data_store[profile_id]["money"]));
end

-- templates
function load_template(profile_id, template_id)
	local profile_id_string = tostring(profile_id);
	local template_id_string = tostring(template_id);

	if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_template_" .. template_id_string) then
		data_store[profile_id]["templates"][template_id] = {};
		if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_template_" .. template_id_string .. "_shuffle") then
			data_store[profile_id]["templates"][template_id]["shuffle"] = true;
		else
			data_store[profile_id]["templates"][template_id]["shuffle"] = false;
		end
		data_store[profile_id]["templates"][template_id]["spells_per_cast"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_spells_per_cast"));
		data_store[profile_id]["templates"][template_id]["cast_delay"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_cast_delay"));
		data_store[profile_id]["templates"][template_id]["recharge_time"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_recharge_time"));
		data_store[profile_id]["templates"][template_id]["mana_max"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_mana_max"));
		data_store[profile_id]["templates"][template_id]["mana_charge_speed"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_mana_charge_speed"));
		data_store[profile_id]["templates"][template_id]["capacity"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_capacity"));
		data_store[profile_id]["templates"][template_id]["spread"] = hex_to_number(load_hex(profile_id_string .. "_template_" .. template_id_string .. "_spread")) / 10;

		data_store[profile_id]["templates"][template_id]["always_cast_spells"] = {};
		for key, _ in pairs(data_store[profile_id]["always_cast_spells"]) do
			if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_template_" .. template_id_string .. "_always_cast_spell_" .. string.lower(key)) then
				table.insert(data_store[profile_id]["templates"][template_id]["always_cast_spells"], key);
				break;
			end
		end

		for key, _ in pairs(data_store[profile_id]["wand_types"]) do
			if HasFlagPersistent(flag_prefix .. "_" .. profile_id_string .. "_template_" .. template_id_string .. "_wand_type_" .. string.lower(key)) then
				data_store[profile_id]["templates"][template_id]["wand_type"] = key;
				break;
			end
		end
	end
end

function get_template(profile_id, template_id)
	load_template(profile_id, template_id);
	return data_store[profile_id]["templates"][template_id];
end

function set_template(profile_id, template_id, wand_data)
	delete_template(profile_id, template_id);
	if wand_data == nil then
		return;
	end
	local template_prefix = tostring(profile_id) .. "_template_" .. tostring(template_id);
	local template_flag_prefix = flag_prefix .. "_" .. template_prefix;
	if wand_data["shuffle"] then
		AddFlagPersistent(template_flag_prefix .. "_shuffle");
	end
	write_hex(template_prefix .. "_spells_per_cast", number_to_hex(wand_data["spells_per_cast"]));
	write_hex(template_prefix .. "_cast_delay", number_to_hex(wand_data["cast_delay"]));
	write_hex(template_prefix .. "_recharge_time", number_to_hex(wand_data["recharge_time"]));
	write_hex(template_prefix .. "_mana_max", number_to_hex(wand_data["mana_max"]));
	write_hex(template_prefix .. "_mana_charge_speed", number_to_hex(wand_data["mana_charge_speed"]));
	write_hex(template_prefix .. "_capacity", number_to_hex(wand_data["capacity"]));
	write_hex(template_prefix .. "_spread", number_to_hex(math.floor(wand_data["spread"] * 10 + 0.5)));

	for _, spell in ipairs(wand_data["always_cast_spells"]) do
		AddFlagPersistent(template_flag_prefix .. "_always_cast_spell_" .. string.lower(spell));
	end

	AddFlagPersistent(template_flag_prefix .. "_wand_type_" .. string.lower(wand_data["wand_type"]));

	AddFlagPersistent(template_flag_prefix);
	data_store[profile_id]["templates"][template_id] = wand_data;
end

function delete_template(profile_id, template_id)
	local template_prefix = tostring(profile_id) .. "_template_" .. tostring(template_id);
	local template_flag_prefix = flag_prefix .. "_" .. template_prefix;
	RemoveFlagPersistent(template_flag_prefix .. "_shuffle");
	write_hex(template_prefix .. "_spells_per_cast", nil);
	write_hex(template_prefix .. "_cast_delay", nil);
	write_hex(template_prefix .. "_recharge_time", nil);
	write_hex(template_prefix .. "_mana_max", nil);
	write_hex(template_prefix .. "_mana_charge_speed", nil);
	write_hex(template_prefix .. "_capacity", nil);
	write_hex(template_prefix .. "_spread", nil);

	for i = 1, #actions do
		RemoveFlagPersistent(template_flag_prefix .. "_always_cast_spell_" .. string.lower(actions[i].id));
	end

	for i = 1, #mod_config.default_wands do
		RemoveFlagPersistent(template_flag_prefix .. "_wand_type_default_" .. tostring(i));
	end
	for i = 1, #wands do
		RemoveFlagPersistent(template_flag_prefix .. "_wand_type_" .. string.lower(sprite_file_to_wand_type(wands[i].file)));
	end

	RemoveFlagPersistent(template_flag_prefix);
	if data_store[profile_id] ~= nil and data_store[profile_id]["templates"] ~= nil then
		data_store[profile_id]["templates"][template_id] = nil;
	end
end

function can_create_wand(profile_id)
	if not data_store_safe(profile_id) then
		return false;
	end

	return get_cast_delay_min(profile_id) ~= nil and get_cast_delay_max(profile_id) ~= nil and get_recharge_time_min(profile_id) ~= nil and get_recharge_time_max(profile_id) ~= nil and get_spread_min(profile_id) ~= nil and get_spread_max(profile_id) ~= nil;
end

--- Check if and how a wand entity is new research for profile
---@param profile_id number
---@param entity_id number
---@return boolean is_new
---@return boolean improves_spells_per_cast
---@return boolean improves_cast_delay_min
---@return boolean improves_cast_delay_max
---@return boolean improves_recharge_time_min
---@return boolean improves_recharge_time_max
---@return boolean improves_mana_max
---@return boolean improves_mana_charge_speed
---@return boolean improves_capacity
---@return boolean improves_spread_min
---@return boolean improves_spread_max
---@return boolean improves_always_cast_spells
---@return boolean improves_wand_types
---@return number count_new_always_cast_spells
function research_wand_is_new(profile_id, entity_id)
	local is_new = false;
	local b_spells_per_cast = false;
	local b_cast_delay_min = false;
	local b_cast_delay_max = false;
	local b_recharge_time_min = false;
	local b_recharge_time_max = false;
	local b_mana_max = false;
	local b_mana_charge_speed = false;
	local b_capacity = false;
	local b_spread_min = false;
	local b_spread_max = false;
	local b_always_cast_spells = false;
	local b_wand_types = false;
	local i_always_cast_spells = 0;

	if data_store_safe(profile_id) and entity_id ~= nil then

		local wand_data = read_wand(entity_id);
		local spells_per_cast = get_spells_per_cast(profile_id);
		local cast_delay_min = get_cast_delay_min(profile_id);
		local cast_delay_max = get_cast_delay_max(profile_id);
		local recharge_time_min = get_recharge_time_min(profile_id);
		local recharge_time_max = get_recharge_time_max(profile_id);
		local mana_max = get_mana_max(profile_id);
		local mana_charge_speed = get_mana_charge_speed(profile_id);
		local capacity = get_capacity(profile_id);
		local spread_min = get_spread_min(profile_id);
		local spread_max = get_spread_max(profile_id);
		local always_cast_spells = get_always_cast_spells(profile_id);
		local wand_types = get_wand_types(profile_id);

		if wand_data["spells_per_cast"] > spells_per_cast then
			b_spells_per_cast = true;
			is_new = true;
		end
		if cast_delay_min == nil or cast_delay_max == nil then
			b_cast_delay_min = cast_delay_min == nil;
			b_cast_delay_max = cast_delay_max == nil;
			is_new = true;
		else
			if wand_data["cast_delay"] < cast_delay_min then
				b_cast_delay_min = true;
				is_new = true;
			end
			if wand_data["cast_delay"] > cast_delay_max then
				b_cast_delay_max = true;
				is_new = true;
			end
		end
		if recharge_time_min == nil or recharge_time_max == nil then
			b_recharge_time_min = recharge_time_min == nil;
			b_recharge_time_max = recharge_time_max == nil;
			is_new = true;
		else
			if wand_data["recharge_time"] < recharge_time_min then
				b_recharge_time_min = true;
				is_new = true;
			end
			if wand_data["recharge_time"] > recharge_time_max then
				b_recharge_time_max = true;
				is_new = true;
			end
		end
		if wand_data["mana_max"] > mana_max then
			b_mana_max = true;
			is_new = true;
		end
		if wand_data["mana_charge_speed"] > mana_charge_speed then
			b_mana_charge_speed = true;
			is_new = true;
		end
		if wand_data["capacity"] > capacity then
			b_capacity = true;
			is_new = true;
		end
		if spread_min == nil or spread_max == nil then
			b_spread_min = spread_min == nil;
			b_spread_max = spread_max == nil;
			is_new = true;
		else
			if wand_data["spread"] < spread_min then
				b_spread_min = true;
				is_new = true;
			end
			if wand_data["spread"] > spread_max then
				b_spread_max = true;
				is_new = true;
			end
		end

		if wand_data["always_cast_spells"] ~= nil and #wand_data["always_cast_spells"] > 0 then
			for _, always_cast_id in ipairs(wand_data["always_cast_spells"]) do
				if actions_by_id[always_cast_id] ~= nil and (always_cast_spells == nil or always_cast_spells[always_cast_id] == nil) then
					i_always_cast_spells = i_always_cast_spells + 1;
					b_always_cast_spells = true;
					is_new = true;
				end
			end
		end

		if wand_types == nil or wand_types[wand_data["wand_type"]] == nil then
			if wand_type_to_base_wand(wand_data["wand_type"]) ~= nil then
				is_new = true;
				b_wand_types = true;
			end
		end
	end

	return is_new, b_spells_per_cast, b_cast_delay_min, b_cast_delay_max, b_recharge_time_min, b_recharge_time_max, b_mana_max, b_mana_charge_speed, b_capacity, b_spread_min, b_spread_max, b_always_cast_spells, b_wand_types, i_always_cast_spells;
end

function research_wand_price(profile_id, entity_id)
	if not data_store_safe(profile_id) or not wand_types_safe(profile_id) or not always_cast_safe(profile_id) then
		return 0;
	end

	local wand_data = read_wand(entity_id);
	local spells_per_cast = get_spells_per_cast(profile_id);
	local cast_delay_min = get_cast_delay_min(profile_id);
	local cast_delay_max = get_cast_delay_max(profile_id);
	local recharge_time_min = get_recharge_time_min(profile_id);
	local recharge_time_max = get_recharge_time_max(profile_id);
	local mana_max = get_mana_max(profile_id);
	local mana_charge_speed = get_mana_charge_speed(profile_id);
	local capacity = get_capacity(profile_id);
	local spread_min = get_spread_min(profile_id);
	local spread_max = get_spread_max(profile_id);
	local always_cast_spells = get_always_cast_spells(profile_id);
	local wand_types = get_wand_types(profile_id);
	local price = 0;

	if wand_data["spells_per_cast"] > spells_per_cast then
		price = price + (wand_data["spells_per_cast"] - spells_per_cast) * 1000;
	end
	if cast_delay_min == nil or cast_delay_max == nil then
		price = price + 0.01 ^ (wand_data["cast_delay"] / 60 - 1.8) + 200;
	else
		if wand_data["cast_delay"] < cast_delay_min then
			price = price + (0.01 ^ (wand_data["cast_delay"] / 60 - 1.8) + 200) - (0.01 ^ (cast_delay_min / 60 - 1.8) + 200);
		end
		if wand_data["cast_delay"] > cast_delay_max then
			price = price + (wand_data["cast_delay"] / 60 - cast_delay_max / 60) * 100;
		end
	end
	if recharge_time_min == nil or recharge_time_max == nil then
		price = price + 0.01 ^ (wand_data["recharge_time"] / 60 - 1.8) + 200;
	else
		if wand_data["recharge_time"] < recharge_time_min then
			price = price + (0.01 ^ (wand_data["recharge_time"] / 60 - 1.8) + 200) - (0.01 ^ (recharge_time_min / 60 - 1.8) + 200);
		end
		if wand_data["recharge_time"] > recharge_time_max then
			price = price + (wand_data["recharge_time"] / 60 - recharge_time_max / 60) * 100;
		end
	end
	if wand_data["mana_max"] > mana_max then
		price = price + (wand_data["mana_max"] - mana_max) * 10;
	end
	if wand_data["mana_charge_speed"] > mana_charge_speed then
		price = price + (wand_data["mana_charge_speed"] - mana_charge_speed) * 20;
	end
	if wand_data["capacity"] > capacity then
		price = price + (wand_data["capacity"] - capacity) * 1000;
	end
	if spread_min == nil or spread_max == nil then
		price = price + math.abs(5 - wand_data["spread"]) * 10;
	else
		if wand_data["spread"] < spread_min then
			price = price + (spread_min - wand_data["spread"]) * 10;
		end
		if wand_data["spread"] > spread_max then
			price = price + (wand_data["spread"] - spread_max) * 10;
		end
	end

	if wand_data["always_cast_spells"] ~= nil and #wand_data["always_cast_spells"] > 0 and always_cast_spells ~= nil then
		for _, always_cast_id in ipairs(wand_data["always_cast_spells"]) do
			if always_cast_spells[always_cast_id] == nil then
				price = price + actions_by_id[always_cast_id].price * 20;
			end
		end
	end

	if wand_types == nil or wand_types[wand_data["wand_type"]] == nil then
		if wand_type_to_base_wand(wand_data["wand_type"]) ~= nil then
			price = math.max(100, price);
		end
	end

	return math.ceil(price * ModSettingGet("persistence.research_wand_price_multiplier"));
end

function research_wand(profile_id, entity_id)
	if not data_store_safe(profile_id) or not wand_types_safe(profile_id) or not always_cast_safe(profile_id) then
		return false;
	end

	local wand_data = read_wand(entity_id);
	local spells_per_cast = get_spells_per_cast(profile_id);
	local cast_delay_min = get_cast_delay_min(profile_id);
	local cast_delay_max = get_cast_delay_max(profile_id);
	local recharge_time_min = get_recharge_time_min(profile_id);
	local recharge_time_max = get_recharge_time_max(profile_id);
	local mana_max = get_mana_max(profile_id);
	local mana_charge_speed = get_mana_charge_speed(profile_id);
	local capacity = get_capacity(profile_id);
	local spread_min = get_spread_min(profile_id);
	local spread_max = get_spread_max(profile_id);

	local price = research_wand_price(profile_id, entity_id);
	if get_player_money() < price then
		return false;
	end

	if wand_data["spells_per_cast"] > spells_per_cast then
		set_spells_per_cast(profile_id, wand_data["spells_per_cast"]);
	end
	if cast_delay_min == nil or wand_data["cast_delay"] < cast_delay_min then
		set_cast_delay_min(profile_id, wand_data["cast_delay"]);
	end
	if cast_delay_max == nil or wand_data["cast_delay"] > cast_delay_max then
		set_cast_delay_max(profile_id, wand_data["cast_delay"]);
	end
	if recharge_time_min == nil or wand_data["recharge_time"] < recharge_time_min then
		set_recharge_time_min(profile_id, wand_data["recharge_time"]);
	end
	if recharge_time_max == nil or wand_data["recharge_time"] > recharge_time_max then
		set_recharge_time_max(profile_id, wand_data["recharge_time"]);
	end
	if wand_data["mana_max"] > mana_max then
		set_mana_max(profile_id, wand_data["mana_max"]);
	end
	if wand_data["mana_charge_speed"] > mana_charge_speed then
		set_mana_charge_speed(profile_id, wand_data["mana_charge_speed"]);
	end
	if wand_data["capacity"] > capacity then
		set_capacity(profile_id, wand_data["capacity"]);
	end
	if spread_min == nil or wand_data["spread"] < spread_min then
		set_spread_min(profile_id, wand_data["spread"]);
	end
	if spread_max == nil or wand_data["spread"] > spread_max then
		set_spread_max(profile_id, wand_data["spread"]);
	end
	if wand_data["always_cast_spells"] ~= nil and #wand_data["always_cast_spells"] > 0 then
		add_always_cast_spells(profile_id, wand_data["always_cast_spells"]);
	end
	if wand_type_to_base_wand(wand_data["wand_type"]) ~= nil then
		add_wand_types(profile_id, { wand_data["wand_type"] });
	end

	delete_wand_entity(entity_id);
	set_player_money(get_player_money() - price);
	return true;
end

function research_spell_entity_price(entity_id)
	local action_id = get_spell_entity_action_id(entity_id);
	if action_id == nil then
		return nil
	end
	return math.ceil(actions_by_id[action_id].price * ModSettingGet("persistence.research_spell_price_multiplier"))
end

function research_spell_entity(profile_id, entity_id)
	local price = research_spell_entity_price(entity_id);
	if price == nil then
		return false;
	end
	if get_player_money() < price then
		return false;
	end

	add_spells(profile_id, { get_spell_entity_action_id(entity_id) });

	delete_spell_entity(entity_id);
	set_player_money(get_player_money() - price);
	return true;
end

function transfer_money_player_to_stash(profile_id, amount)
	if get_player_money() < amount then
		return false;
	end
	if not data_store_safe(profile_id) then
		return false;
	end

	set_stash_money(profile_id, get_stash_money(profile_id) + amount);
	set_player_money(get_player_money() - amount);
	return true;
end

function transfer_money_stash_to_player(profile_id, amount)
	if get_stash_money(profile_id) < amount then
		return false;
	end
	if not data_store_safe(profile_id) then
		return false;
	end

	set_player_money(get_player_money() + amount);
	set_stash_money(profile_id, get_stash_money(profile_id) - amount);
	return true;
end
