dofile_once("data/scripts/lib/mod_settings.lua");
-- dofile_once("data/scripts/debug/keycodes.lua");

-- This file can't access other files from this or other mods in all circumstances.
-- Settings will be automatically saved.
-- Settings don't have access unsafe lua APIs.

-- Use ModSettingGet() in the game to query settings.
-- For some settings (for example those that affect world generation) you might want to retain the current value until a certain point, even
-- if the player has changed the setting while playing.
-- To make it easy to define settings like that, each setting has a "scope" (e.g. MOD_SETTING_SCOPE_NEW_GAME) that will define when the changes
-- will actually become visible via ModSettingGet(). In the case of MOD_SETTING_SCOPE_NEW_GAME the value at the start of the run will be visible
-- until the player starts a new game.
-- ModSettingSetNextValue() will set the buffered value, that will later become visible via ModSettingGet(), unless the setting scope is MOD_SETTING_SCOPE_RUNTIME.

function mod_setting_integer(mod_id, gui, in_main_menu, im_id, setting)
	local value = ModSettingGetNextValue(mod_setting_get_id(mod_id,setting));
	if type(value) ~= "number" then value = setting.value_default or 0; end

	local value_new = GuiSlider(gui, im_id, mod_setting_group_x_offset, 0, setting.ui_name, value, setting.value_min, setting.value_max, setting.value_default, setting.value_display_multiplier or 1, setting.value_display_formatting or "", 64);
  value_new = math.floor(value_new);

  if value ~= value_new then
		ModSettingSetNextValue(mod_setting_get_id(mod_id,setting), value_new, false);
		mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, value_new);
	end

	mod_setting_tooltip(mod_id, gui, in_main_menu, setting);
end

function mod_setting_number_multiple(mod_id, gui, in_main_menu, im_id, setting)
  local _round_to = setting.round_to or 1;

  local value = ModSettingGetNextValue(mod_setting_get_id(mod_id,setting)) or setting.value_default;

	local value_new = value;
  value_new = math.floor( (GuiSlider(gui, im_id, mod_setting_group_x_offset, 0, setting.ui_name, value_new, setting.value_min, setting.value_max, setting.value_default, setting.value_display_multiplier or 1, setting.value_display_formatting or "", 64) / _round_to) + 0.5 ) * _round_to;

  if value ~= value_new then
    ModSettingSetNextValue(mod_setting_get_id(mod_id,setting), value_new, false);
		mod_setting_handle_change_callback(mod_id, gui, in_main_menu, setting, value, value_new);
	end

	mod_setting_tooltip(mod_id, gui, in_main_menu, setting);
end

mod_id = "persistence" -- This should match the name of your mod's folder.

mod_settings_version = 1; -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 
mod_settings =
{
  {
    category_id = "encoded_settings",
    ui_name = "",
    ui_description = "",
    settings = {
      { hidden = true,  id = "loadout_1",   ui_name = "Wand loadout 1",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_2",   ui_name = "Wand loadout 2",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_3",   ui_name = "Wand loadout 3",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_4",   ui_name = "Wand loadout 4",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_5",   ui_name = "Wand loadout 5",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_6",   ui_name = "Wand loadout 6",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_7",   ui_name = "Wand loadout 7",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_8",   ui_name = "Wand loadout 8",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_9",   ui_name = "Wand loadout 9",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
      { hidden = true,  id = "loadout_10",   ui_name = "Wand loadout 10",   ui_description = "A saved wand loadout",    text_max_length = 512,    value_default = "",
        allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789, ",   scope = MOD_SETTING_SCOPE_RUNTIME,  },
    },
  },
  {
    id = "restart_warning",
    ui_name = "-- NOTE: These settings will not apply until you start a New Game. --",
    not_setting = true,
  },
  {
    category_id = "liteness_settings",
    ui_name = "LITENESS",
    ui_description = "'Lite-ness' settings (Keep money, etc)",
    settings = {
      {
        id = "money_saved_on_death",
        ui_name = "Money Saved on Death",
        ui_description = "How much money persists after you do not",
        ui_fn = mod_setting_number_multiple,
        round_to = 0.01,
        value_default = 0.25,
        value_min = 0,
        value_max = 1,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "cap_money_saved_on_death",
        ui_name = "MAX Money Saved on Death",
        ui_description = "If you think you're earning too quickly (0 is no limit)",
        ui_fn = mod_setting_number_multiple,
        round_to = 5,
        value_default = 0,
        value_min = 0,
        value_max = 500,
        value_display_multiplier = 1,
        value_display_formatting = " $ $0 k",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
    },
  },
  {
    category_id = "default_settings",
    ui_name = "DEFAULTS",
    ui_description = "Run defaults",
    settings = {
      {
        id = "always_choose_save_id",
        ui_name = "Load-Save behavior",
        ui_description = "Manually or automatically load a save (or not)",
        value_default = "-1",
        values = { {"-1","Manual"}, {"0","Disable mod"}, {"1","Use Slot 1"}, {"2","Use Slot 2"}, {"3","Use Slot 3"}, {"4","Use Slot 4"} },
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
      },
      {
        id = "allow_stash",
        ui_name = "(Manual) Stash use",
        ui_description = "Optionally disallow withdrawals, or manual use altogether. Automatic payouts still work.",
        value_default = "1",
        values = { {"1","Allow"}, {"0","Disable Entirely"}, {"-1","Deposit Only"} },
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "start_with_money",
        ui_name = "Start with money",
        ui_description = "Money to withdraw from your Stash at run start",
        ui_fn = mod_setting_number_multiple,
        round_to = 100,
        value_default = 0,
        value_min = 0,
        value_max = 5000,
        value_display_multiplier = 1,
        value_display_formatting = " $ $0",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "holy_mountain_money",
        ui_name = "Holy Mountain Paycheck",
        ui_description = "Money to withdraw from your Stash at each Holy Mountain",
        ui_fn = mod_setting_number_multiple,
        round_to = 100,
        value_default = 0,
        value_min = 0,
        value_max = 5000,
        value_display_multiplier = 1,
        value_display_formatting = " $ $0",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      }
    },
  },
  {
    category_id = "multiplier_settings",
    ui_name = "MULTIPLIERS",
    ui_description = "Cost multipliers",
    settings = {
      {
        id = "research_wand_price_multiplier",
        ui_name = "Wand Research Price Multiplier",
        ui_description = "Price Multiplier to Research a Wand",
        ui_fn = mod_setting_number_multiple,
        round_to = 0.01,
        value_default = 1,
        value_min = .1,
        value_max = 3,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "research_spell_price_multiplier",
        ui_name = "Spell Research Price Multiplier",
        ui_description = "Price Multiplier to Research a Spell",
        ui_fn = mod_setting_number_multiple,
        round_to = 0.1,
        value_default = 10,
        value_min = 1,
        value_max = 30,
        value_display_multiplier = 10,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "buy_wand_price_multiplier",
        ui_name = "Buy Wand Price Multiplier",
        ui_description = "Price Multiplier to Buy a Wand",
        ui_fn = mod_setting_number_multiple,
        round_to = 0.01,
        value_default = 1,
        value_min = .1,
        value_max = 3,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "buy_spell_price_multiplier",
        ui_name = "Buy Spell Price Multiplier",
        ui_description = "Price Multiplier to Buy a Spell",
        ui_fn = mod_setting_number_multiple,
        round_to = 0.01,
        value_default = 1,
        value_min = .1,
        value_max = 3,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
    },
  },
  {
    category_id = "toggle_settings",
    ui_name = "TOGGLES",
    ui_description = "Feature toggles",
    settings = {
      {
        id = "show_guide_tips",
        ui_name = "Show Guide Tooltips in Persistence menus",
        ui_description = "Hotkeys, feature explanations, etc...",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      },
      {
        hidden = true, -- Unused, keep for future need?
        id = "move_lobby_to_spawn",
        ui_name = "Move Lobby to Spawn location",
        ui_description = "Lobby is normally Starting Cave. Move Lobby to Spawn instead. Meant for Random runs.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "enable_edit_wands_in_lobby",
        ui_name = "Allow editing Wands in Lobby",
        ui_description = "Only allowed in Holy Mountain / with perk normally",
        value_default = false,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "enable_teleport_back_up",
        ui_name = "Allow Teleport to Lobby in Holy Mountain",
        ui_description = "Note: There is no return teleport!",
        value_default = true,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "enable_menu_in_holy_mountain",
        ui_name = "Allow Persistence menu in Holy Mountain",
        ui_description = "Allow access to menu for money deposit/withdraw, research, buy, etc in Holy Mountain",
        value_default = false,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "reusable_holy_mountain",
        ui_name = "Allow Holy Mountain to be reused",
        ui_description = "Definitely a cheat.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
    },
  },
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--    - when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
--     - before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--    - when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--    - at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate(init_scope)
  local old_version = mod_settings_get_version(mod_id) -- This can be used to migrate some settings between mod versions.
  mod_settings_update(mod_id, mod_settings, init_scope)
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount()
  return mod_settings_gui_count(mod_id, mod_settings)
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu)
  mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
