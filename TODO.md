-- Spell per-purchase options; per-spell, per-copy
-- Add linear/expo scaling option to above
-- Configurable cap on gold recovered (or damping factor?)
-- Wand Icons don't line up
-- Price very wrong during wand creation/editing
-- Condense spell list, other modes?
-- Proximity scan not report new types?
-- Fancy search functions?


-- TODO : function EntityGetInRadius(pos_x, pos_y, radius) to auto close menu? -- EntityGetHerdRelationSafe( entity_a:int, entity_b:int )
-- TODO : amount of money (from stash) for player on new run
-- TODO : alt. scaling of costs (nonlinear)
-- TODO : persistence tokens
-- TODO : Can't research spells when player has "unlimited spells" perk?
-- TODO : Spells bought while "unlimited spells" perk have count?
-- TODO : Mod order fixes?
-- TODO : Mod setting for "allow research spells inside wands"?


-- TODO : Translation table for translation mods, translation helper Mod Options setting for tooltips indicating strings and meanings



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
