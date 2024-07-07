dofile_once("data/scripts/lib/mod_settings.lua");
---mod files dir. ALSO UPDATE IN XMLs
mod_dir = "mods/persistence_staging/";

dofile_once(mod_dir .. "files/meta.lua");
dofile_once(mod_dir .. "files/cost.lua");

mod_flag_name = "persistence";

mod_disabled = false;
persistence_active=false;

player_e_id=0;
last_known_money=0;
mod_setting = {
  show_guide_tips =                   ModSettingGet("persistence.show_guide_tips"),
  start_with_money =                  ModSettingGet("persistence.start_with_money"), --- see profile load
  holy_mountain_money =               ModSettingGet("persistence.holy_mountain_money"), --- see entity_mgr
  cap_money_saved_on_death =          ModSettingGet("persistence.cap_money_saved_on_death") * 1000,
  allow_stash =              tonumber(ModSettingGet("persistence.allow_stash")), --- 1, allow   0, disable  -1, deposit only
  buy_wand_price_multiplier =         ModSettingGet("persistence.buy_wand_price_multiplier"),
  buy_spell_price_multiplier =        ModSettingGet("persistence.buy_spell_price_multiplier"),
  research_wand_price_multiplier =    ModSettingGet("persistence.research_wand_price_multiplier"),
  research_spell_price_multiplier =   ModSettingGet("persistence.research_spell_price_multiplier"),
  money_saved_on_death =              ModSettingGet("persistence.money_saved_on_death"),
  always_choose_save_id =             ModSettingGet("persistence.always_choose_save_id"),
  enable_edit_wands_in_lobby =        ModSettingGet("persistence.enable_edit_wands_in_lobby"),
  reusable_holy_mountain =            ModSettingGet("persistence.reusable_holy_mountain"),
};

local _paused = false;
function OnPausedChanged(is_paused, _)
  if is_paused~=false then return; end

  mod_setting = {
    show_guide_tips =                   ModSettingGet("persistence.show_guide_tips"),
    start_with_money =                  ModSettingGet("persistence.start_with_money"), --- see profile load
    holy_mountain_money =               ModSettingGet("persistence.holy_mountain_money"), --- see entity_mgr
    cap_money_saved_on_death =          ModSettingGet("persistence.cap_money_saved_on_death") * 1000,
    allow_stash =              tonumber(ModSettingGet("persistence.allow_stash")), --- 1, allow   0, disable  -1, deposit only
    buy_wand_price_multiplier =         ModSettingGet("persistence.buy_wand_price_multiplier"),
    buy_spell_price_multiplier =        ModSettingGet("persistence.buy_spell_price_multiplier"),
    research_wand_price_multiplier =    ModSettingGet("persistence.research_wand_price_multiplier"),
    research_spell_price_multiplier =   ModSettingGet("persistence.research_spell_price_multiplier"),
    money_saved_on_death =              ModSettingGet("persistence.money_saved_on_death"),
    always_choose_save_id =             ModSettingGet("persistence.always_choose_save_id"),
    enable_edit_wands_in_lobby =        ModSettingGet("persistence.enable_edit_wands_in_lobby"),
    reusable_holy_mountain =            ModSettingGet("persistence.reusable_holy_mountain"),
  };
end

function create_lobby_effect_entity()
  local _e_id = EntityGetWithTag("player_unit")[1];
  if _e_id~=nil and _e_id~=0 then
    player_e_id = _e_id;
  else
    return;
  end

  local lobby_effect_e_id=EntityCreateNew("persistence_lobby_effect_entity");
  local lobby_effect_gameeffect_c_id = EntityAddComponent2(lobby_effect_e_id, "GameEffectComponent", { effect="EDIT_WANDS_EVERYWHERE", _enabled=false });
  local lobby_effect_lua_c_id = EntityAddComponent2(lobby_effect_e_id, "LuaComponent", {script_source_file=mod_dir .. "files/entity/lobby_effect.lua", execute_every_n_frame=10, _enabled=true });
  EntityAddChild(player_e_id, lobby_effect_e_id);
end

function teleport_back_to_lobby()
  local lobby_x = tonumber(GlobalsGetValue("first_spawn_x", "0")) or 0;
  local lobby_y = tonumber(GlobalsGetValue("first_spawn_y", "0")) or 0;

  EntitySetTransform(player_e_id, lobby_x, lobby_y);
end

function OnModPreInit()
  mod_disabled = mod_setting.always_choose_save_id==0;
end


local _frame_skip = 10;
function OnWorldPostUpdate()
  if mod_disabled then return; end

  dofile(mod_dir .. "files/actions_by_id.lua");
  dofile(mod_dir .. "files/entity_mgr.lua");

  if not actions_by_id_loaded then return; end

  persistence_active = GlobalsGetValue("persistence_active", "false")=="true";

  if GameGetFrameNum()%_frame_skip==0 then
    local _e_id = EntityGetWithTag("player_unit")[1];
    if _e_id~=nil and _e_id~=0 then
      player_e_id = _e_id;
    else
      player_e_id = 0;
    end
  end

  if persistence_active and player_e_id~=0 then
    local _c_id = EntityGetFirstComponentIncludingDisabled(player_e_id, "WalletComponent") or 0;
    if _c_id~=0 then
      local _money = ComponentGetValue2(_c_id, "money")
      if _money~=nil and _money>0 then last_known_money=_money; end
    end

    dofile(mod_dir .. "files/gui.lua");
    -- GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) );
    OnModEndFrame();
  end
end


local spawn_run_once=true;

function OnPlayerSpawned(entity_id)
  if mod_disabled then return; end

  -- if player_e_id~=0 then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and player_e_id~=nil"); return; end
  if entity_id==0 then print("Persistence: init.lua: OnPlayerSpawned(entity_id) and entity_id==0"); return; end
  -- player_e_id = entity_id;

  if GameGetFrameNum() < 60 and spawn_run_once then
    ---Player spawned within 60 frames, this is a new game
    GlobalsSetValue("persistence_active", "true"); persistence_active=true; ---latter is mostly for ide annotations

    x_loc, y_loc = EntityGetTransform(entity_id);
    GlobalsSetValue("first_spawn_x", tostring(x_loc));
    GlobalsSetValue("first_spawn_y", tostring(y_loc));
    once=false;  ---set late so function repeats if not successful aka early exit
  end
end


function OnPlayerDied(entity_id)
  if mod_disabled then return; end
  -- if entity_id~=player_e_id then return; end

  local _money_to_save = math.floor(last_known_money * mod_setting.money_saved_on_death );
  local _mod_cap = mod_setting.cap_money_saved_on_death;
  local _pain = 0;
  if _mod_cap>0 then
    _pain = math.floor(_money_to_save - math.min(_money_to_save, _mod_cap));
    _money_to_save = math.ceil(_money_to_save - _pain);
  end

  GamePrintImportant("You died", string.format(" $ %i was saved.", _money_to_save) );
  print(string.format(" $ %i was saved.", _money_to_save) );
  if _pain>0 then
    GamePrintImportant("You died", string.format(" $ %i evaporated, and you asked for it.", _pain));
    print("recovery cap: " .. _mod_cap);
    print(string.format(" $ %i evaporated, and you asked for it.", _pain));
  end
  increment_stash_money(_money_to_save);
end
