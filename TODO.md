
-- TODO : function EntityGetInRadius(pos_x, pos_y, radius) to auto close menu? -- EntityGetHerdRelationSafe( entity_a:int, entity_b:int )
-- TODO : amount of money (from stash) for player on new run
-- TODO : alt. scaling of costs (nonlinear)
-- TODO : persistence tokens
-- TODO : find code which runs every frame and reduce
-- TODO : Push IDs / Z order
-- TODO : Fix bypassing "no wand tinkering"
-- TODO : Can't research spells when player has "unlimited spells" perk
-- TODO : Spells bought while "unlimited spells" perk have count
-- TODO : Mod order fixes?
-- TODO : Mod setting for "allow research spells inside wands"
-- TODO : check proximity for wands/spells, icon lower left if new
--- store: spell tag: card_action -- component "ItemActionComponent", member action_id
--- roaming: wand tag: item, wand, child entities: card_action, component "ItemActionComponent", members action_id
                        component "AbilityComponent" for stats, member use_gun_script, mana_max, mana_charge_speed, object gun_config ConfigGun, actions_per_round, shuffle_deck_when_empty, reload_time, deck_capacity
                        component "SpriteComponent", image_file


-- TODO : Translation table for translation mods, translation helper Mod Options setting for tooltips indicating strings and meanings


-- nearby entities check rearchable, ui icon?

--- V3 notes;
-- init
---   find/clone workshops
---   load actions_by_id, gui
---   watch position, show/disable buttons/uis, disable/enable controls
---   fix teleport component on teleport?
--    fix workshops
--    handle lobby entity
--    death screen/info

-- datastore;
--    load/store data structure

--    mostly unchanged

-- UI responsibilities;
---   MANAGE Z ORDER
--    Spells rendered by lua table+functions
--    catch spawn, profile select, play w/out mod
---       retrieve name, desc, icon
---       tooltip
-- 'buy/research/pick always cast' all use same method, sub showtrigger/interact group
-- profile window;
--            largely unchanged
--            icons for spells?
--            icons for wands?
-- main window;
--    bottom right corner, logo to toggle UI
--        money always on screen
---           hide button group unless hovering?
--        wand "tab", click existing to research, click empty to buy
---           largely unchanged from existing layout
---           buy wand; new ui
--                reuse first wand layout, expand right w/ sliders
--            inscriptions button on each wand near capacity; new ui
--                wand capacity top row, stored inscription templates below
--        spell "tab", col. a research, col. b buy
--            filter, search, sort
---           extend search func? comma separate? name, #desc, @stat, ##any, -not?
---           extend sort func? name, sort/sub-sort; By Name, or By Type+{Name|Cost}, Cost+{Name|Type}
---           multi-layout? detail list, short list, grid
---           extra verbosity; self-danger? penetrates world? destroys world?
-- teleport button
--    teleport functions in helper? ui?
--    fix teleport component on teleport?

-- for archival
-- function extract_action_stats(action)
-- 	function draw_actions(_, _) end
-- 	function add_projectile(x) proc_projectiles(x); end
-- 	function add_projectile_trigger_hit_world(x, _) proc_projectiles(x); end
-- 	function add_projectile_trigger_timer(x, _, _) proc_projectiles(x); end
-- 	function add_projectile_trigger_death(x, _) proc_projectiles(x); end
-- 	function check_recursion(_, x) return x or 0; end
-- 	function move_discarded_to_deck() end
-- 	function order_deck() end
-- 	function StartReload() end
-- 	function EntityGetWithTag(_) return {} end
-- 	function GameGetFrameNum() return 5431289; end
-- 	function SetRandomSeed() end
-- 	function Random() return 1; end
-- 	-- function GetUpdatedEntityID() return 0; end
-- 	-- function EntityGetComponent(_) return {}; end
-- 	-- function EntityGetFirstComponent(_, _) return {}; end
-- 	-- function ComponentGetValue2(_) return 0; end
-- 	-- function EntityGetTransform(_) return {}; end
-- 	-- function EntityGetAllChildren(_) return {}; end
-- 	-- function EntityGetInRadiusWithTag(_, _) return {}; end
-- 	-- function GlobalsGetValue(_) return 0; end
-- 	function GlobalsSetValue(_) end
-- 	function find_the_wand_held() return nil; end
-- 	-- function EntityGetFirstComponentIncludingDisabled(_) end


---Lobby detection uses lobby collider
---workshop detection reads player/hitbox location manually per frame
---add persistence lua to persistence_workshop entities?
---add persistence lua to *all* workshop entities?


-- System flow;
OnWorldPostUpdate;
-- dofile actions_by_id
-- load lobby collider entity if not exist, store globally
-- exit if no player or player is dead
-- if player entity's TeleportComponent exists and coords are nonzero, set coords zero and disable
-- if player post-spawn routine not run, run it ----BELOW
-- if loaded profile invalid or zero, exit
-- find and enable lobby collider entity components
-- if gui_update() exists, run it
-- if loaded profile is nil, exit

-- populate workshop entity pool, store count
-- iterate workshop list, if persistence_workshop is invalid or "distance" to nearest persistence_workshop>10 load new persistence_workshop and set coords to match.
-- if mod setting persistence.reusable_holy_mountain then add persistence_list to workshop_list
-- set if player was in workshop before
-- check player coords for hitbox trigger in workshop list
-- set player in workshop now

-- show teleport ui if in workshop now but not before

-- manage "in valid lobby area" with global lobby_collider_triggered, lobby_collider_triggered_edge, unset _edge, tag/untag as present, trigger/close guis


OnPostPlayerSpawned; -- not engine event
-- dofile_once data_store.lua, gui.lua
-- if first few frames, set_run_created_with_mod -- intent; tag mod as active for new game, prevent running if mod added mid-game

-- if selected_profile_id==nil,
--- load or create default profile if set in modsettings, or play-without-mod -- intent, runi start with default slot
--- if default is manual, show profile selector gui -- intent, run start with manual
-- else if not zero, load profile -- intent, reloading mod during run

OnPlayerDied;
-- hide gui elements
-- ensure mod is running
-- save money to stash
GamePrintImportant death message
