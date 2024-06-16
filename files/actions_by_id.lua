---how to use for your own mod: drop this file into files\ and call it with dofile() -- NOT dofile_once() -- in init.lua OnWorldPostUpdate()

---only run function one time, but must init variable
if actions_by_id__init_done==nil then actions_by_id__init_done=false; end
if actions_by_id__init_done==false then
	---variables and functions run/register/initialize only once
	actions_by_id__init_done = true;
	actions_bt_id__notify_when_finished = true;

	---kill file cache, force reload
	__loaded = {};

	dofile_once( "data/scripts/gun/gun.lua" );
	dofile_once( "data/scripts/lib/utilities.lua" );

	---init but don't overwrite public veriables
	action_count = action_count or 0;
	actions_by_id = actions_by_id or {};

	---returns nothing, directly acts on actions_by_id array
	---@param action_id string id of action to run
	function get_action_metadata(action_id)
		if type(action_id)~="string" then return; end

		reflecting = true; -- This is how we tell the game not to do the things, this redirects many of the action's calls to Reflection_RegisterProjectile() which allows us to extract data
		metadata = {};

		---override Reflection_RegisterProjectile(xml) -in this context only-
		Reflection_RegisterProjectile = function( projectile_xml )
			local skip_or_modify_hash =
			{		---list of member names we don't care about, or need to explicitly change
				config = true,
				config_explosion = true,
				damage_critical = true,
				damage_by_type = true,
				mStartingLifetime = true,
				mTriggers = true,
				do_moveto_update = true,
				angular_velocity = true,
				penetrate_world_velocity_coeff = true,
				ground_penetration_coeff = true,
				-- mInitialSpeed = true,
				on_death_emit_particle = true,
				ground_collision_fx = true,
				die_on_low_velocity = true,
				on_collision_spawn_entity = true,
				penetrate_entities = true,
				velocity_sets_scale = true,
				go_through_this_material = true,
				die_on_liquid_collision = true,
				bounce_at_any_angle = true,
				-- damage_melee = true,
				-- damage_explosion = true,
				mDamagedEntities = true,
				on_death_emit_particle_count = true,
				-- never_hit_player = true,
				camera_shake_when_shot = true,
				-- bounce_always = true,
				velocity_sets_y_flip = true,
				-- damage_physics_hit = true,
				-- collide_with_world = true,
				-- penetrate_world = true,
				physics_impulse_coeff = true,
				mShooterHerdId = true,
				lifetime_randomness = true,
				on_death_particle_check_concrete = true,
				spawn_entity_is_projectile = true,
				-- explosion_dont_damage_shooter = true,
				-- damage_ice = true,
				muzzle_flash_file = true,
				shoot_light_flash_g = true,
				-- damage_radioactive = true,
				shoot_light_flash_b = true,
				collide_with_entities = true,
				damage_scale_max_speed = true,
				ragdoll_fx_on_collision = true,
				bounces_left = true,
				lifetime = true,
				velocity_updates_animation = true,
				-- damage_curse = true,
				damage_every_x_frames = true,
				friction = true,
				on_death_duplicate_remaining = true,
				-- damage_fire = true,
				-- damage_projectile = true,
				shoot_light_flash_radius = true,
				damage_overeating = true,
				-- projectiles = true,
				die_on_low_velocity_limit = true,
				shell_casing_material = true,
				lob_min = true,
				on_collision_die = true,
				-- damage_drill = true,
				-- on_death_explode = true,
				lob_max = true,
				on_collision_remove_projectile = true,
				-- friendly_fire = true,
				-- damage_scaled_by_speed = true,
				-- damage_healing = true,
				spawn_entity = true,
				velocity_sets_rotation = true,
				on_death_item_pickable_radius = true,
				on_lifetime_out_explode = true,
				play_damage_sounds = true,
				mWhoShotEntityTypeID = true,
				-- projectile_type = true,
				-- damage_poison = true,
				damage_game_effect_entities = true,
				attach_to_parent_trigger = true,
				speed_min = true,
				speed_max = true,
				on_death_gfx_leave_sprite = true,
				ground_penetration_max_durability_to_destroy = true,
				mLastFrameDamaged = true,
				shoot_light_flash_r = true,
				shell_casing_offset = true,
				-- bounce_energy = true,
				collide_with_tag = true,
				ragdoll_force_multiplier = true,
				damage = true,
				collide_with_shooter_frames = true,
				-- knockback_force = true,
				velocity_sets_scale_coeff = true,
				dont_collide_with_tag = true,
				hit_particle_force_multiplier = true,
				create_shell_casing = true,
				bounce_fx_file = true,
				collect_materials_to_shooter = true,
				blood_count_multiplier = true,
				mEntityThatShot = true,
				mWhoShot = true,
				-- damage_electricity = true,
				on_death_emit_particle_type = true,
				-- damage_slice = true,
				-- damage_holy = true,
				-- direction_nonrandom_rad = true,
				direction_random_rad = true
			};

			-- if metadata.projectiles[projectile_xml]~=nil then ---check if projectile data already exists
			-- 	metadata.projectiles[projectile_xml].projectiles = metadata.projectiles[projectile_xml].projectiles + 1 ---data for this projectile_xml already exists, add one to count
			-- else ---projectile doesn't exist, create it
			local xml_entity_id = EntityCreateNew();
			EntityApplyTransform(xml_entity_id, -2000, -2000);
			EntityLoadToEntity(projectile_xml, xml_entity_id); ---load projectile entity
			if xml_entity_id~=nil and xml_entity_id~=0 then
				local xml_component_pool = EntityGetAllComponents(xml_entity_id);
				if xml_component_pool~=nil then
					for _, xml_comp_id in pairs(xml_component_pool) do
						if xml_comp_id~=nil and xml_comp_id~=0 then ---ensure component loaded properly
							EntitySetComponentIsEnabled(xml_entity_id, xml_comp_id, false);
							local xml_comp_name = ComponentGetTypeName(xml_comp_id);
							if xml_comp_name=="ProjectileComponent" or xml_comp_name=="LightningComponent" or xml_comp_name=="ExplodeOnDamageComponent" or xml_comp_name=="ExplosionComponent" then
								local xml_comp_field_pool = ComponentGetMembers(xml_comp_id);
								if xml_comp_field_pool~=nil then
									metadata[projectile_xml] = metadata[projectile_xml] or {}; ---create empty table for incoming data if doesn't exist
									metadata[projectile_xml][xml_comp_name] = metadata[projectile_xml][xml_comp_name] or {}; ---create empty table for incoming data if doesn't exist
									for xml_comp_field, _ in pairs(xml_comp_field_pool) do ---iterate thru component members if they exist
										if skip_or_modify_hash[xml_comp_field]~=true then ---only directly store members which aren't tagged
											metadata[projectile_xml][xml_comp_name][xml_comp_field] = ComponentGetValue2(xml_comp_id, xml_comp_field); ---store member to structure
										elseif xml_comp_field=="damage" then ---specific processing for "damage"
											metadata[projectile_xml][xml_comp_name]["damage_basic"] = 25 * (ComponentGetValue2(xml_comp_id, xml_comp_field) or 0);
										elseif xml_comp_field=="damage_by_type" then ---specific processing for "damage_by_type"
											local dmg_type_pool = ComponentObjectGetMembers(xml_comp_id, xml_comp_field);
											if dmg_type_pool~=nil then
												for dmg_type, _ in pairs(dmg_type_pool) do ---break open damage_by_type table
													metadata[projectile_xml][xml_comp_name]["damage_" .. dmg_type] = 25 * (ComponentObjectGetValue2(xml_comp_id, xml_comp_field, dmg_type) or 0); ---store it in singles
												end ---for dmg_type in damage_by_type
											end
										elseif xml_comp_field=="config_explosion" then ---specific processing for "config_explosion"
											metadata[projectile_xml][xml_comp_name]["damage_explosion"] = 25 * (ComponentObjectGetValue2(xml_comp_id, xml_comp_field, "damage") or 0); ---stored separately, standardise
											metadata[projectile_xml][xml_comp_name]["explosion_radius"] = 25 * (ComponentObjectGetValue2(xml_comp_id, xml_comp_field, "explosion_radius") or 0); ---stored separately, standardise
										elseif xml_comp_field=="mStartingLifetime" then ---specific processing for "mStartingLifetime"
											metadata[projectile_xml][xml_comp_name]["lifetime"] = ComponentGetValue2(xml_comp_id, xml_comp_field); ---save with more typical name
										elseif xml_comp_field=="direction_random_rad" then ---specific processing for "direction_random_rad"
											metadata[projectile_xml][xml_comp_name]["spread_degrees"] = math.deg(ComponentGetValue2(xml_comp_id, xml_comp_field));
										elseif xml_comp_field=="speed_min" then ---specific processing for "speed_min"
											local in_speed = ComponentGetValue2(xml_comp_id, xml_comp_field);
											metadata[projectile_xml][xml_comp_name]["speed_min"] = in_speed;
											metadata[projectile_xml][xml_comp_name]["speed"] = (metadata[projectile_xml][xml_comp_name]["speed"]==nil) and in_speed or ((metadata[projectile_xml][xml_comp_name]["speed"] + in_speed) / 2);
										elseif xml_comp_field=="speed_max" then ---specific processing for "speed_max"
											local in_speed = ComponentGetValue2(xml_comp_id, xml_comp_field);
											metadata[projectile_xml][xml_comp_name]["speed_max"] = math.deg(ComponentGetValue2(xml_comp_id, xml_comp_field));
											metadata[projectile_xml][xml_comp_name]["speed"] = (metadata[projectile_xml][xml_comp_name]["speed"]==nil) and in_speed or ((metadata[projectile_xml][xml_comp_name]["speed"] + in_speed) / 2);
										end ---if skip_or_modify_hash[proj_member] block
									end ---for proj_member in ComponentGetMembers(proj_comp); ---iterate thru component members if they exist
									metadata[projectile_xml][xml_comp_name].projectiles = 1; ---start with one projectile
								end
							end
							EntityRemoveComponent(xml_entity_id, xml_comp_id); ---remove the projectile component before we kill it to avoid issues
						end
					end
				end
				EntityKill(xml_entity_id); ---kill the projectile entity since we're done with it
			end
		end -- function override Reflection_RegisterProjectile();


		-- function draw_actions(_, _) end
		-- function add_projectile(x) Reflection_RegisterProjectile(x); end
		-- function add_projectile_trigger_hit_world(x, _) Reflection_RegisterProjectile(x); end
		-- function add_projectile_trigger_timer(x, _, _) Reflection_RegisterProjectile(x); end
		-- function add_projectile_trigger_death(x, _) Reflection_RegisterProjectile(x); end
		-- function check_recursion(_, x) return x or 0; end
		-- function move_discarded_to_deck() end
		-- function order_deck() end
		-- function StartReload() end
		-- -- function EntityGetWithTag(_) return {} end
		-- function GameGetFrameNum() return 5431289; end
		-- function SetRandomSeed() end
		-- function Random() return 1; end
		-- -- function GetUpdatedEntityID() return 0; end
		-- -- function EntityGetComponent(_) return {}; end
		-- -- function EntityGetFirstComponent(_, _) return {}; end
		-- -- function ComponentGetValue2(_) return 0; end
		-- -- function EntityGetTransform(_) return {}; end
		-- -- function EntityGetAllChildren(_) return {}; end
		-- -- function EntityGetInRadiusWithTag(_, _) return {}; end
		-- -- function GlobalsGetValue(_) return 0; end
		-- function GlobalsSetValue(_) end
		-- function find_the_wand_held() return nil; end
		-- -- function EntityGetFirstComponentIncludingDisabled(_) end

		---strip values from c which we don't care about, modify others inline, return updated c table
		---@param in_c table incoming c table
		---@return table stripped c table
		local function parse_c(in_c)
			local skip_or_modify_hash =
			{		---table of values to remove, modify here if add'l data required
				-- pattern_degrees = true,
				-- bounces = true,
				-- action_spawn_level = true,
				-- lightning_count = true,
				state_destroyed_action = true,
				-- action_ai_never_uses = true,
				-- action_name = true,
				-- recoil = true,
				-- action_max_uses = true,
				fire_rate_wait = true,
				sprite = true,
				-- explosion_damage_to_materials = true,
				physics_impulse_coeff = true,
				-- trail_material = true,
				-- child_speed_multiplier = true,
				-- action_draw_many_count = true,
				-- damage_critical_chance = true,
				gore_particles = true,
				action_sprite_filename = true,
				-- action_type = true,
				game_effect_entities = true,
				screenshake = true,
				-- material = true,
				extra_entities = true,
				-- action_never_unlimited = true,
				-- friendly_fire = true,
				sound_loop_tag = true,
				-- action_spawn_probability = true,
				reload_time = true,
				projectile_file = true,
				state_shuffled = true,
				-- explosion_radius = true,
				custom_xml_file = true,
				action_mana_drain = true, ---this value seems to be a lie
				ragdoll_fx = true,
				-- light = true,
				-- action_is_dangerous_blast = true,
				-- spread_degrees = true,
				state_discarded_action = true,
				action_unidentified_sprite_filename = true,
				-- action_description = true,
				-- speed_multiplier = true,
				-- dampening = true,
				-- damage_null_all = true,
				-- knockback_force = true,
				-- action_spawn_requires_flag = true,
				-- blood_count_multiplier = true,
				-- trail_material_amount = true,
				-- damage_critical_multiplier = true,
				state_cards_drawn = true,
				action_spawn_manual_unlock = true,
				-- material_amount = true,
				-- action_id = true,
				-- gravity = true,
				-- lifetime_add = true,
				-- damage_slice_add = true,
				-- damage_ice_add = true,
				-- damage_curse_add = true,
				-- damage_healing_add = true,
				-- damage_drill_add = true,
				damage_fire_add = true,
				damage_melee_add = true,
				damage_electricity_add = true,
				damage_explosion_add = true,
				damage_projectile_add = true,
				direction_random_rad = true,
			};
			local out_c = {}; ---create out_c table
			for membername, _ in pairs(in_c) do ---iterate through members in incoming table
				if skip_or_modify_hash[membername]~=true then ---check against skip_hash to only store desired info
					out_c[membername] = in_c[membername]; ---copy member to output table
				elseif	membername=="damage_electricity_add" or
								membername=="damage_melee_add" or
								membername=="damage_explosion_add" or
								membername=="damage_projectile_add" or
								membername=="damage_fire_add" then
					out_c[membername] = in_c[membername] * 25;
				elseif 	membername=="reload_time" or
								membername=="fire_rate_wait" then
					out_c[membername] = in_c[membername] / 60;
				elseif  membername=="direction_random_rad" then ---specific processing for "direction_random_rad"
					out_c["spread_degrees"] = math.deg(in_c[membername]);
				end ---if skip_hash[membername];
			end ---for membername in in_ic
			return out_c; ---return data table
		end ---function strip_c(in_c); ---returns stripped c structure

		-- local _draw_actions = draw_actions;
		local draws = 0; -- start at 0 additional draws
		draw_actions = function( x ) draws = draws + x; end -- another local override for action() to count draw_action calls

		local _c = c; -- capture the global c context
		c = {}; -- clear c context so we only get one action()
		shot_effects = {}; -- clear shot_effects context so we only get one action()
		current_reload_time = 0; -- clear current_reload_time so we only get one action()
		reset_modifiers( c ); -- prepare c table structure and initialize for relative operations
		ConfigGunShotEffects_Init( shot_effects ); -- prepare shot_effects table structure and initialize for relative operations
		actions_by_id[action_id].action(); -- call the action() function
		actions_by_id[action_id] = actions_by_id[action_id] or {}; -- new table if not already present
		actions_by_id[action_id].c = parse_c(c); -- strip c before storing its data
		actions_by_id[action_id].c.draw_actions = draws; -- add a few flags
		actions_by_id[action_id].c.reload_time = current_reload_time;
		actions_by_id[action_id].c.recoil_knockback = shot_effects.recoil_knockback;
		actions_by_id[action_id].metadata = metadata;
		c = _c; -- restore the global c context
		reflecting = false; -- Return to normal. Likely not necessary but....
	end -- function get_action_metadata(action_id)

	---intended to be run when new actions are found, typically by code below -- feeds information directly into actions_by_id
	---@param max_new_actions_this_pass number
	function collect_action_data(max_new_actions_this_pass)
		local target_cnt = action_count + max_new_actions_this_pass; ---track how many actions we're targeting as our max
		local player = EntityGetWithTag("player_unit")[1];

		if player then EntityRemoveTag(player, "player_unit"); end ---remove player_unit tag, this protects us from some actions
		for _,curr_action in pairs(actions) do ---iterate thru actions until finished or stopped
			if actions_by_id[curr_action.id]==nil and curr_action.id~=nil then ---only process non-nil entries
				action_count = (action_count or 0) + 1; ---add to the action count, start at zero if un-initialized
				actions_by_id[curr_action.id] = curr_action; ---store current action basic data
				-- get_action_metadata(curr_action.id); ---process action to add metadata
			end ---if actions_by_id[curr_action.id]==nil and curr_action.id~=nil;
			if action_count >= target_cnt then break; end
		end ---for curr_action in actions;
		if player then EntityAddTag(player, "player_unit"); end ---re-add player_unit tag to stored player entity
	end -- function collect_action_data(max_new_actions_this_pass)

	---debugging function
	function table_dump(o)
		if type(o) == 'table' then
			 local s = '{ '
			 for k,v in pairs(o) do
					if type(k) ~= 'number' then k = '"'..k..'"' end
					s = s .. '['..k..'] = ' .. table_dump(v) .. ','
			 end
			 return s .. '} '
		else
			 return tostring(o)
		end
	end ---function table_dump(0);

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

	__show_always = function(_) return true; end
	__show_nz = function(value) return (value~=nil and value~=0) and true or false; end
	__show_many = function(value) return (value~=nil and value>1) and true or false; end

	__val = function(value) return value; end
	__trans = function(value) return GameTextGetTranslatedOrNot(value); end
	__yesno = function(value) return value and "$menu_yes" or "$menu_no"; end
	__time = function(value) return GameTextGet("$inventory_seconds", string.format("%1.2f", value)); end
	__deg = function(value) return GameTextGet("$inventory_degrees", string.format("%d", value)); end
	__pct = function(value) return GameTextGet("$menu_slider_percentage", value); end
	__round = function(value) return math.floor(value + 0.49999999999999994); end
	__nil = function(_) return nil; end
	__type = function(value) return action_type_to_string(value); end

	local spell_tooltip_stats_format =
	{ ---membername_pattern 		=	{	icon, 																										gametext,															show_cond(value),			show_value_gametext(value), }
		name											=	{ nil,																											nil,																	__show_always,				__trans },
		description								=	{ nil,																											nil,																	__show_always,				__trans },
		sprite										=	{ __val,																										nil,																	__show_always,				nil },
		type											= { "data/ui_gfx/inventory/icon_action_type.png",							"$inventory_actiontype",							__show_always,				__type },
		draw_actions 							=	{ "data/ui_gfx/inventory/icon_gun_actions_per_round.png",		"$inventory_actiontype_drawmany",			__show_many,					__val },
		max_uses 									=	{ "data/ui_gfx/inventory/icon_action_max_uses.png",					"$inventory_usesremaining",						__show_nz,						__val },
		mana											=	{ "data/ui_gfx/inventory/icon_mana_drain.png",							"$inventory_manadrain",								__show_nz,		 				__val },
		fire_rate_wait						=	{ "data/ui_gfx/inventory/icon_gun_reload_time.png",					"$inventory_castdelay",								__show_always, 				__time },
		reload_time								=	{ "data/ui_gfx/inventory/icon_reload_time.png",							"$inventory_rechargetime",						__show_always, 				__time },
		damage_projectile_add			=	{ "data/ui_gfx/inventory/icon_damage_projectile.png",				"$inventory_damage",									__show_nz,						__round },
		damage_basic							=	{ "data/ui_gfx/inventory/icon_damage_projectile.png",				"$inventory_mod_damage",							__show_nz,						__round },
		damage_slice							=	{ "data/ui_gfx/inventory/icon_damage_slice.png",						"$inventory_dmg_slice",								__show_nz,						__round },
		damage_melee_add					=	{ "data/ui_gfx/inventory/icon_damage_melee.png",						"$inventory_dmg_melee",								__show_nz,						__round	},
		damage_melee							=	{ "data/ui_gfx/inventory/icon_damage_melee.png",						"$inventory_dmg_melee",								__show_nz,						__round },
		damage_electricity_add		=	{ "data/ui_gfx/inventory/icon_damage_electricity.png",			"$inventory_mod_damage_electric",			__show_nz,						__round },
		damage_electricity				=	{ "data/ui_gfx/inventory/icon_damage_electricity.png",			"$inventory_mod_damage_electric",			__show_nz,						__round },
		damage_fire_add	 					=	{ "data/ui_gfx/inventory/icon_damage_fire.png",							"$inventory_dmg_fire",								__show_nz,						__round },
		damage_fire								=	{ "data/ui_gfx/inventory/icon_damage_fire.png",							"$inventory_dmg_fire",								__show_nz,						__round },
		damage_explosion_add			=	{ "data/ui_gfx/inventory/icon_damage_explosion.png",				"$inventory_dmg_explosion",						__show_nz,						__round },
		explosion_radius					=	{ "data/ui_gfx/inventory/icon_explosion_radius.png",				"$inventory_explosion_radius",				__show_nz,						__val },
		damage_explosion					=	{ "data/ui_gfx/inventory/icon_damage_explosion.png",				"$inventory_dmg_explosion",						__show_nz,						__round },
		damage_curse							=	{ "data/ui_gfx/inventory/icon_damage_curse.png",						"$inventory_dmg_curse",								__show_nz,						__round },
		damage_ice								=	{ "data/ui_gfx/inventory/icon_damage_ice.png" ,							"$inventory_dmg_ice",									__show_nz,						__round },
		damage_drill							=	{ "data/ui_gfx/inventory/icon_damage_drill.png",						"$inventory_dmg_drill",								__show_nz,						__round },
		damage_poison							=	{ "data/ui_gfx/inventory/icon_damage_curse.png",						"$inventory_dmg_poison",							__show_nz,						__round },
		damage_healing						=	{ "data/ui_gfx/inventory/icon_damage_healing.png",					"$inventory_dmg_healing",							__show_nz,						__round },
		damage_radioactive				=	{ "data/ui_gfx/inventory/icon_damage_curse.png",						"$inventory_dmg_radioactive",					__show_nz,						__round },
		-- speed_multiplier					=	{ "data/ui_gfx/inventory/icon_speed_multiplier.png",				"$inventory_speed",										__show_many,		 				__val },
		speed											= { "data/ui_gfx/inventory/icon_speed_multiplier.png",				"$inventory_speed",										__show_nz,						__round },
		damage_critical_chance		=	{ "data/ui_gfx/inventory/icon_damage_critical_chance.png",	"$inventory_mod_critchance",					__show_nz,						__pct },
		projectiles								=	{ "data/ui_gfx/inventory/icon_gun_actions_per_round.png",		"$inventory_type_projectile",					__show_many,					__val	},
		spread_degrees						=	{ "data/ui_gfx/inventory/icon_spread_degrees.png",					"$inventory_spread",									__show_nz,						__deg },
		-- speed_min									= { "data/ui_gfx/inventory/icon_speed_multiplier.png",				"$inventory_speed",										__show_nz,						__round },
		-- speed_max									= { "data/ui_gfx/inventory/icon_speed_multiplier.png",				"$inventory_speed",										__show_nz,						__round },
	}

	function get_action_struct(in_action)
		if type(in_action)~="table" then return; end

		get_action_metadata(in_action.id);

		local struct_data = {};
		local struct_index = 0;
		local source_pool = {in_action, in_action.c };
		for _, projectile_component_pool in pairs(in_action.metadata) do
			for _, projectile_component_member_pool in pairs(projectile_component_pool) do
				source_pool[#source_pool+1] = projectile_component_member_pool;
			end
		end

		for _, member_pool in ipairs(source_pool) do
			for member_name, member_value in pairs(member_pool) do
				for datum_name, datum_formatting in pairs(spell_tooltip_stats_format) do
					if member_name==datum_name and (datum_formatting[3](member_value)==true) then
						local thismember_data = {}
						if datum_formatting[1]~=nil then
							if type(datum_formatting[1])=="function" then
								thismember_data.icon = datum_formatting[1](member_value);
								-- print("icon: " .. datum_formatting[1](member_value));
							else
								thismember_data.icon = datum_formatting[1];
								-- print("icon: " .. datum_formatting[1]);
								thismember_data.label = GameTextGetTranslatedOrNot(datum_formatting[2]);
								-- print("label: " .. GameTextGetTranslatedOrNot(datum_formatting[2]));
							end
						end
						if datum_formatting[4]~=nil then
							thismember_data.value = datum_formatting[4](member_value);
							-- print("value: " .. datum_formatting[4](member_value));
						end
						if thismember_data["icon"]~=nil or thismember_data["value"]~=nil then
							struct_index = struct_index + 1;
							thismember_data.name = member_name;
							struct_data[struct_index] = thismember_data;
						end
					end
				end
			end
		end
		return struct_data;
	end

	function debug_print_action(debug_action)
		local action_struct_pool = get_action_struct(debug_action);
		if action_struct_pool==nil then return; end

		for action_member, action_struct in pairs(action_struct_pool) do
			print("icon: " .. (action_struct.icon or " "));
			print("label: " .. (action_struct.label or " "));
			print("value: " .. (action_struct.value or " "));
			print(" ");
		end
	end -- function debug_print_action();

	function action_tooltip(x_loc, y_loc, action_id)

	end
end -- if initialized

---intended to be run every world update w/ minimal impact
if action_count<#actions then
	print("actions_by_id: capturing new actions, group " .. action_count .. " to (at most) " .. action_count + 100);
	collect_action_data(100);
	actions_bt_id__notify_when_finished = true;
elseif actions_bt_id__notify_when_finished==true then
	actions_bt_id__notify_when_finished = false;
	print("actions_by_id: scan done, storing " .. action_count .. " actions")
	local debug_action = actions_by_id["RUBBER_BALL"];

	print("table = " .. table_dump(debug_action));
	print("action: " .. GameTextGetTranslatedOrNot(debug_action.name));

	debug_print_action(debug_action);

	---debug_action

	-- local action_datum_pool = { "mana", "price", "type", "name", "description", "spread_degrees", "damage.*", "speed.*" }
	-- for action_member, action_value in pairs(debug_action) do
	-- 	print("- members: " .. action_member);
	-- 	for _, datum_pattern in ipairs(action_datum_pool) do
	-- 		if string.find(action_member, datum_pattern)~=nil and type(action_value)~="boolean" then
	-- 			if type(action_value)=="boolean" then
	-- 				print(".. " .. (action_value and "true" or "false") )
	-- 			else
	-- 				print(" .. " .. action_value);
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- print "c:"
	-- local c_datum_pool = { "mana", "price", "action_name", "action_type", "spread_degrees", "damage.*", "speed.*" }
	-- for c_member, c_value in pairs(debug_action.c) do
	-- 	print("- members: " .. c_member);
	-- 	for _, datum_pattern in ipairs(c_datum_pool) do
	-- 		if string.find(c_member, datum_pattern)~=nil then
	-- 			if type(c_value)=="boolean" then
	-- 				print(".. " .. (c_value and "true" or "false") )
	-- 			else
	-- 				print(" .. " .. c_value);
	-- 			end
	-- 		end
	-- 	end
	-- end


	-- local datum_pool = { "spread_degrees", "damage.*", "speed.*", "projectiles" }
	-- print("meta:");
	-- for curr_xml, xml_member_pool in pairs(debug_action.metadata) do
	-- 	print("- xml: " .. curr_xml);
	-- 	for xml_component_name, xml_component_value in pairs(xml_member_pool) do
	-- 		print("-- component: " .. xml_component_name);
	-- 		for xml_member, member_value in pairs(xml_component_value) do
	-- 			print("--- members: " .. xml_member);
	-- 			for _, datum_pattern in ipairs(datum_pool) do
	-- 				if string.find(xml_member, datum_pattern)~=nil and type(member_value)~="boolean" then
	-- 					if type(member_value)=="boolean" then
	-- 						print(".. " .. (member_value and "true" or "false") )
	-- 					else
	-- 						print(" .. " .. member_value);
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end
