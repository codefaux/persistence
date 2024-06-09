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
