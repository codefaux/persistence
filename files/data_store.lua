if persistence_data_store_loaded~=true then
  -- On load only
  wands=wands or {};

  dofile_once(mod_dir .. "files/helper.lua");
  dofile_once(mod_dir .. "files/encoder.lua")

  local data_store = {};

  ---@type integer
  default_profile_id =  tonumber(mod_setting.always_choose_save_id) or 0;
  ---@type integer
  selected_profile_id = 0;
  ---@type integer
  loaded_profile_id = 0;

  function get_profile_count() return 4; end
  function get_template_count() return 5; end


  ---- =================
  ---- PRIVATE FUNCTIONS
  ---- =================


  local function _do_startup_paycheck_check()
    if not GameHasFlagRun("persistence_startup_paid") then
      GameAddFlagRun("persistence_startup_paid");
      if mod_setting.start_with_money>0 then
        ---@diagnostic disable-next-line: param-type-mismatch
        local _withdraw = math.min(mod_setting.start_with_money, get_stash_money());
        GamePrint(string.format("Persistence: Run start, $ %i from Stash", _withdraw));
        transfer_money_stash_to_player(_withdraw);
      end
    end
  end

  local function _do_holy_mountain_paycheck_check()
    if mod_setting.holy_mountain_money==0 then return; end

    local _workshop_e_id = tonumber(GlobalsGetValue("workshop_e_id", "0")) or 0;
    if not EntityHasTag(_workshop_e_id, "persistence_visited") then return; end
    if not EntityHasTag(_workshop_e_id, "persistence_unpaid") then return; end
    if     EntityHasTag(_workshop_e_id, "persistence_paid") then return; end

    ---@diagnostic disable-next-line: param-type-mismatch
    local _withdraw = math.min(get_stash_money(), mod_setting.holy_mountain_money);
    GamePrint(string.format("Persistence: Holy Mountain paycheck, $ %i from Stash", _withdraw));
    transfer_money_stash_to_player(_withdraw);
    local _ent_x, _ent_y = EntityGetTransform(_workshop_e_id);

    local _workshops_here = EntityGetInRadiusWithTag(_ent_x, _ent_y, 500, "persistence_workshop");
    for _, _test_e_id in ipairs(_workshops_here) do
      -- GamePrint("Persistence: Marking workshop as paid");
      EntityRemoveTag(_test_e_id, "persistence_unpaid");
      EntityAddTag(_test_e_id, "persistence_paid");
      EntityAddTag(_test_e_id, "persistence_visited");
    end
  end


  ---return wand bounds for profile
  ---@param profile_id integer
  ---@return wand_bounds_data
  local function _get_wand_bounds(profile_id)
    return {
      wand_types = data_store[profile_id]["wand_types"],
      always_casts = data_store[profile_id]["always_cast_spells"],
      always_cast_count = data_store[profile_id]["always_cast_count"],
      spells_per_cast = {1, data_store[profile_id]["spells_per_cast"] == nil and 1 or data_store[profile_id]["spells_per_cast"]},
      mana_max = {2, data_store[profile_id]["mana_max"] or 2},
      mana_charge_speed = {2, data_store[profile_id]["mana_charge_speed"] or 2},
      capacity = {1, data_store[profile_id]["capacity"] == nil and 1 or data_store[profile_id]["capacity"]},
      cast_delay = {data_store[profile_id]["cast_delay_min"], data_store[profile_id]["cast_delay_max"]},
      recharge_time = {data_store[profile_id]["recharge_time_min"], data_store[profile_id]["recharge_time_max"]},
      spread = {data_store[profile_id]["spread_min"], data_store[profile_id]["spread_max"]}
    };
  end

  ---return in-memory {spell_id = true, ... }, spells_known for profile
  ---@param profile_id integer
  ---@return table spells {spell_id = true, ...}
  ---@return integer count known spells
  local function _get_profile_spells(profile_id)
    return data_store[profile_id]["spells"], data_store[profile_id]["spells_known"]~=nil and data_store[profile_id]["spells_known"] or 0;
  end

  ---update quantity of known spells, saved to datastore and disk
  ---@param profile_id integer
  ---@return integer count known spells
  local function _update_spells_known_count(profile_id)
    local spells_known = 0;
    for _, known in pairs(data_store[profile_id]["spells"]) do
      if known then spells_known = spells_known + 1; end
    end
    data_store[profile_id]["spells_known"] = spells_known;
    write_encode_integer(profile_id .. "_spells_known", spells_known);
    return spells_known;
  end

  ---add spells and update known spells count, saved to datastore and disk
  ---@param profile_id integer
  ---@param spells table {1=spell_id, 2=spell_id, ... }
  local function _add_spells(profile_id, spells)
    if spells == nil or #spells == 0 then return; end
    for _, spell_id in ipairs(spells) do
      data_store[profile_id]["spells"][spell_id] = true;
      AddFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_spell_" .. string.lower(spell_id));
    end
    _update_spells_known_count(profile_id);
  end

  ---return in-memory {spell_id = true, ... }, always_cast_spells_known for profile
  ---@param profile_id integer
  ---@return table spells {spell_id = true, ...}
  ---@return integer count known always_cast spells
  local function _get_always_cast_spells(profile_id)
    return data_store[profile_id]["always_cast_spells"], data_store[profile_id]["always_cast_spells_known"] or 0;
  end

  ---update quantity of known always_cast spells, saved to datastore and disk
  ---@param profile_id integer
  ---@return integer count known always_cast spells
  local function _update_always_cast_spells_known_count(profile_id)
    local always_casts_known = 0;
    for _, known in pairs(data_store[profile_id]["always_cast_spells"]) do
      if known then always_casts_known = always_casts_known + 1; end
    end
    data_store[profile_id]["always_cast_spells_known"]=always_casts_known;
    write_encode_integer(profile_id .. "_always_cast_spells_known", always_casts_known);
    return always_casts_known;
  end

  ---add always_cast spells and update known always_cast spells count, saved to datastore and disk
  ---@param profile_id integer
  ---@param ac_spells table {1=spell_id, 2=spell_id, ... }
  local function _add_always_cast_spells(profile_id, ac_spells)
    if ac_spells == nil or #ac_spells == 0 then return; end
    for _, curr_ac_spell_id in ipairs(ac_spells) do
      data_store[profile_id]["always_cast_spells"][curr_ac_spell_id] = true;
      AddFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_always_cast_spell_" .. string.lower(curr_ac_spell_id));
    end
    _update_always_cast_spells_known_count(profile_id);
  end

  ---load spells, always_cast spells, and known quantities from disk
  ---@param profile_id integer
  local function _load_profile_spells(profile_id)
    if data_store ~= nil and data_store[profile_id] ~= nil then
      local prefixed_string = mod_flag_name .. "_" .. profile_id;
      data_store[profile_id]["always_cast_spells"] = {};
      data_store[profile_id]["spells"] = {};
      for curr_action_id, _ in pairs(actions_by_id) do
        if HasFlagPersistent(prefixed_string .. "_spell_" .. string.lower(curr_action_id)) then data_store[profile_id]["spells"][curr_action_id] = true; end
        if HasFlagPersistent(prefixed_string .. "_always_cast_spell_" .. string.lower(curr_action_id)) then  data_store[profile_id]["always_cast_spells"][curr_action_id] = true; end
      end
      data_store[profile_id]["spells_known"] = _update_spells_known_count(profile_id);
      data_store[profile_id]["always_cast_spells_known"] = _update_always_cast_spells_known_count(profile_id);
    end
  end

  ---update quantity of known wand types, saved to datastore and disk
  ---@param profile_id integer
  ---@return integer count known wand types
  local function _update_wand_types_known_count(profile_id)
    local wand_types_known = 0;
    for _, known in pairs(data_store[profile_id]["wand_types"]) do
      if known then wand_types_known = wand_types_known + 1; end
    end
    data_store[profile_id]["wand_types_known"]=wand_types_known;
    write_encode_integer(profile_id .. "_wand_types_known", wand_types_known);
    return wand_types_known;
  end

  ---add wand types and update known wand types count, saved to datastore and disk
  ---@param profile_id integer
  ---@param wand_types table {1=wand_type, 2=wand_type, ... }
  local function _add_wand_types(profile_id, wand_types)
    for _, curr_wand_type in ipairs(wand_types) do
      if string.sub(curr_wand_type, 1, #"default") ~= "default" then
        data_store[profile_id]["wand_types"][curr_wand_type] = true;
        AddFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_wand_type_" .. string.lower(curr_wand_type));
      end
    end
    _update_wand_types_known_count(profile_id);
  end

  ---load wand types and known quantity from disk
  ---@param profile_id integer
  local function _load_wand_types(profile_id)
    local idx = 0;
    data_store[profile_id]["wand_types"] = {};
    data_store[profile_id]["wand_types_idx"] = {};
    ---TODO: is this actually necessary? Debug and check
    local prefixed_string = mod_flag_name .. "_" .. profile_id;
    for i, _ in ipairs(default_wands) do
      idx = idx + 1;
      data_store[profile_id]["wand_types"]["default_" .. i] = true;
      data_store[profile_id]["wand_types_idx"][idx] = "default_" .. i;
    end
    for _, scan_wand in ipairs(wands) do
      local scan_wand_type = sprite_file_to_wand_type(scan_wand.file);
      if HasFlagPersistent(prefixed_string .. "_wand_type_" .. string.lower(scan_wand_type)) then
        idx = idx + 1;
        data_store[profile_id]["wand_types"][scan_wand_type] = true;
        data_store[profile_id]["wand_types_idx"][idx] = scan_wand_type;
      end
    end
    data_store[profile_id]["wand_types_known"] = _update_wand_types_known_count(profile_id);
  end

  local function _set_spells_per_cast(profile_id, value)
    data_store[profile_id]["spells_per_cast"] = value;
    write_encode_integer(profile_id .. "_spells_per_cast", data_store[profile_id]["spells_per_cast"]);
  end

  local function _set_cast_delay_min(profile_id, value)
    data_store[profile_id]["cast_delay_min"] = value;
    write_encode_integer(profile_id .. "_cast_delay_min", data_store[profile_id]["cast_delay_min"]);
  end

  local function _set_cast_delay_max(profile_id, value)
    data_store[profile_id]["cast_delay_max"] = value;
    write_encode_integer(profile_id .. "_cast_delay_max", data_store[profile_id]["cast_delay_max"]);
  end

  local function _set_recharge_time_min(profile_id, value)
    data_store[profile_id]["recharge_time_min"] = value;
    write_encode_integer(profile_id .. "_recharge_time_min", data_store[profile_id]["recharge_time_min"]);
  end

  local function _set_recharge_time_max(profile_id, value)
    data_store[profile_id]["recharge_time_max"] = value;
    write_encode_integer(profile_id .. "_recharge_time_max", data_store[profile_id]["recharge_time_max"]);
  end

  local function _set_mana_max(profile_id, value)
    data_store[profile_id]["mana_max"] = value;
    write_encode_integer(profile_id .. "_mana_max", data_store[profile_id]["mana_max"]);
  end

  local function _set_mana_charge_speed(profile_id, value)
    data_store[profile_id]["mana_charge_speed"] = value;
    write_encode_integer(profile_id .. "_mana_charge_speed", data_store[profile_id]["mana_charge_speed"]);
  end

  local function _set_capacity(profile_id, value)
    data_store[profile_id]["capacity"] = value;
    write_encode_integer(profile_id .. "_capacity", data_store[profile_id]["capacity"]);
  end

  local function _set_spread_min(profile_id, value)
    data_store[profile_id]["spread_min"] = value;
    write_encode_integer(profile_id .. "_spread_min", data_store[profile_id]["spread_min"] == nil and nil or math.floor(data_store[profile_id]["spread_min"] * 10));
  end

  local function _set_spread_max(profile_id, value)
    data_store[profile_id]["spread_max"] = value;
    write_encode_integer(profile_id .. "_spread_max", data_store[profile_id]["spread_max"] == nil and nil or math.ceil(data_store[profile_id]["spread_max"] * 10));
  end

  -- money
  local function _get_stash_money(profile_id)
    return data_store[profile_id]["money"] or 0;
  end

  local function _set_stash_money(profile_id, value)
    data_store[profile_id]["money"] = value;
    write_encode_integer(profile_id .. "_money", data_store[profile_id]["money"]);
  end

  ---increments stash money, returns success
  ---@param profile_id integer profile
  ---@param amount integer money
  ---@return boolean success
  local function _increment_stash_money(profile_id, amount)
    local _stash = data_store[profile_id]["money"] or 0;
    local _target = _stash + amount;
    if _stash < _target then return false; end

    data_store[profile_id]["money"] = _target;
    write_encode_integer(profile_id .. "_money", data_store[profile_id]["money"]);
    return true;
  end

  ---decrements stash money, returns success
  ---@param profile_id integer profile
  ---@param amount integer money
  ---@return boolean success
  local function _decrement_stash_money(profile_id, amount)
    local _stash = data_store[profile_id]["money"] or 0;
    local _target = _stash - amount;
    if _stash > _target then return false; end

    data_store[profile_id]["money"] = _target;
    write_encode_integer(profile_id .. "_money", data_store[profile_id]["money"]);
    return true;
  end

  -- always_cast_count
  local function _get_always_cast_count(profile_id)
    return data_store[profile_id]["always_cast_count"] or 0;
  end

  local function _set_always_cast_count(profile_id, value)
    data_store[profile_id]["always_cast_count"] = value;
    write_encode_integer(tostring(profile_id) .. "_always_cast_count", data_store[profile_id]["always_cast_count"]);
  end


  local function _transfer_money_player_to_stash(profile_id, amount)
    if get_player_money() < amount then
      return false;
    end

    _increment_stash_money(profile_id, amount);
    decrement_player_money(amount);
    return true;
  end

  local function _transfer_money_stash_to_player(profile_id, amount)
    local _money = get_player_money();
    if _money >= (2^29) then return false; end
    if _money + amount > (2^29) then return false; end
    if _get_stash_money(profile_id) < amount then return false; end

    local _newtarget = math.min(_money + amount, (2^29));
    local _difference = _newtarget - _money;

    if set_player_money( _newtarget ) then
      return _decrement_stash_money(profile_id, _difference);
    else
      return false;
    end
  end

  ---Load a profile quick-view, return values and populate datastore
  ---@param profile_id integer profile id
  ---@return integer|nil money stashed money
  ---@return integer|nil always_cast quantity known always cast spells
  ---@return integer|nil spells quantity known spells
  ---@return integer|nil wand_types quantity known wand types
  local function _load_profile_quick(profile_id)
    local money = load_decode_integer(profile_id .. "_money") or 0;
    local always_cast = load_decode_integer(profile_id .. "_always_cast_spells_known") or 0;
    local spells = load_decode_integer(profile_id .. "_spells_known") or 0;
    local wand_types = load_decode_integer(profile_id .. "_wand_types_known") or 0;

    if always_cast==0 or spells==0 or wand_types==0 then
      _load_profile_spells(profile_id);
      _load_wand_types(profile_id);
      always_cast = _update_always_cast_spells_known_count(profile_id) or 0;
      spells = _update_spells_known_count(profile_id) or 0;
      wand_types = _update_wand_types_known_count(profile_id) or 0;
    end
    data_store[profile_id]["quickloaded"] = true;
    data_store[profile_id]["money"] = money;
    data_store[profile_id]["always_cast_spells_known"] = always_cast;
    data_store[profile_id]["spells_known"] = spells;
    data_store[profile_id]["wand_types_known"] = wand_types;
    return money, always_cast, spells, wand_types;
  end

  -- templates
  local function _get_template(profile_id, template_id)
    local template_id_string = template_id;

    local _template = {};
    if HasFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_template_" .. template_id_string) then
      if HasFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_template_" .. template_id_string .. "_shuffle") then
        _template["shuffle"] = true;
      else
        _template["shuffle"] = false;
      end
      _template["spells_per_cast"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_spells_per_cast");
      _template["cast_delay"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_cast_delay");
      _template["recharge_time"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_recharge_time");
      _template["mana_max"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_mana_max");
      _template["mana_charge_speed"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_mana_charge_speed");
      _template["capacity"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_capacity");
      _template["spread"] = load_decode_integer(profile_id .. "_template_" .. template_id_string .. "_spread") / 10;

      _template["always_cast_spells"] = {};
      for key, _ in pairs(data_store[profile_id]["always_cast_spells"]) do
        if HasFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_template_" .. template_id_string .. "_always_cast_spell_" .. string.lower(key)) then
          table.insert(_template["always_cast_spells"], key);
        end
      end
      _template["always_cast_count"] = #_template["always_cast_spells"];

      for key, _ in pairs(data_store[profile_id]["wand_types"]) do
        if HasFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_template_" .. template_id_string .. "_wand_type_" .. string.lower(key)) then
          _template["wand_type"] = key;
          break;
        end
      end
      _template.price = get_wand_buy_price(_template);
    end
    return _template;
  end

  local function _get_templates(profile_id)
    local _templates = {};
    for _idx = 1, get_template_count() do
      table.insert(_templates, _get_template(profile_id, _idx));
    end
    return _templates;
  end

  local function _delete_template(profile_id, template_id)
    local template_prefix = profile_id .. "_template_" .. template_id;
    local template_flag_prefix = mod_flag_name .. "_" .. template_prefix;
    RemoveFlagPersistent(template_flag_prefix .. "_shuffle");
    clear_encode_integer(template_prefix .. "_spells_per_cast");
    clear_encode_integer(template_prefix .. "_cast_delay");
    clear_encode_integer(template_prefix .. "_recharge_time");
    clear_encode_integer(template_prefix .. "_mana_max");
    clear_encode_integer(template_prefix .. "_mana_charge_speed");
    clear_encode_integer(template_prefix .. "_capacity");
    clear_encode_integer(template_prefix .. "_spread");

    for scan_action_id, _ in pairs(actions_by_id) do
      RemoveFlagPersistent(template_flag_prefix .. "_always_cast_spell_" .. string.lower(scan_action_id));
    end

    for def_idx, _ in ipairs(default_wands) do
      RemoveFlagPersistent(template_flag_prefix .. "_wand_type_default_" .. def_idx);
    end
    for _, scan_wand in ipairs(wands) do
      RemoveFlagPersistent(template_flag_prefix .. "_wand_type_" .. string.lower(sprite_file_to_wand_type(scan_wand.file)));
    end

    RemoveFlagPersistent(template_flag_prefix);
  end

  local function _set_template(profile_id, template_id, wand_data)
    _delete_template(profile_id, template_id);
    if wand_data == nil then
      return;
    end
    local template_prefix = profile_id .. "_template_" .. template_id;
    local template_flag_prefix = mod_flag_name .. "_" .. template_prefix;
    if wand_data["shuffle"] then
      AddFlagPersistent(template_flag_prefix .. "_shuffle");
    end
    write_encode_integer(template_prefix .. "_spells_per_cast", wand_data["spells_per_cast"]);
    write_encode_integer(template_prefix .. "_cast_delay", wand_data["cast_delay"]);
    write_encode_integer(template_prefix .. "_recharge_time", wand_data["recharge_time"]);
    write_encode_integer(template_prefix .. "_mana_max", wand_data["mana_max"]);
    write_encode_integer(template_prefix .. "_mana_charge_speed", wand_data["mana_charge_speed"]);
    write_encode_integer(template_prefix .. "_capacity", wand_data["capacity"]);
    write_encode_integer(template_prefix .. "_spread", math.floor(wand_data["spread"] * 10 + 0.5));

    for _, spell in ipairs(wand_data["always_cast_spells"]) do
      AddFlagPersistent(template_flag_prefix .. "_always_cast_spell_" .. string.lower(spell));
    end

    AddFlagPersistent(template_flag_prefix .. "_wand_type_" .. string.lower(wand_data["wand_type"]));

    AddFlagPersistent(template_flag_prefix);
  end

  --- Check if and how a wand entity is new research for profile
  ---@param profile_id integer
  ---@param entity_id integer
  ---@return table research_flags {is_new, improves_spells_per_cast, improves_cast_delay_min, improves_cast_delay_max, improves_recharge_time_min, improves_recharge_time_max, improves_mana_max, improves_mana_charge_speed, improves_capacity, improves_spread_min, improves_spread_max, improves_always_cast_spells, improves_wand_types, count_new_always_cast_spells}
  ---@return table cost_data {_sum, wand_type, always_casts, always_cast_count, shuffle, spells_per_cast, cast_delay, recharge_time, mana_max, mana_charge_speed, capacity, spread }
  ---@return table wand_data wand data
  local function _get_wand_entity_research(profile_id, entity_id)
    local _research = { is_new = false,
                        b_new_is_only_type = false,
                        b_spells_per_cast = false,
                        b_cast_delay = false,
                        b_cast_delay_min = false,
                        b_cast_delay_max = false,
                        b_recharge_time = false,
                        b_recharge_time_min = false,
                        b_recharge_time_max = false,
                        b_mana_max = false,
                        b_mana_charge_speed = false,
                        b_capacity = false,
                        b_spread = false,
                        b_spread_min = false,
                        b_spread_max = false,
                        b_always_cast_spells = false,
                        i_always_cast_spells = 0,
                        b_spells = false,
                        i_spells = 0,
                        b_always_cast_count = false,
                        b_wand_types = false };
    local _cost = { wand_type           = 0,
                    always_cast_spells  = 0,
                    always_cast_count   = 0,
                    shuffle             = 0,
                    spells_per_cast     = 0,
                    cast_delay          = 0,
                    recharge_time       = 0,
                    mana_max            = 0,
                    mana_charge_speed   = 0,
                    capacity            = 0,
                    spread              = 0 };
    local _profile_known_spells = _get_profile_spells(profile_id);
    local _in_wand_data = {};

    if entity_id~=nil and entity_id~=0 then
      local _wand_bounds = _get_wand_bounds(profile_id);
      _in_wand_data = read_wand_entity(entity_id);

      if _in_wand_data["spells_per_cast"] > _wand_bounds.spells_per_cast[2] then
        _research.b_spells_per_cast = true;
        _research.is_new = true;
        _cost.spells_per_cast = math.ceil(__cost_func_spells_per_cast(_in_wand_data["spells_per_cast"]));
      end
      if _wand_bounds.cast_delay[1] == nil or _wand_bounds.cast_delay[2] == nil then
        b_cast_delay_min = _wand_bounds.cast_delay[1] == nil;
        b_cast_delay_max = _wand_bounds.cast_delay[2] == nil;
        _research.b_cast_delay = true;
        _research.b_cast_delay_min = true;
        _research.b_cast_delay_max = true;
        _research.is_new = true;
        _cost.cast_delay = math.ceil(__cost_func_cast_delay(_in_wand_data["cast_delay"]));
      else
        if _in_wand_data["cast_delay"] < _wand_bounds.cast_delay[1] then
          _research.b_cast_delay = true;
          _research.b_cast_delay_min = true;
          _research.is_new = true;
          _cost.cast_delay = math.ceil(__cost_func_cast_delay(_in_wand_data["cast_delay"]));
        elseif _in_wand_data["cast_delay"] > _wand_bounds.cast_delay[2] then
          _research.b_cast_delay = true;
          _research.b_cast_delay_max = true;
          _research.is_new = true;
          _cost.cast_delay = math.ceil(__cost_func_cast_delay(_in_wand_data["cast_delay"]));
        end
      end
      if _wand_bounds.recharge_time[1] == nil or _wand_bounds.recharge_time[2] == nil then
        b_recharge_time_min = _wand_bounds.recharge_time[1] == nil;
        b_recharge_time_max = _wand_bounds.recharge_time[2] == nil;
        _research.b_recharge_time = true;
        _research.b_recharge_time_min = true;
        _research.b_recharge_time_max = true;
        _research.is_new = true;
        _cost.recharge_time = math.ceil(__cost_func_recharge_time(_in_wand_data["recharge_time"]));
      else
        if _in_wand_data["recharge_time"] < _wand_bounds.recharge_time[1] then
          _research.b_recharge_time = true;
          _research.b_recharge_time_min = true;
          _research.is_new = true;
          _cost.recharge_time = math.ceil(__cost_func_recharge_time(_in_wand_data["recharge_time"]));
        end
        if _in_wand_data["recharge_time"] > _wand_bounds.recharge_time[2] then
          _research.b_recharge_time = true;
          _research.b_recharge_time_max = true;
          _research.is_new = true;
          _cost.recharge_time = math.ceil(__cost_func_recharge_time(_in_wand_data["recharge_time"]));
        end
      end
      if _in_wand_data["mana_max"] > _wand_bounds.mana_max[2] then
        _research.b_mana_max = true;
        _research.is_new = true;
        _cost.mana_max = math.ceil(__cost_func_mana_max(_in_wand_data["mana_max"]));
      end
      if _in_wand_data["mana_charge_speed"] > _wand_bounds.mana_charge_speed[2] then
        _research.b_mana_charge_speed = true;
        _research.is_new = true;
        _cost.mana_charge_speed = math.ceil(__cost_func_mana_charge_speed(_in_wand_data["mana_charge_speed"]));
      end
      if _in_wand_data["capacity"] > _wand_bounds.capacity[2] then
        _cost.capacity = math.ceil(__cost_func_capacity(_in_wand_data["capacity"]));
        _research.b_capacity = true;
        _research.is_new = true;
      end
      if _wand_bounds.spread[1] == nil or _wand_bounds.spread[2] == nil then
        b_spread_min = _wand_bounds.spread[1] == nil;
        b_spread_max = _wand_bounds.spread[2] == nil;
        _research.b_spread = true;
        _research.b_spread_min = true;
        _research.b_spread_max = true;
        _research.is_new = true;
        _cost.spread = math.ceil(__cost_func_spread(_in_wand_data["spread"]));
      else
        if _in_wand_data["spread"] < _wand_bounds.spread[1] then
          _research.b_spread = true;
          _research.b_spread_min = true;
          _research.is_new = true;
          _cost.spread = math.ceil(__cost_func_spread(_in_wand_data["spread"]));
        end
        if _in_wand_data["spread"] > _wand_bounds.spread[2] then
          _research.b_spread = true;
          _research.b_spread_max = true;
          _research.is_new = true;
          _cost.spread = math.ceil(__cost_func_spread(_in_wand_data["spread"]));
        end
      end

      if _in_wand_data["always_cast_spells"] ~= nil and #_in_wand_data["always_cast_spells"] > 0 then
        for _, _always_cast_id in pairs(_in_wand_data["always_cast_spells"]) do
          if actions_by_id[_always_cast_id] ~= nil and (_wand_bounds.always_casts == nil or _wand_bounds.always_casts[_always_cast_id] == nil) then
            _research.i_always_cast_spells = _research.i_always_cast_spells + 1;
            _research.b_always_cast_spells = true;
            _research.is_new = true;
            _cost.always_cast_spells = _cost.always_cast_spells + math.ceil(__cost_func_always_cast_spell(_always_cast_id));
          end
        end
        if #_in_wand_data["always_cast_spells"] > _wand_bounds.always_cast_count then
          _research.b_always_cast_count = true;
          _research.is_new = true;
          _cost.always_cast_count = math.ceil(__cost_func_always_cast_count(#_in_wand_data["always_cast_spells"]));
        end
      end

      if _in_wand_data["spells"] ~= nil and #_in_wand_data["spells"] > 0 then
        for _, _spell_id in pairs(_in_wand_data["spells"]) do
          if actions_by_id[_spell_id] ~= nil and (_profile_known_spells == nil or _profile_known_spells[_spell_id] ~= true) then
            _research.i_spells = _research.i_spells + 1;
            _research.b_spells = true;
          end
        end
      end

      if _wand_bounds.wand_types == nil or _wand_bounds.wand_types[_in_wand_data["wand_type"]] == nil then
        if wand_type_to_base_wand(_in_wand_data["wand_type"]) ~= nil then
          _research.b_new_is_only_type = not _research.is_new;
          _research.b_wand_types = true;
          _research.is_new = true;
          _cost.wand_type = math.ceil(__cost_func_wand_type(_in_wand_data["wand_type"]));
        end
      end
    end -- if entity_id~=nil|0

    local _sum = 0;
    for _member_name, _member_cost in pairs(_cost) do
      if _member_name=="always_cast_spells" then
        _sum = _sum + math.ceil(_member_cost * mod_setting.research_spell_price_multiplier);
      else
        _sum = _sum + math.ceil(_member_cost * mod_setting.research_wand_price_multiplier);
      end
    end
    _cost._sum = _sum;

    return _research, _cost, _in_wand_data;
  end

  local function _research_wand(profile_id, entity_id)
    local _research, _cost, _wand_data = _get_wand_entity_research(profile_id, entity_id);

    if get_player_money() < _cost._sum then
      return false;
    end

    if _research.b_spells_per_cast then                 _set_spells_per_cast(profile_id, _wand_data["spells_per_cast"]);                 end
    if _research.b_cast_delay_min then                  _set_cast_delay_min(profile_id, _wand_data["cast_delay"]);                       end
    if _research.b_cast_delay_max then                  _set_cast_delay_max(profile_id, _wand_data["cast_delay"]);                       end
    if _research.b_recharge_time_min then               _set_recharge_time_min(profile_id, _wand_data["recharge_time"]);                 end
    if _research.b_recharge_time_max then               _set_recharge_time_max(profile_id, _wand_data["recharge_time"]);                 end
    if _research.b_mana_max then                        _set_mana_max(profile_id, _wand_data["mana_max"]);                               end
    if _research.b_mana_charge_speed_max then           _set_mana_charge_speed(profile_id, _wand_data["mana_charge_speed"]);             end
    if _research.b_capacity then                        _set_capacity(profile_id, _wand_data["capacity"]);                               end
    if _research.b_spread_min then                      _set_spread_min(profile_id, _wand_data["spread"]);                               end
    if _research.b_spread_max then                      _set_spread_max(profile_id, _wand_data["spread"]);                               end
    if _research.b_always_cast_spells then              _add_always_cast_spells(profile_id, _wand_data["always_cast_spells"]);           end
    if _research.b_always_cast_count then               _set_always_cast_count(profile_id, #_wand_data["always_cast_spells"]);           end
    if _research.b_wand_types then                      _add_wand_types(profile_id, { _wand_data["wand_type"] });                        end

    delete_wand_entity(entity_id);
    decrement_player_money(_cost._sum);
    return true;
  end

  local function _research_spell_entity(profile_id, entity_id)
    local price = get_spell_entity_research_price(entity_id);
    if (price == nil) or (get_player_money() < price) then
      return false;
    end

    _add_spells(profile_id, { get_spell_entity_action_id(entity_id) });

    delete_spell_entity(entity_id);
    decrement_player_money(price);
    return true;
  end

  ---- ===========================
  ---- PRIVATE TO PUBLIC PROMOTION
  ---- ===========================

  function get_stash_money() return _get_stash_money(loaded_profile_id); end
  function set_stash_money(value) return _set_stash_money(loaded_profile_id, value); end
  ---increments stash money, returns success
  ---@param amount integer money
  ---@return boolean success
  function increment_stash_money(amount) return _increment_stash_money(loaded_profile_id, amount); end
  ---increments stash money, returns success
  ---@param amount integer money
  ---@return boolean success
  function decrement_stash_money(amount) return _decrement_stash_money(loaded_profile_id, amount); end
  function transfer_money_player_to_stash(value) return _transfer_money_player_to_stash(loaded_profile_id, value); end
  function transfer_money_stash_to_player(value) return _transfer_money_stash_to_player(loaded_profile_id, value); end
  function get_profile_spells() return _get_profile_spells(loaded_profile_id); end
  function research_spell_entity(entity_id) return _research_spell_entity(loaded_profile_id, entity_id); end
  function research_wand(entity_id) return _research_wand(loaded_profile_id, entity_id); end
  function get_templates() return _get_templates(loaded_profile_id); end
  function get_template(template_id) return _get_template(loaded_profile_id, template_id); end
  function load_template(template_id) return _get_template(loaded_profile_id, template_id); end
  function set_template(template_id, wand_data) _set_template(loaded_profile_id, template_id, wand_data); end
  function delete_template(template_id) _delete_template(loaded_profile_id, template_id); end
  function get_always_cast_spells() return _get_always_cast_spells(loaded_profile_id); end
  function get_always_cast_count() return _get_always_cast_count(loaded_profile_id); end
  function get_wand_bounds() return _get_wand_bounds(loaded_profile_id); end
  function get_wand_entity_research(entity_id) return _get_wand_entity_research(loaded_profile_id, entity_id); end

  ---- ================
  ---- PUBLIC FUNCTIONS
  ---- ================

  function does_profile_know_spell(action_id) return data_store[loaded_profile_id]["spells"][action_id] or false; end

  function get_modify_wand_table(entity_id)
    local _members = {"spells_per_cast", "cast_delay", "recharge_time", "mana_max", "mana_charge_speed", "spread", "capacity"};

    local _template = get_template(1);
    local _table = { origin_entity = entity_id, bounds = get_wand_bounds() };
    if _template.capacity~=nil and (entity_id==nil or entity_id==0) then
      _table.wand = {};
      for _member, _data in pairs(_template) do
        _table.wand[_member] = _data;
      end
    else
      _table.wand = read_wand_entity(entity_id);
      _table.price = get_wand_buy_price(_table.wand);
      _table.origin_e_id = entity_id;
    end
    if _table.wand.wand_type==-1 then
      _table.wand.wand_type = data_store[loaded_profile_id]["wand_types_idx"][1];
      _table.wand.sprite = wand_type_to_sprite_file(_table.wand.wand_type);
      _table.wand.shuffle = false;
      for _, _member in ipairs(_members) do
        _table.wand[_member] = math.floor( (_table.bounds[_member][1] + _table.bounds[_member][2]) / 2 );
      end
    end
    _table.ac_limit = _table.bounds.always_cast_count;
    _table.ac_spells = get_always_cast_spell_purchase_table();
    return _table;
  end

  -- PROFILES

  ---erase profile slot and write new, clear in-memory datastore for profile, tag profile as selected
  ---@param profile_id integer
  function create_new_profile(profile_id, _force)
    _force = _force==true or false;
    if data_store[profile_id]~=nil and data_store[profile_id].quickloaded==true and not _force then return; end

    delete_profile(profile_id);
    load_profile(profile_id);
    AddFlagPersistent(mod_flag_name .. "_" .. profile_id);
    selected_profile_id=profile_id;
  end

  ---erase profile slot and mark empty, clear in-memory datastore for profile
  ---@param profile_id integer
  function delete_profile(profile_id)
    clear_encode_integer(profile_id .. "_spells_per_cast");
    clear_encode_integer(profile_id .. "_cast_delay_min");
    clear_encode_integer(profile_id .. "_cast_delay_max");
    clear_encode_integer(profile_id .. "_recharge_time_min");
    clear_encode_integer(profile_id .. "_recharge_time_max");
    clear_encode_integer(profile_id .. "_mana_max");
    clear_encode_integer(profile_id .. "_capacity");
    clear_encode_integer(profile_id .. "_always_cast_count");
    clear_encode_integer(profile_id .. "_spread_min");
    clear_encode_integer(profile_id .. "_spread_max");
    clear_encode_integer(profile_id .. "_money");
    clear_encode_integer(profile_id .. "_always_cast_spells_known");
    clear_encode_integer(profile_id .. "_spells_known");
    clear_encode_integer(profile_id .. "_wand_types_known");
    for _, curr_action in ipairs(actions_by_id) do
        RemoveFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_spell_" .. string.lower(curr_action.id));
      RemoveFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_always_cast_spell_" .. string.lower(curr_action.id));
    end
    for _, curr_wand in ipairs(wands) do
      RemoveFlagPersistent(mod_flag_name .. "_" .. profile_id .. "_wand_type_" .. sprite_file_to_wand_type(curr_wand.file));
    end

    for i = 1, get_template_count() do
      _delete_template(profile_id, i);
    end

    RemoveFlagPersistent(mod_flag_name .. "_" .. profile_id); -- remove profile exists tag
    data_store[profile_id] = nil;
  end

  ---return byval copy of datastore for quickloaded profiles
  ---@return table {quickloaded, money, always_cast_spells_known, wand_types_known}
  function get_quick_profiles()
    clean_store = {};
    for profile_id = 1, get_profile_count() do
      clean_store[profile_id] = {};
      if data_store[profile_id]~=nil and data_store[profile_id]["quickloaded"]==true then
        clean_store[profile_id]["quickloaded"] = data_store[profile_id]["quickloaded"];
        clean_store[profile_id]["money"] = data_store[profile_id]["money"];
        clean_store[profile_id]["always_cast_spells_known"] = data_store[profile_id]["always_cast_spells_known"];
        clean_store[profile_id]["spells_known"] = data_store[profile_id]["spells_known"];
        clean_store[profile_id]["wand_types_known"] = data_store[profile_id]["wand_types_known"];
      else
        clean_store[profile_id]["quickloaded"] = nil;
      end
    end
    return clean_store;
  end

  ---load profile_id from disk to data_store
  ---@param profile_id number
  function load_profile(profile_id)
    for to_clear = 1, get_profile_count() do
      data_store[to_clear] = {}
    end

    _load_profile_quick(profile_id);

    data_store[profile_id]["spells_per_cast"] = load_decode_integer(profile_id .. "_spells_per_cast");
    data_store[profile_id]["cast_delay_min"] = load_decode_integer(profile_id .. "_cast_delay_min");
    data_store[profile_id]["cast_delay_max"] = load_decode_integer(profile_id .. "_cast_delay_max");
    data_store[profile_id]["recharge_time_min"] = load_decode_integer(profile_id .. "_recharge_time_min");
    data_store[profile_id]["recharge_time_max"] = load_decode_integer(profile_id .. "_recharge_time_max");
    data_store[profile_id]["mana_max"] = load_decode_integer(profile_id .. "_mana_max");
    data_store[profile_id]["mana_charge_speed"] = load_decode_integer(profile_id .. "_mana_charge_speed");
    data_store[profile_id]["always_cast_count"] = load_decode_integer(profile_id .. "_always_cast_count");
    data_store[profile_id]["capacity"] = load_decode_integer(profile_id .. "_capacity");
    local spread_min = load_decode_integer(profile_id .. "_spread_min");
    if spread_min ~= nil then
      spread_min = spread_min / 10;
    end
    data_store[profile_id]["spread_min"] = spread_min;
    local spread_max = load_decode_integer(profile_id .. "_spread_max");
    if spread_max ~= nil then
      spread_max = spread_max / 10;
    end
    data_store[profile_id]["spread_max"] = spread_max;


    _load_profile_spells(profile_id);
    _load_wand_types(profile_id);

    data_store[profile_id]["loaded"] = true;

    print("=========================");
    print("persistence: Loaded profile " .. profile_id);
    print("money: " .. data_store[profile_id]["money"]);
    print("always_cast_spells_known: " .. data_store[profile_id]["always_cast_spells_known"]);
    print("spells_known: " .. data_store[profile_id]["spells_known"]);
    print("wand_types_known: " .. data_store[profile_id]["wand_types_known"]);
    loaded_profile_id = profile_id;
    GlobalsSetValue("persistence_profile", tostring(profile_id));
  end

  function data_store_everyframe()
    if selected_profile_id>0 and loaded_profile_id~=selected_profile_id then load_profile(selected_profile_id); end

    if loaded_profile_id==0 then return; end

    local _game_frame = GameGetFrameNum();

    if _game_frame%120 then
      _do_startup_paycheck_check();
    end

    if _game_frame%10==0 and _in_workshop then
      _do_holy_mountain_paycheck_check();
    end
  end
  ---end function declarations, run code here;

  for profile_idx = 1, get_profile_count() do
    data_store[profile_idx]=data_store[profile_idx] or {};
    if HasFlagPersistent(mod_flag_name .. "_" .. profile_idx) then
      _load_profile_quick(profile_idx)
    end
  end

  if GlobalsGetValue("persistence_profile", "0")~="0" then
    selected_profile_id = tonumber(GlobalsGetValue("persistence_profile", "0"));
  elseif default_profile_id>0 then
    selected_profile_id = default_profile_id;
  end

  print("=========================");
  print("persistence: Datastore loaded.");
  persistence_data_store_loaded = true;
end -- if persistence_data_store_loaded==false;


-- every frame: