-- Spell per-purchase options; per-spell, per-copy
-- Add linear/expo scaling option to above
-- Wand Icons don't line up consistently
-- Condense spell list, other modes?
-- Fancy search functions?
-- Unique wands (minigun, ocarina, kantele) don't research correctly
-- Spells/wands "stuffing" inventory

-- function EntityGetInRadius(pos_x, pos_y, radius) to auto close menu? -- EntityGetHerdRelationSafe( entity_a:int, entity_b:int )
-- amount of money (from stash) for player on new run
-- persistence tokens

-- Mod order fixes?
-- Mod setting for "allow research spells inside wands"?
-- Translation table for translation mods, translation helper Mod Options setting for tooltips indicating strings and meanings


--- DONE? NEEDS VERIFY:

-- Configurable cap on gold recovered (or damping factor?)
-- Proximity scan report new types
-- Can't research spells when player has "unlimited spells" perk?
-- Spells bought while "unlimited spells" perk have count?



-- for archival
-- function extract_action_stats(action)
--   function draw_actions(_, _) end
--   function add_projectile(x) proc_projectiles(x); end
--   function add_projectile_trigger_hit_world(x, _) proc_projectiles(x); end
--   function add_projectile_trigger_timer(x, _, _) proc_projectiles(x); end
--   function add_projectile_trigger_death(x, _) proc_projectiles(x); end
--   function check_recursion(_, x) return x or 0; end
--   function move_discarded_to_deck() end
--   function order_deck() end
--   function StartReload() end
--   function EntityGetWithTag(_) return {} end
--   function GameGetFrameNum() return 5431289; end
--   function SetRandomSeed() end
--   function Random() return 1; end
--   -- function GetUpdatedEntityID() return 0; end
--   -- function EntityGetComponent(_) return {}; end
--   -- function EntityGetFirstComponent(_, _) return {}; end
--   -- function ComponentGetValue2(_) return 0; end
--   -- function EntityGetTransform(_) return {}; end
--   -- function EntityGetAllChildren(_) return {}; end
--   -- function EntityGetInRadiusWithTag(_, _) return {}; end
--   -- function GlobalsGetValue(_) return 0; end
--   function GlobalsSetValue(_) end
--   function find_the_wand_held() return nil; end
--   -- function EntityGetFirstComponentIncludingDisabled(_) end
