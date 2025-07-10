if persistence_active==false then return; end
if persistence_gui_loaded~=true then
  -- once, on load
  dofile_once("data/scripts/debug/keycodes.lua");
  dofile_once(mod_dir .. "files/data_store.lua");
  dofile_once(mod_dir .. "files/gui_subfunc.lua");

  gui = GuiCreate();
  active_windows = {};
  fourslot_table = {};
  fourslot_confirmation = 0;
  spell_list_confirmation = 0;
  small_text_scale = 0.9;
  spell_tooltip_id = "";
  _right_panel_id = 0;

  window_open=false;

  function __nil(...) return; end
  function __layer(n) return 1000 - ((n+1) * 50); end

  dofile_once(mod_dir .. "files/gui/fourslot.lua");
  dofile_once(mod_dir .. "files/gui/modify_wand.lua");
  dofile_once(mod_dir .. "files/gui/money.lua");
  dofile_once(mod_dir .. "files/gui/persistence.lua");
  dofile_once(mod_dir .. "files/gui/scan_nearby_entities.lua");
  dofile_once(mod_dir .. "files/gui/spell_list.lua");
  dofile_once(mod_dir .. "files/gui/spell_loadout.lua");
  dofile_once(mod_dir .. "files/gui/spell_tooltip.lua");
  dofile_once(mod_dir .. "files/gui/teleport.lua");
  dofile_once(mod_dir .. "files/gui/wand_template.lua");

  ---Close all open windows
  function close_open_windows()
    -- close_profile_select();
    close_wands();
    close_money();
    close_wands();
    close_purchase_spells();
    close_inventory_spells();
    close_modify_wand();
    -- close_wand_template();
    close_scan_nearby_entities();
    -- close_spell_loadouts();
    right_panel_picker(0);
    --   close_persistence_menu();
    --   close_spell_tooltip();
  end
  ---end function declarations, run code here;

  print("=========================");
  print("persistence: GUI loaded.");
  persistence_gui_loaded=true;
end
-- every frame;
if selected_profile_id~=-1 then
  _in_lobby = GlobalsGetValue("lobby_collider_triggered", "0")~="0";
  _in_workshop = GlobalsGetValue("workshop_collider_triggered", "0")~="0";
  _allow_teleport = _in_workshop and mod_setting.enable_teleport_back_up==true;
  _allow_workshop = _in_workshop and mod_setting.enable_menu_in_holy_mountain==true;
  _in_persistence_area = _in_lobby or _allow_workshop;
  _persistence_available = _in_persistence_area or mod_setting.global_persistence==true;

  data_store_everyframe();
  if spell_tooltip_id=="" then close_spell_tooltip(); end
  spell_tooltip_id="";

  if loaded_profile_id>0 then
    ---profile loaded, proceed as normal
    if profile_open then close_profile_select(); end

    if isLocked() then UnlockPlayer(); end

    present_scan_nearby_entities();

    if InputIsKeyJustDown(Key_ESCAPE) then
      close_open_windows();
    end

    if _allow_teleport then
      present_teleport();
    else
      close_teleport();
    end
    if _persistence_available then
      present_persistence_menu();
    else
      close_persistence_menu();
    end
  elseif selected_profile_id==-1 then
    if isLocked() then UnlockPlayer(); end
    close_open_windows();
    close_profile_select();
  else
    if not isLocked() then LockPlayer(); end
    present_profile_select();
  end
else
  if isLocked() then UnlockPlayer(); end
  close_open_windows();
  close_profile_select();
end

window_open = profile_open or money_open or wands_open or inventory_spells_open or modify_wand_open;
-- if window_open and spell_tooltip_id~="" then show_spell_tooltip_gui(); end

if gui~=nil and active_windows~=nil and EntityGetIsAlive(player_e_id) then
  GuiStartFrame(gui);
  local start_gui_id = 319585;
  if window_open then
    if not isLocked() then LockPlayer(); end
    GuiZSetForNextWidget(gui, 1000);
    GuiImage(gui, start_gui_id - 1, 0, 0, mod_dir .. "files/img/gui_darken.png", 1, 1, 1, 0);
  end
  for name, window in pairs(active_windows) do
    if window~=nil then
      local gui_id = start_gui_id + simple_string_hash(name);
      window(function()
        gui_id = gui_id + 1;
        return gui_id;
      end);
    end
  end
else
  if isLocked() then UnlockPlayer(); end
end
