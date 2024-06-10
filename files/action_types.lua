ACTION_TYPE_PROJECTILE = 0;
ACTION_TYPE_STATIC_PROJECTILE = 1;
ACTION_TYPE_MODIFIER = 2;
ACTION_TYPE_DRAW_MANY = 3;
ACTION_TYPE_MATERIAL = 4;
ACTION_TYPE_OTHER = 5;
ACTION_TYPE_UTILITY = 6;
ACTION_TYPE_PASSIVE = 7;

function action_type_to_string(action_type)
  if action_type == ACTION_TYPE_PROJECTILE then
    return "$inventory_actiontype_projectile";
  end
  if action_type == ACTION_TYPE_STATIC_PROJECTILE then
    return "$inventory_actiontype_staticprojectile";
  end
  if action_type == ACTION_TYPE_MODIFIER then
    return "$inventory_actiontype_modifier";
  end
	if action_type == ACTION_TYPE_DRAW_MANY then
    return "$inventory_actiontype_drawmany";
  end
	if action_type == ACTION_TYPE_MATERIAL then
    return "$inventory_actiontype_material";
  end
	if action_type == ACTION_TYPE_OTHER then
    return "$inventory_actiontype_other";
  end
	if action_type == ACTION_TYPE_UTILITY then
    return "$inventory_actiontype_utility";
  end
  if action_type == ACTION_TYPE_PASSIVE then
    return "$inventory_actiontype_passive";
  end
  return "";
end

function action_type_to_slot_sprite(action_type)
	if action_type == ACTION_TYPE_DRAW_MANY then
    return "data/ui_gfx/inventory/item_bg_draw_many.png";
  end
	if action_type == ACTION_TYPE_MATERIAL then
    return "data/ui_gfx/inventory/item_bg_material.png";
  end
	if action_type == ACTION_TYPE_MODIFIER then
    return "data/ui_gfx/inventory/item_bg_modifier.png";
  end
	if action_type == ACTION_TYPE_OTHER then
    return "data/ui_gfx/inventory/item_bg_other.png";
  end
	if action_type == ACTION_TYPE_PASSIVE then
    return "data/ui_gfx/inventory/item_bg_passive.png";
  end
	if action_type == ACTION_TYPE_PROJECTILE then
    return "data/ui_gfx/inventory/item_bg_projectile.png";
  end
	if action_type == ACTION_TYPE_STATIC_PROJECTILE then
    return "data/ui_gfx/inventory/item_bg_static_projectile.png";
  end
	if action_type == ACTION_TYPE_UTILITY then
    return "data/ui_gfx/inventory/item_bg_utility.png";
  end
  return "data/ui_gfx/inventory/hover_info_empty_slot.png";
end

function extract_action_stats(action_function)
  ACTION_DRAW_RELOAD_TIME_INCREASE = 0;

  function draw_actions(_, _) end
  function add_projectile_trigger_hit_world(_, _) end
  function add_projectile(_) end
  function add_projectile_trigger_timer(_, _, _) end
  function add_projectile_trigger_death(_, _) end
  function check_recursion(_, _) return -1; end
  function move_discarded_to_deck() end
  function order_deck() end
  function StartReload() end
  function EntityGetWithTag(_) return {} end
  function GameGetFrameNum() return 5431289; end
  function SetRandomSeed() end
  function Random() return 1; end
  function GetUpdatedEntityID() return 0; end
  function EntityGetComponent(_) return {}; end
  function EntityGetFirstComponent(_) return {}; end
  function ComponentGetValue2(_) return 0; end
  function EntityGetTransform(_) return {}; end
  function EntityGetAllChildren(_) return {}; end
  function EntityGetInRadiusWithTag(_, _) return {}; end
  function GlobalsGetValue(_) return 0; end
  function GlobalsSetValue(_) end
  function find_the_wand_held() end
  function EntityGetFirstComponentIncludingDisabled(_) end

  -- for _, action in ipairs(actions) do
  c = {};
  c.fire_rate_wait = 0;
  c.screenshake = 0;
  c.spread_degrees = 0;
  c.damage_critical_chance = 0;
  c.dampening = 0;
  c.ragdoll_fx = 0;
  c.child_speed_multiplier = 0;
  c.bounces = 0;
  c.speed_multiplier = 0;
  c.damage_projectile_add = 0;
  c.game_effect_entities = "";
  c.extra_entities = "";
  c.trail_material = "";
  c.material_amount = 0;
  c.gore_particles = 0;
  c.lifetime_add = 0;
  c.explosion_radius = 0;
  c.damage_explosion_add = 0;
  c.gravity = 0;
  c.knockback_force = 0;
  c.lightning_count = 0;
  c.damage_electricity_add = 0;
  c.damage_ice_add = 0;
  c.trail_material_amount = 0;

  shot_effects = {};
  shot_effects.recoil_knockback = 0;
  discarded = {};
  deck = {};
  hand = {};

  mana = 0;
  current_reload_time = 0;
  reflecting = false;
  action_function();
  return c;
  -- end
end

dofile_once("data/scripts/gun/gun_actions.lua");

function load_actions_by_id()
  local out_table = {};

  for i = 1, #actions do
		out_table[actions[i].id] = actions[i];
		out_table[actions[i].id].actions_index = i;
	end
  return out_table;
end

actions_by_id = load_actions_by_id();
