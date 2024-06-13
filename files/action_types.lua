dofile_once("data/scripts/gun/gun_enums.lua");
dofile_once("data/scripts/gun/gun_extra_modifiers.lua");
dofile_once("data/scripts/gun/gunaction_generated.lua");
dofile_once("data/scripts/gun/gunshoteffects_generated.lua");


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

function extract_action_stats(action)
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

	shot_effects = {};
	ConfigGunShotEffects_Init(shot_effects);

	discarded = {};
	deck = {};
	hand = {};

	mana = 0;
	current_reload_time = 0;

	reflecting = true;

	current_reload_time = 0;
	local shot = { };
	shot.state = { };
	ConfigGunActionInfo_Init(shot.state);
	shot.num_of_cards_to_draw = 0;
	local c = shot.state;

	c.action_id                	 = action.id;
	c.action_name              	 = action.name;
	c.action_description       	 = action.description;
	c.action_sprite_filename   	 = action.sprite;
	c.action_type              	 = action.type;
	c.action_recursive           = action.recursive;
	c.action_spawn_level       	 = action.spawn_level;
	c.action_spawn_probability 	 = action.spawn_probability;
	c.action_spawn_requires_flag = action.spawn_requires_flag;
	c.action_spawn_manual_unlock = action.spawn_manual_unlock or false;
	c.action_max_uses          	 = action.max_uses;
	c.custom_xml_file          	 = action.custom_xml_file;
	c.action_ai_never_uses		 = action.ai_never_uses or false;
	c.action_never_unlimited	 = action.never_unlimited or false;

	c.action_is_dangerous_blast  = action.is_dangerous_blast;

	c.sound_loop_tag = action.sound_loop_tag;

	c.action_mana_drain = action.mana;
	if action.mana == nil then
		c.action_mana_drain = ACTION_MANA_DRAIN_DEFAULT;
	end

	c.action_unidentified_sprite_filename = action.sprite_unidentified;
	if action.sprite_unidentified == nil then
		c.action_unidentified_sprite_filename = ACTION_UNIDENTIFIED_SPRITE_DEFAULT;
	end
	pcall(action.action);

	reflecting = false;
	return c;
end

dofile_once("data/scripts/gun/gun_actions.lua");

function load_actions_by_id()
	local out_table = {};

	for curr_idx, curr_action in ipairs(actions) do
		local a_id = curr_action.id;
		out_table[a_id] = curr_action;
		out_table[a_id].c = {};
		out_table[a_id].actions_index = curr_idx;
		-- out_table[curr_action.id].c = extract_action_stats(curr_action); -- Simulating spells causes thread(?) close
	end
	return out_table;
end

actions_by_id = load_actions_by_id();
