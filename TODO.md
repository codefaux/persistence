-- ============
--  BACKBURNER
-- ============
-- persistence tokens?
-- Wand Icons don't line up consistently (best-effort, needs better fix)
-- Mod order fixes?
-- function EntityGetInRadius(pos_x, pos_y, radius) to auto close menu? -- EntityGetHerdRelationSafe( entity_a:int, entity_b:int )
-- Spell per-purchase cost ramp options; per-spell, per-copy
-- Mod setting for "allow research spells inside wands"?
-- Translation table for translation mods, translation helper Mod Options setting for tooltips indicating strings and meanings
-- Config option: Replace starter wand w/ templates 1, 2?
-- Apply loadouts to replacement wands?
-- Z order w/ blinking cursor, spell tooltip re: wand stats
-- stash overflows; split into two variables, store w/ data_store into big_money, bigger_money?


-- =====================
--  BUGS / TOP PRIORITY
-- =====================
-- Options to disable persistent wand stat memory, spell memory, allowing per-run "fresh profile" with stashed money
-- PRUNE DATASTORE/HELPER/WAND_SPELL_HELPER (second wave done)
-- Enable in parallel worlds -- look for controls_mouse and controls_wasd for new "lobby" area?
-- Flesh out and implement meta.lua rigorously
-- Sort order drop-down


-- ====================
--  REQUESTS / IDEAS
-- ====================
-- "Builds" - Match template to Loadout
--    check fit, can cast, etc
--    auto-load spells onto wand when purhcased
-- "Training" - Character stat buffs
-- PlayerEntity;
--  CharacterDataComponent
--    fly_time_max=3 -- adjusts as expected
--    flying_in_air_wait_frames==24
--  CharacterPlatformingComponent
--    velocity_min x, y=-57, -200
--    velocity_max x, y=57, 350
--    fly_velocity_x = ?
--    fly_speed_max_up = ?
--    swim_drag = 0.95
--    swim_extra_horizontal_drag = 0.9
--    pixel_gravity = 
--  DamageModelComponent
--    damage_multipliers
--    air_in_lungs_max
--  IngestionComponent
--    ingestion_capacity
--    ingestion_reduce_every_n_frame
--  KickComponent
--    kick_radius
--    player_kickforce
--    kick_damage
--    kick_knockback
--  LightComponent
--    radius
--  MaterialSuckerComponent
--    barrel_size
--    num_cells_sucked_per_frame


-- ====================
--  DONE? NEEDS VERIFY
-- ====================


-- ==============
--  KNOWN ISSUES
-- ==============
-- Spell overlap due to game item placement bug re: overfilled inventory. Worth fixing? Drop purchases on ground?
-- Inventory spells on wands visibly offset due to wand changes. Seems ingame bug? Unlock during manipulation?
-- Potential wand cost overlap in thoroughly broken gamestage. Clamp?
-- Too easy to research "ultimate tier wand." Weighted research? One stat at a time?


-- ==============
--  for archival
-- ==============
-- function extract_action_stats(action)
-- function draw_actions(_, _) end
-- function add_projectile(x) proc_projectiles(x); end
-- function add_projectile_trigger_hit_world(x, _) proc_projectiles(x); end
-- function add_projectile_trigger_timer(x, _, _) proc_projectiles(x); end
-- function add_projectile_trigger_death(x, _) proc_projectiles(x); end
-- function check_recursion(_, x) return x or 0; end
-- function move_discarded_to_deck() end
-- function order_deck() end
-- function StartReload() end
-- function EntityGetWithTag(_) return {} end
-- function GameGetFrameNum() return 5431289; end
-- function SetRandomSeed() end
-- function Random() return 1; end
-- function GetUpdatedEntityID() return 0; end
-- function EntityGetComponent(_) return {}; end
-- function EntityGetFirstComponent(_, _) return {}; end
-- function ComponentGetValue2(_) return 0; end
-- function EntityGetTransform(_) return {}; end
-- function EntityGetAllChildren(_) return {}; end
-- function EntityGetInRadiusWithTag(_, _) return {}; end
-- function GlobalsGetValue(_) return 0; end
-- function GlobalsSetValue(_) end
-- function find_the_wand_held() return nil; end
-- function EntityGetFirstComponentIncludingDisabled(_) end

-- local biome = BiomeMapGetName( pos_x, pos_y )
--	if ( string.find( biome, "holymountain" ) == nil ) and ( string.find( biome, "victoryroom" ) == nil ) then
