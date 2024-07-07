

function __cost_func_wand_type(_)
  return 200;
end

function __cost_func_shuffle(_shuffle)
  return _shuffle and 0 or 100;
end

function __cost_func_spells_per_cast(a_p_c)
  return math.ceil(math.max(a_p_c-1,0)*500);
end

function __cost_func_cast_delay(_castdelay)
  return math.ceil((0.01 ^ ((_castdelay/60) - 1.8) + 200) * 0.1);
end

function __cost_func_recharge_time(_rechargetime)
  return math.ceil((0.01 ^ ((_rechargetime/60) - 1.8) + 200) * 0.1);
end

function __cost_func_mana_max(_manamax)
  return math.ceil(_manamax);
end

function __cost_func_mana_charge_speed(_manachargespeed)
  return math.ceil(_manachargespeed * 2);
end

function __cost_func_capacity(_capacity)
  return math.ceil((math.max(_capacity - 1, 0)) * 50);
end

function __cost_func_spread(_spread)
  return math.ceil(math.abs(10 - _spread) * 5);
end

function __cost_func_always_cast_spells(_alwayscasts)
  local _val = 0; for _, _a_c_id in ipairs(_alwayscasts) do if (_a_c_id~=nil and actions_by_id[_a_c_id]~=nil and actions_by_id[_a_c_id].price~=nil) then _val = _val + __get_ac_raw_cost(_a_c_id); end; end; return math.ceil(_val);
end

function __cost_func_always_cast_spell(_alwayscast)
  return math.ceil(__get_ac_raw_cost(_alwayscast));
end

function __cost_func_always_cast_count(_alwayscasts)
  return math.ceil((_alwayscasts ^ 2) * 100);
end

function __get_ac_raw_cost(_a_c_id)
  if _a_c_id==nil then return 0; end
  return math.ceil(actions_by_id[_a_c_id].price * 5);
end

function fill_wand_stat_cost(wand_data)
  wand_data.cost                    = {};
  wand_data.cost.wand_type          = math.ceil(__cost_func_wand_type(wand_data["wand_type"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.shuffle            = math.ceil(__cost_func_shuffle(wand_data["shuffle"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.spells_per_cast    = math.ceil(__cost_func_spells_per_cast(wand_data["spells_per_cast"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.cast_delay         = math.ceil(__cost_func_cast_delay(wand_data["cast_delay"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.recharge_time      = math.ceil(__cost_func_recharge_time(wand_data["recharge_time"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.mana_max           = math.ceil(__cost_func_mana_max(wand_data["mana_max"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.mana_charge_speed  = math.ceil(__cost_func_mana_charge_speed(wand_data["mana_charge_speed"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.capacity           = math.ceil(__cost_func_capacity(wand_data["capacity"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.spread             = math.ceil(__cost_func_spread(wand_data["spread"]) * mod_setting.buy_wand_price_multiplier);
  wand_data.cost.always_cast_count  = math.ceil(__cost_func_always_cast_count(wand_data["always_cast_count"]) * mod_setting.buy_wand_price_multiplier);
  local _sum = 0;
  for _, _cost in pairs(wand_data["cost"]) do
    _sum = _sum + _cost;
  end
  wand_data.cost.stat_sum = _sum;
end

function get_wand_buy_price(wand_data)
  local price = 0;
  fill_wand_stat_cost(wand_data);
  price = wand_data.cost.stat_sum;
  price = price + math.ceil(__cost_func_always_cast_spells(wand_data["always_cast_spells"]) * mod_setting.buy_spell_price_multiplier);

  return math.ceil(price);
end

function get_spell_purchase_price(action_id)
  if action_id==nil or type(action_id)~="string" then return nil; end

  return math.ceil(actions_by_id[action_id].price * mod_setting.buy_spell_price_multiplier);
end

function get_spell_research_price(action_id)
  if action_id==nil or type(action_id)~="string" then return nil; end

  return math.ceil(actions_by_id[action_id].price * mod_setting.research_spell_price_multiplier);
end

function get_spell_entity_research_price(entity_id)
  local action_id = get_spell_entity_action_id(entity_id);
  if action_id == nil then
    return nil;
  end
  return get_spell_research_price(action_id);
end
