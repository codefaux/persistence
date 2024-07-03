if persistence_helper_loaded~=true then
  dofile_once("data/scripts/gun/procedural/gun_procedural.lua");
  dofile_once("data/scripts/gun/procedural/gun_action_utils.lua");
  dofile_once("data/scripts/gun/procedural/wands.lua");

  default_wands = {
    { name = "Handgun",     file = "data/items_gfx/handgun.png",     grip_x = 4,     grip_y = 4,     tip_x = 12,     tip_y = 4   },
    { name = "Bomb wand",   file = "data/items_gfx/bomb_wand.png",   grip_x = 4,     grip_y = 4,     tip_x = 12,     tip_y = 4   }};

  function sprite_file_to_wand_type(sprite_file)
    ---TODO: Debug this and see what actually happens here, intent: remove dependence on default_wands
    for def_idx, _ in ipairs(default_wands) do
      if default_wands[def_idx].file == sprite_file then
        return "default_" .. def_idx;
      end
    end
    return string.sub(sprite_file, string.find(sprite_file, "/[^/]*$") + 1, -5);
  end

  function load_wands_by_type()
    local out_table = {};
    out_table.default_1 = default_wands[1];
    out_table.default_2 = default_wands[2];
    for _, wand_entry in ipairs(wands) do
      out_table[sprite_file_to_wand_type(wand_entry.file)] = wand_entry;
    end
    return out_table;
  end

  function cast_time_to_time(value)
    return math.floor((value / 60) * 100 + 0.5) / 100;
  end

  function wand_type_to_sprite_file(wand_type)
    ---TODO: Debug this and see what actually happens here, intent: remove dependence on default_wands
    if string.sub(wand_type, 1, #"default") == "default" then
      local nr = tonumber(string.sub(wand_type, #"default" + 2));
      return default_wands[nr].file;
    else
      if string.match(wand_type, "wand_%d%d%d%d") then
        return "data/items_gfx/wands/" .. wand_type .. ".png";
      else
        return "data/items_gfx/" .. wand_type .. ".png";
      end
    end
  end

  function wand_type_to_base_wand(wand_type)
    ---TODO: Debug this and see what actually happens here, intent: remove dependence on default_wands
    if string.sub(wand_type, 1, #"default") == "default" then
      local nr = tonumber(string.sub(wand_type, #"default" + 2));
      return default_wands[nr];
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

  function read_wand_entity(entity_id)
    local wand_data = {};

    local comp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent");

    if comp == nil then
      return {
        shuffle = false,
        spells_per_cast = -1,
        cast_delay = -1,
        recharge_time = -1,
        mana_max = -1,
        mana_charge_speed = -1,
        spread = -1,
        sprite = -1,
        wand_type = -1,
        capacity = 1,
        spells = {},
        always_cast_spells = {},
      };
    else
      wand_data["shuffle"] = ComponentObjectGetValue2(comp, "gun_config", "shuffle_deck_when_empty") == 1 and true or false;
      wand_data["spells_per_cast"] = ComponentObjectGetValue2(comp, "gun_config", "actions_per_round");
      wand_data["cast_delay"] = ComponentObjectGetValue2(comp, "gunaction_config", "fire_rate_wait");
      wand_data["recharge_time"] = ComponentObjectGetValue2(comp, "gun_config", "reload_time");
      wand_data["mana_max"] = ComponentGetValue2(comp, "mana_max");
      wand_data["mana_charge_speed"] = ComponentGetValue2(comp, "mana_charge_speed");
      wand_data["capacity"] = ComponentObjectGetValue2(comp, "gun_config", "deck_capacity");
      wand_data["spread"] = ComponentObjectGetValue2(comp, "gunaction_config", "spread_degrees");
      wand_data["sprite"] = string.gsub(ComponentGetValue2(comp, "sprite_file"), "%.xml$", ".png");
      wand_data["wand_type"] = sprite_file_to_wand_type(ComponentGetValue2(comp, "sprite_file"));
      wand_data["spells"] = {};
      wand_data["always_cast_spells"] = {};
      local childs = EntityGetAllChildren(entity_id);
      if childs ~= nil then
        for _, child_id in ipairs(childs) do
          local item_action_comp = EntityGetFirstComponentIncludingDisabled(child_id, "ItemActionComponent");
          if item_action_comp ~= nil and item_action_comp ~= 0 then
            local action_id = ComponentGetValue2(item_action_comp, "action_id");
            if ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(child_id, "ItemComponent") or 0, "permanently_attached") == true then
              table.insert(wand_data["always_cast_spells"], action_id);
            else
              table.insert(wand_data["spells"], action_id);
            end
          end
        end
      end
      wand_data["capacity"] = wand_data["capacity"] - #wand_data["always_cast_spells"];
      end
  return wand_data;
  end

  function get_spell_entity_action_id(entity_id)
    return ComponentGetValue2( EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent") or 0, "action_id");
  end

  function delete_wand_entity(entity_id)
    if not EntityHasTag(entity_id, "wand") then return; end
    EntityKill(entity_id);
  end

  function delete_spell_entity(entity_id)
    if not EntityHasTag(entity_id, "card_action") then return; end
    EntityKill(entity_id);
  end

  function cost_func_wand_type(_) return 200; end
  function cost_func_shuffle(_shuffle) return _shuffle and 0 or 100; end
  function cost_func_spells_per_cast(a_p_c) return math.max(a_p_c-1,0)*500; end
  function cost_func_cast_delay(_castdelay) return (0.01 ^ ((_castdelay/60) - 1.8) + 200) * 0.1; end
  function cost_func_recharge_time(_rechargetime) return (0.01 ^ ((_rechargetime/60) - 1.8) + 200) * 0.1; end
  function cost_func_mana_max(_manamax) return _manamax; end
  function cost_func_mana_charge_speed(_manachargespeed) return _manachargespeed * 2; end
  function cost_func_capacity(_capacity) return (math.max(_capacity - 1, 0)) * 50; end
  function cost_func_spread(_spread) return math.abs(10 - _spread) * 5; end
  function cost_func_always_cast_spells(_alwayscasts) local _val = 0; for _, _a_c_id in ipairs(_alwayscasts) do if (_a_c_id~=nil and actions_by_id[_a_c_id]~=nil and actions_by_id[_a_c_id].price~=nil) then _val = _val + get_ac_cost(_a_c_id); end; end; return _val; end




  function get_wand_price(wand_data)
    local price = 0;
    price = price + math.ceil(cost_func_wand_type(wand_data["wand_type"]));
    price = price + math.ceil(cost_func_shuffle(wand_data["shuffle"]));
    price = price + math.ceil(cost_func_spells_per_cast(wand_data["spells_per_cast"]));
    price = price + math.ceil(cost_func_cast_delay(wand_data["cast_delay"]));
    price = price + math.ceil(cost_func_recharge_time(wand_data["recharge_time"]));
    price = price + math.ceil(cost_func_mana_max(wand_data["mana_max"]));
    price = price + math.ceil(cost_func_mana_charge_speed(wand_data["mana_charge_speed"]));
    price = price + math.ceil(cost_func_capacity(wand_data["capacity"]));
    price = price + math.ceil(cost_func_spread(wand_data["spread"]));

    price = math.ceil(price * mod_setting.buy_wand_price_multiplier);

    price = price + cost_func_always_cast_spells(wand_data["always_cast_spells"]);

    return math.ceil(price);
  end

  function modify_wand_entity(slot_data)
    local _var_comp = EntityGetFirstComponentIncludingDisabled(slot_data.origin_e_id, "VariableStorageComponent", "persistence_wand_price") or 0;
    local _origin_price = ComponentGetValue2(_var_comp, "value_int") or 0;

    local _price = slot_data.price - _origin_price;
    if get_player_money() < _price then return false; end

    local ability_comp = EntityGetFirstComponentIncludingDisabled(slot_data.origin_e_id, "AbilityComponent") or 0;
    local basewand = wand_type_to_base_wand(slot_data.wand["wand_type"]);

    if basewand==nil then return false; end

    ComponentSetValue2(ability_comp, "ui_name", basewand.name);
    ComponentObjectSetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty", slot_data.wand["shuffle"] and true or false);
    ComponentObjectSetValue2(ability_comp, "gun_config", "actions_per_round", slot_data.wand["spells_per_cast"]);
    ComponentObjectSetValue2(ability_comp, "gunaction_config", "fire_rate_wait", slot_data.wand["cast_delay"]);
    ComponentObjectSetValue2(ability_comp, "gun_config", "reload_time", slot_data.wand["recharge_time"]);
    ComponentSetValue2(ability_comp, "mana_max", slot_data.wand["mana_max"]);
    ComponentSetValue2(ability_comp, "mana", slot_data.wand["mana_max"]);
    ComponentSetValue2(ability_comp, "mana_charge_speed", slot_data.wand["mana_charge_speed"]);
    ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", slot_data.wand["capacity"]);
    ComponentObjectSetValue2(ability_comp, "gunaction_config", "spread_degrees", slot_data.wand["spread"]);
    ComponentObjectSetValue2(ability_comp, "gunaction_config", "speed_multiplier", 1);
    ComponentSetValue2(ability_comp, "item_recoil_recovery_speed", 15);


    local childs = EntityGetAllChildren(slot_data.origin_e_id);
    if childs ~= nil then
      for _, child_id in ipairs(childs) do
        local item_action_comp = EntityGetFirstComponentIncludingDisabled(child_id, "ItemActionComponent");
        if item_action_comp ~= nil and item_action_comp ~= 0 then
          local action_id = ComponentGetValue2(item_action_comp, "action_id");
          if ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(child_id, "ItemComponent") or 0, "permanently_attached") == true then
            EntityKill(child_id);
          end
        end
      end
    end

    if #slot_data.wand["always_cast_spells"] > 0 then
      for _, curr_a_c_action_id in ipairs(slot_data.wand["always_cast_spells"]) do
        AddGunActionPermanent(slot_data.origin_e_id, curr_a_c_action_id);
      end
    end
    SetWandSprite(slot_data.origin_e_id, ability_comp, basewand.file, basewand.grip_x, basewand.grip_y, (basewand.tip_x - basewand.grip_x), (basewand.tip_y - basewand.grip_y));

    set_player_money(get_player_money() - _price);
  end

  function purchase_wand(wand_data)
    local _price = wand_data.price;
    if get_player_money() < _price then return false; end

    local x, y = EntityGetTransform(player_e_id);
    local _new_wand_e_id = EntityLoad(mod_dir .. "files/entity/wand_empty.xml", x, y);

    if _new_wand_e_id==nil or _new_wand_e_id==0 then return false; end
    EntityAddTag(_new_wand_e_id, "persistence");
    local _wand_var_c_id = EntityAddComponent(_new_wand_e_id, "VariableStorageComponent", {name = "persistence_wand_price", value_int=_price});
    ComponentAddTag(_wand_var_c_id, "persistence_wand_price");

    local ability_comp = EntityGetFirstComponentIncludingDisabled(_new_wand_e_id, "AbilityComponent") or 0;
    local wand = wand_type_to_base_wand(wand_data["wand_type"]);

    if wand==nil then return false; end

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
      for _, curr_a_c_action_id in ipairs(wand_data["always_cast_spells"]) do
        AddGunActionPermanent(_new_wand_e_id, curr_a_c_action_id);
      end
    end
    SetWandSprite(_new_wand_e_id, ability_comp, wand.file, wand.grip_x, wand.grip_y, (wand.tip_x - wand.grip_x), (wand.tip_y - wand.grip_y));

    -- UnlockPlayer();
    -- GamePickUpInventoryItem(player_e_id, _new_wand_e_id, true);
    -- LockPlayer();

    set_player_money(get_player_money() - _price);
    return true;
  end

  function get_spell_purchase_price(action_id)
    return math.ceil(actions_by_id[action_id].price * mod_setting.buy_spell_price_multiplier);
  end

  function purchase_spell(action_id)
    local price = get_spell_purchase_price(action_id);
    if get_player_money() < price then return false; end

    local x, y = EntityGetTransform(player_e_id);
    local _spell_e_id = CreateItemActionEntity(action_id, x, y);
    if _spell_e_id~=0 then
      local _inv_full_e_id = EntityGetWithName("inventory_full");
      EntitySetComponentsWithTagEnabled(_spell_e_id, "enabled_in_world", false);
      EntityAddChild(_inv_full_e_id, _spell_e_id);
      set_player_money(get_player_money() - price);
    end
    return true;
  end

  function get_player_wands()
    local wands = {};
    for ii = 1, 4 do
      wands[ii] = {};
    end
    local inv_quick;
    local inventory_quick_childs;

    while inventory_quick_childs==nil or #inventory_quick_childs<1 do
      if inv_quick~=0 then EntityKill(inv_quick); end
      inv_quick=EntityGetWithName("inventory_quick");
      if inv_quick==nil or inv_quick==0 then return {}; end
      inventory_quick_childs = EntityGetAllChildren(inv_quick);
    end

    if inventory_quick_childs ~=nil then
      for _, item in ipairs(inventory_quick_childs) do
        if EntityHasTag(item, "wand") then
          local inventory_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent") or 0;
          local inv_slot = ComponentGetValue2(inventory_comp, "inventory_slot") + 1;
          wands[inv_slot] = {};
          wands[inv_slot].e_id = item;
          wands[inv_slot].wand = read_wand_entity(item);
          wands[inv_slot].research = research_wand_is_new(item);
          wands[inv_slot].price = get_wand_price(wands[inv_slot].wand);
        end
      end
    end

    return wands;
  end

  function get_player_inv_spell_entities()
    local _spell_entities = {};
    if EntityGetWithName("inventory_full") == nil then return {}; end
    local _inventory_full_children = EntityGetAllChildren(EntityGetWithName("inventory_full"));
    if _inventory_full_children ~=nil then
      for _, _inventory_entity in ipairs(_inventory_full_children) do
        if EntityHasTag(_inventory_entity, "card_action") then
          table.insert(_spell_entities, _inventory_entity);
        end
      end
    end
    return _spell_entities;
  end

  function get_spell_entity_current_uses(entity_id)
    local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent");
    if item_comp ~= nil then
      local _uses_now = ComponentGetValue2(item_comp, "uses_remaining");
      return _uses_now;
    end
  end


  function get_spell_inv_research_table()
    local _spells = {};
    local _type_hash = {};
    local _carrying_e_ids = get_player_inv_spell_entities();
    local _known = get_profile_spells();
    local _researchable_hash = {}
    local _spell_idx = 0;

    _type_hash[99] = true; -- "all"
    for _, _e_id in ipairs(_carrying_e_ids) do
      local _a_id = get_spell_entity_action_id(_e_id);
      _spell_idx = _spell_idx + 1;
      local _uses_max = actions_by_id[_a_id].max_uses;
      local _uses_now = get_spell_entity_current_uses(_e_id);

      _spells[_spell_idx] = {};
      _spells[_spell_idx].e_id = _e_id;
      _spells[_spell_idx].a_id = _a_id;
      _spells[_spell_idx].name = actions_by_id[_a_id].name;
      _spells[_spell_idx].description = actions_by_id[_a_id].description;
      _spells[_spell_idx].cost = actions_by_id[_a_id].cost;
      _spells[_spell_idx].type = actions_by_id[_a_id].type;
      _spells[_spell_idx].type_sprite = action_type_to_slot_sprite(actions_by_id[_a_id].type);
      _spells[_spell_idx].sprite = actions_by_id[_a_id].sprite;
      _spells[_spell_idx].price = actions_by_id[_a_id].price;
      _spells[_spell_idx].max_uses = _uses_max;
      _spells[_spell_idx].curr_uses = _uses_now;

      _type_hash[actions_by_id[_a_id].type] = true;

      local _research_eligible = true;

      if _uses_max~=nil and _uses_max>0 and _uses_now~=nil and _uses_now~=_uses_max and _uses_now~=-1 then
        _research_eligible = false;
      end
      -- TODO: Other disqualifying factors?

      _spells[_spell_idx].known = _known[_a_id];

      if not _known[_a_id] then
        if _researchable_hash[_a_id]==nil then
          _spells[_spell_idx].researchable = _research_eligible;
          _spells[_spell_idx].recyclable = not _research_eligible;
          if _research_eligible then _researchable_hash[_a_id]=true; end
        else
          _spells[_spell_idx].researchable = false;
          _spells[_spell_idx].recyclable = false;
        end
      else
        _spells[_spell_idx].researchable = false;
        _spells[_spell_idx].recyclable = true;
      end
    end
    _spells["_index"] = {};
    _spells["_index"].count = _spell_idx;
    _spells["_index"].type_hash = _type_hash;
    return _spells;
  end

  function get_spell_purchase_single(action_id)
    local _spell = {};
    _spell.a_id = action_id;
    _spell.name = actions_by_id[action_id].name;
    _spell.description = actions_by_id[action_id].description;
    _spell.cost = actions_by_id[action_id].cost;
    _spell.type = actions_by_id[action_id].type;
    _spell.type_sprite = action_type_to_slot_sprite(actions_by_id[action_id].type);
    _spell.sprite = actions_by_id[action_id].sprite;
    _spell.price = actions_by_id[action_id].price;
    _spell.max_uses = actions_by_id[action_id].max_uses;
    return _spell;
  end

  function get_spell_purchase_table()
    local _spells = {};
    local _type_hash = {};
    local _known = get_profile_spells();
    local _spell_idx = 0;

    _type_hash[99] = true; -- "all"
    for _a_id, _ in pairs(_known) do
      _spell_idx = _spell_idx + 1;
      _spells[_spell_idx] = {};
      _spells[_spell_idx] = get_spell_purchase_single(_a_id);
      _type_hash[actions_by_id[_a_id].type] = true;
    end
    _spells["_index"] = {};
    _spells["_index"].count = _spell_idx;
    _spells["_index"].type_hash = _type_hash;
    return _spells;
  end

  function get_always_cast_spell_purchase_table()
    local _ac_spells = {};
    local _ac_type_hash = {};
    local _ac_known = get_always_cast_spells();
    local _ac_spell_idx = 0;

    _ac_type_hash[99] = true; -- "all"
    for _a_id, _ in pairs(_ac_known) do
      _ac_spell_idx = _ac_spell_idx + 1;
      _ac_spells[_ac_spell_idx] = {};
      _ac_spells[_ac_spell_idx] = get_spell_purchase_single(_a_id);
      _ac_type_hash[actions_by_id[_a_id].type] = true;
    end
    _ac_spells["_index"] = {};
    _ac_spells["_index"].count = _ac_spell_idx;
    _ac_spells["_index"].type_hash = _ac_type_hash;
    return _ac_spells;
  end

  function get_world_state_entity_id()
    return EntityGetWithTag("world_state")[1];
  end

  function get_player_stats_component()
    for _, w_s_child_id in ipairs(EntityGetAllChildren(get_world_state_entity_id()) or {}) do
      if w_s_child_id~=0 then return EntityGetFirstComponentIncludingDisabled(w_s_child_id, "PlayerStatsComponent"); end
    end
  end

  function get_player_gamestats_component()
    return EntityGetFirstComponentIncludingDisabled(player_e_id, "GameStatsComponent");
  end

  function get_inventory_gui()
    return EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent");
  end

  function get_inventory2()
    return EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component");
  end

  function get_controls_component()
    return EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent");
  end

  function simple_string_hash(text) --don't use it for storing passwords...
    local sum = 0;
    for i = 1, #text do
      sum = sum + string.byte(text, i) * i * 2999;
    end
    return sum;
  end

  function get_player_money()
    return ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent") or 0, "money") or -1;
  end

  function set_player_money(value)
    ComponentSetValue2(EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent") or 0, "money", value);
  end

  function get_root_entity(entity_id)
    local _tmp_e_id = entity_id;
    local _prev_e_id = entity_id;
    while _tmp_e_id~=0 and _tmp_e_id~=nil do
      _prev_e_id = _tmp_e_id;
      _tmp_e_id = EntityGetParent(_tmp_e_id);
    end
    return _prev_e_id;
  end

  function check_search_for(spell_object, search_string)
    if spell_object==nil or spell_object.description==nil or spell_object.name==nil then return false; end

    local _show_item = true;
      for _search_word in string.gmatch(search_string,'([^, ]+)') do
      if string.sub(_search_word, 1, 1)=="#" then
        local _search_sub = string.sub(_search_word, 2, -1);
        if string.find(string.lower(GameTextGetTranslatedOrNot(spell_object.description)), string.lower(_search_sub), 1, true)==nil then _show_item = false; end
      else
        if string.find(string.lower(GameTextGetTranslatedOrNot(spell_object.name)),        string.lower(_search_word), 1, true)==nil then _show_item = false; end
      end
    end
    return _show_item;
  end
  ---end function declarations, run code here;


  wands_by_type = load_wands_by_type();

  print("=========================");
  print("persistence: Helper loaded.");
  persistence_helper_loaded=true;
end

