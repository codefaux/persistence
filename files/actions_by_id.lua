if initialized==nil then initialized=false; end
if initialized==false then
	initialized = true;
	dump_once = true;

	__loaded = {};

	dofile_once( "data/scripts/gun/gun.lua" );
	dofile_once( "data/scripts/lib/utilities.lua" );

	function table_equals(o1, o2, ignore_mt)
		if o1 == o2 then return true end
		local o1Type = type(o1)
		local o2Type = type(o2)
		if o1Type ~= o2Type then return false end
		if o1Type ~= 'table' then return false end

		if not ignore_mt then
				local mt1 = getmetatable(o1)
				if mt1 and mt1.__eq then
					  --compare using built in method
					  return o1 == o2
				end
		end

		local keySet = {}

		for key1, value1 in pairs(o1) do
				local value2 = o2[key1]
				if value2 == nil or table_equals(value1, value2, ignore_mt) == false then
					  return false
				end
				keySet[key1] = true
		end

		for key2, _ in pairs(o2) do
				if not keySet[key2] then return false end
		end
		return true
	end

	action_count = action_count or 0;
	action_data = action_data or {};
	action_metadata = action_metadata or {};
	metadata = {};

	function get_action_metadata( action_id )
		metadata =
		{
			c = {},
			projectiles = nil,
			shot_effects = {},
		};
		reflecting = true;
		Reflection_RegisterProjectile = function( projectile_xml )
			if metadata.projectiles==nil then
				metadata.projectiles = {};
			end

			local skip_or_modify_hash =
			{
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
				-- speed_min = true,
				attach_to_parent_trigger = true,
				-- speed_max = true,
				on_death_gfx_leave_sprite = true,
				ground_penetration_max_durability_to_destroy = true,
				mLastFrameDamaged = true,
				shoot_light_flash_r = true,
				shell_casing_offset = true,
				-- bounce_energy = true,
				collide_with_tag = true,
				ragdoll_force_multiplier = true,
				-- damage = true,
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
				direction_nonrandom_rad = true,
				direction_random_rad = true
			};

			if metadata.projectiles[projectile_xml]~=nil then
				metadata.projectiles[projectile_xml].projectiles = metadata.projectiles[projectile_xml].projectiles + 1
			else
				local proj_entity_id = EntityLoad(projectile_xml, -20000, -20000);
				local proj_comp = EntityGetFirstComponent(proj_entity_id, "ProjectileComponent");
				if proj_comp~=nil and proj_comp~=0 then
					metadata.projectiles[projectile_xml] = {};
					for proj_member, _ in pairs(ComponentGetMembers(proj_comp)) do
					  if skip_or_modify_hash[proj_member]~=true then
					    metadata.projectiles[projectile_xml][proj_member] = ComponentGetValue2(proj_comp, proj_member);
					  elseif proj_member=="damage_by_type" then
					    for dmg_type, _ in pairs(ComponentObjectGetMembers(proj_comp, proj_member)) do
					      metadata.projectiles[projectile_xml]["damage_" .. dmg_type] = ComponentObjectGetValue2(proj_comp, proj_member, dmg_type) or 0;
					    end
					  elseif proj_member=="config_explosion" then
					    metadata.projectiles[projectile_xml]["damage_explosion"] = ComponentObjectGetValue2(proj_comp, proj_member, "damage" );
					  elseif proj_member=="mStartingLifetime" then
					    metadata.projectiles[projectile_xml]["lifetime"] = ComponentGetValue2(proj_comp, proj_member);
					  end
					end
					metadata.projectiles[projectile_xml].projectiles = 1;
					-- ComponentSetValue2(proj_comp, "on_death_explode", false);
					-- ComponentSetValue2(proj_comp, "on_lifetime_out_explode", false);
					-- ComponentSetValue2(proj_comp, "collide_with_entities", false);
					-- ComponentSetValue2(proj_comp, "collide_with_world", false);
					-- ComponentSetValue2(proj_comp, "lifetime", 999 );

					EntityRemoveComponent(proj_entity_id, proj_comp);
				end
				EntityKill(proj_entity_id);
			end
		end -- function override Reflection_RegisterProjectile();

		local function strip_c(in_c)
			local skip_or_modify_hash =
			{
				pattern_degrees = true,
				damage_curse_add = true,
				bounces = true,
				action_spawn_level = true,
				lightning_count = true,
				state_destroyed_action = true,
				action_ai_never_uses = true,
				action_name = true,
				recoil = true,
				action_max_uses = true,
				damage_electricity_add = true,
				fire_rate_wait = true,
				sprite = true,
				explosion_damage_to_materials = true,
				physics_impulse_coeff = true,
				trail_material = true,
				child_speed_multiplier = true,
				action_draw_many_count = true,
				lifetime_add = true,
				damage_critical_chance = true,
				gore_particles = true,
				action_sprite_filename = true,
				action_type = true,
				game_effect_entities = true,
				screenshake = true,
				damage_explosion_add = true,
				damage_slice_add = true,
				material = true,
				extra_entities = true,
				damage_projectile_add = true,
				action_never_unlimited = true,
				friendly_fire = true,
				sound_loop_tag = true,
				damage_ice_add = true,
				action_spawn_probability = true,
				reload_time = true,
				projectile_file = true,
				state_shuffled = true,
				explosion_radius = true,
				damage_healing_add = true,
				custom_xml_file = true,
				action_mana_drain = true,
				ragdoll_fx = true,
				light = true,
				action_is_dangerous_blast = true,
				spread_degrees = true,
				state_discarded_action = true,
				damage_drill_add = true,
				action_unidentified_sprite_filename = true,
				action_description = true,
				speed_multiplier = true,
				damage_fire_add = true,
				dampening = true,
				damage_null_all = true,
				knockback_force = true,
				action_spawn_requires_flag = true,
				blood_count_multiplier = true,
				trail_material_amount = true,
				damage_critical_multiplier = true,
				state_cards_drawn = true,
				action_spawn_manual_unlock = true,
				material_amount = true,
				action_id = true,
				gravity = true,
				damage_melee_add = true
			};
					if skip_or_modify_hash[proj_member]~=true then

					end

		end


		-- local _draw_actions = draw_actions;
		local draws = 0;
		draw_actions = function( x ) draws = draws + x; end



		local _c = c;
		c = {};
		shot_effects = {};
		current_reload_time = 0;
		reset_modifiers( c );
		ConfigGunShotEffects_Init( shot_effects );
		action_data[action_id].action();
		-- draw_actions = _draw_actions;
		action_metadata[action_id] = action_metadata[action_id] or {};
		action_metadata[action_id].c = c;
		action_metadata[action_id].draw_actions = draws;
		action_metadata[action_id].reload_time = current_reload_time;
		action_metadata[action_id].recoil_knockback = shot_effects.recoil_knockback;
		action_metadata[action_id].projectiles =  metadata.projectiles;
		c = _c;
		reflecting = false;
	end

	function collect_action_data(amt)
		local target_cnt = action_count + amt;
		local player = EntityGetWithTag("player_unit")[1];

		if player then EntityRemoveTag(player, "player_unit"); end
		for _,curr_action in pairs(actions) do
			if action_count < target_cnt then
				if action_data[curr_action.id]==nil then
					print(" -- " .. curr_action.id);
					action_count = (action_count or 0) + 1;
					action_data[curr_action.id] = curr_action;
					get_action_metadata(curr_action.id);
				end
			else
				break;
			end
		end
		if player then EntityAddTag(player, "player_unit"); end
		refresh_actions = false;
	end

	function dump(o)
		if type(o) == 'table' then
			 local s = '{ '
			 for k,v in pairs(o) do
					if type(k) ~= 'number' then k = '"'..k..'"' end
					s = s .. '['..k..'] = ' .. dump(v) .. ','
			 end
			 return s .. '} '
		else
			 return tostring(o)
		end
	end
end -- if initialized

if action_count<#actions then
	dump_once = true;
	print("capturing actions, group " .. action_count .. " .. " .. action_count + 150);
	collect_action_data(150);
elseif dump_once==true then
	dump_once = false;
	print(dump(action_data["BOMB"]));
	print(dump(action_metadata["BOMB"]));
end
