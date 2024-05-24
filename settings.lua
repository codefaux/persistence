dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.
dofile_once("mods/persistence/files/helper.lua");

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

function mod_setting_change_callback( mod_id, gui, in_main_menu, setting, old_value, new_value  )
	print( tostring(new_value) )
end

mod_id = "persistence" -- This should match the name of your mod's folder.

mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 
mod_settings =
{
  {
    category_id = "liteness_settings",
    ui_name = "LITENESS",
    ui_description = "'Lite-ness' settings (Keep gold, etc)",
    settings = {
      {
        id = "money_saved_on_death",
        ui_name = "Money Saved on Death",
        ui_description = "How much money persists after you do not",
        value_default = 0.25,
        value_min = 0,
        value_max = 1,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
    },
  },
  {
    category_id = "default_settings",
    ui_name = "DEFAULTS",
    ui_description = "Mod defaults",
    settings = {
      {
        id = "always_choose_save_id",
        ui_name = "Load-Save behavior",
        ui_description = "Manually or automatically load a save (or not)",
        value_default = "-1",
        values = { {"-1","Manual"}, {"0","Disable mod"}, {"1","Use Slot 1"}, {"2","Use Slot 2"}, {"3","Use Slot 3"}, {"4","Use Slot 4"}, {"5","Use Slot 5"} },
        scope = MOD_SETTING_SCOPE_RUNTIME,
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
        value_default = 1,
        value_min = .1,
        value_max = 2,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "research_spell_price_multiplier",
        ui_name = "Spell Research Price Multiplier",
        ui_description = "Price Multiplier to Research a Spell",
        value_default = 10,
        value_min = 1,
        value_max = 20,
        value_display_multiplier = 10,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "buy_wand_price_multiplier",
        ui_name = "Buy Wand Price Multiplier",
        ui_description = "Price Multiplier to Buy a Wand",
        value_default = 1,
        value_min = .1,
        value_max = 2,
        value_display_multiplier = 100,
        value_display_formatting = " $0 %",
        scope = MOD_SETTING_SCOPE_NEW_GAME,
      },
      {
        id = "buy_spell_price_multiplier",
        ui_name = "Buy Spell Price Multiplier",
        ui_description = "Price Multiplier to Buy a Spell",
        value_default = 1,
        value_min = .1,
        value_max = 2,
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
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
      {
				id = "enable_teleport_back_up",
				ui_name = "Allow Teleport to Lobby in Holy Mountain",
				ui_description = "Note: There is no return teleport!",
				value_default = true,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
      {
				id = "enable_menu_in_holy_mountain",
				ui_name = "Allow Persistence menu in Holy Mountain",
				ui_description = "Allow access to menu for gold deposit/withdraw, research, buy, etc in Holy Mountain",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
      {
				id = "reusable_holy_mountain",
				ui_name = "Allow Holy Mountain to be reused",
				ui_description = "Definitely a cheat.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
    },
  },
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )

	--example usage:
	--[[
	local im_id = 124662 -- NOTE: ids should not be reused like we do below
	GuiLayoutBeginLayer( gui )

	GuiLayoutBeginHorizontal( gui, 10, 50 )
    GuiImage( gui, im_id + 12312535, 0, 0, "data/particles/shine_07.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause )
    GuiImage( gui, im_id + 123125351, 0, 0, "data/particles/shine_04.xml", 1, 1, 1, 0, GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndPause )
    GuiLayoutEnd( gui )

	GuiBeginAutoBox( gui )

	GuiZSet( gui, 10 )
	GuiZSetForNextWidget( gui, 11 )
	GuiText( gui, 50, 50, "Gui*AutoBox*")
	GuiImage( gui, im_id, 50, 60, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiZSetForNextWidget( gui, 13 )
	GuiImage( gui, im_id, 60, 150, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )

	GuiZSetForNextWidget( gui, 12 )
	GuiEndAutoBoxNinePiece( gui )

	GuiZSetForNextWidget( gui, 11 )
	GuiImageNinePiece( gui, 12368912341, 10, 10, 80, 20 )
	GuiText( gui, 15, 15, "GuiImageNinePiece")

	GuiBeginScrollContainer( gui, 1233451, 500, 100, 100, 100 )
	GuiLayoutBeginVertical( gui, 0, 0 )
	GuiText( gui, 10, 0, "GuiScrollContainer")
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiImage( gui, im_id, 10, 0, "data/ui_gfx/game_over_menu/game_over.png", 1, 1, 0 )
	GuiLayoutEnd( gui )
	GuiEndScrollContainer( gui )

	local c,rc,hov,x,y,w,h = GuiGetPreviousWidgetInfo( gui )
	print( tostring(c) .. " " .. tostring(rc) .." " .. tostring(hov) .." " .. tostring(x) .." " .. tostring(y) .." " .. tostring(w) .." ".. tostring(h) )

	GuiLayoutEndLayer( gui )
	]]--
end
