if persistence_menu_loaded~=true then
  dofile_once("data/scripts/debug/keycodes.lua");
  persistence_open=false;
  local _right_panel_id = 0;

  function right_panel_picker(panel_id)
    _right_panel_id = panel_id or 0;
    if _right_panel_id==0 then
      close_spell_loadouts();
      close_wand_template();
    elseif _right_panel_id==1 then
      present_wand_template();
      close_spell_loadouts();
    elseif _right_panel_id==2 then
      close_wand_template();
      present_spell_loadouts();
    end
  end

  local function draw_persistence_menu()
    persistence_expanded = false;
    local _gamepad_page = 0;

    active_windows["persistence"] = function (_nid)
      local _hotkey = 0;

      local function _toggle_state()
        if persistence_expanded then
          _right_panel_id = 0;
          close_open_windows();
          persistence_expanded=false;
        else
          persistence_expanded=true;
        end
      end

      if persistence_expanded then
        -- TRYING TO HANDLE GAMEPAD INPUT HERE
        if InputIsJoystickButtonJustDown(0, JOY_BUTTON_LEFT_SHOULDER) then
          _gamepad_page = (_gamepad_page - 1) % 3;
          _hotkey = _gamepad_page + 1;
        end

        if InputIsJoystickButtonJustDown(0, JOY_BUTTON_RIGHT_SHOULDER) then
          _gamepad_page = (_gamepad_page + 1) % 3;
          _hotkey = _gamepad_page + 1;
        end
      end

      if InputIsJoystickButtonJustDown(0, mod_setting.gamepad_menu_trigger) and not _keywait then
        if persistence_expanded==false then
          _keywait = true;
          _toggle_state();
          _hotkey = 1;
          -- _hotkey = _gamepad_page + 1;
        else
          _toggle_state();
        end
      end

      if InputIsKeyJustDown(Key_GRAVE) and not _keywait then
        if persistence_expanded==false then _toggle_state(); end

        local _shift = InputIsKeyDown(Key_LSHIFT);
        local _ctrl = InputIsKeyDown(Key_LCTRL);
        _keywait = true;
        if not (_shift or _ctrl) then _hotkey=1; else
          if _shift and not _ctrl then _hotkey=2; end
          if not _shift and _ctrl then _hotkey=3; end
        end
      end

      if _keywait and (not InputIsKeyJustDown(Key_GRAVE) and not InputIsJoystickButtonJustDown(0, mod_setting.gamepad_menu_trigger) ) then
        _keywait = false;
      end


      if purchase_spells_open==true and _hotkey==2 then _toggle_state(); end
      if inventory_spells_open==true and _hotkey==3 then _toggle_state(); end

      local _picker_x_base = 488;
      local _picker_y_base = 134;
      local _picker_height = 10;
      local _picker_width = 134;

      if _right_panel_id~=0 then
        GuiBeginAutoBox(gui);
        GuiZSetForNextWidget(gui, __layer(4));
        GuiColorNextWidgetEnum(gui, _right_panel_id==1 and COLORS.Green or COLORS.Dim);
        if GuiButton(gui, _nid(), _picker_x_base, _picker_y_base, "Templates", 1) then
          right_panel_picker(1);
        end
        GuiGuideTip(gui, "Stored Wand Templates menu", "Create and buy wand templates");

        GuiZSetForNextWidget(gui, __layer(3));
        GuiEndAutoBoxNinePiece(gui, 2);

        GuiZSetForNextWidget(gui, __layer(3));
        GuiBeginAutoBox(gui);
        GuiZSetForNextWidget(gui, __layer(4));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
        GuiColorNextWidgetEnum(gui, _right_panel_id==2 and COLORS.Green or COLORS.Dim);
        if GuiButton(gui, _nid(), _picker_x_base + _picker_width, _picker_y_base, "Loadouts", 1) then
          right_panel_picker(2);
        end
        GuiGuideTip(gui, "Spell Loadouts menu", "Create and Buy spell loadouts");
        GuiZSetForNextWidget(gui, __layer(3));
        GuiEndAutoBoxNinePiece(gui, 2);
      end

      local x_base = 2;
      local x_offset = 25;
      local y_base = 348;
      local y_expand = 40;

      GuiZSetForNextWidget(gui, __layer(1));
      GuiColorNextWidgetEnum(gui, COLORS.Tip);
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);

      if GuiButton(gui, _nid(), x_base + x_offset, y_base, persistence_expanded and "-close-" or "persistence", 1) then
        _toggle_state();
      end
      if persistence_expanded==false then GuiGuideTip(gui, "HOTKEY: ` (aka Tilde / Grave)", ""); end

      if persistence_expanded==false then
        GuiZSet(gui, __layer(0)); ---gui frame
        GuiImageNinePiece(gui, _nid(), x_base, y_base, 50, 10);
      else
        GuiZSet(gui, __layer(0)); ---gui frame
        GuiImageNinePiece(gui, _nid(), x_base, y_base - y_expand, 48, 10 + y_expand);
        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, (wands_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 40, "wands", 1) or _hotkey==1 then
          if wands_open==false then
            present_money();
            present_wands();
            right_panel_picker(1);
            close_purchase_spells();
            close_inventory_spells();
            close_modify_wand();
          else
            _toggle_state();
          end
        end
        GuiGuideTip(gui, "Wands Menu    HOTKEY: ` (aka Tilde/Grave)", "Research, Recycle, Create, and Modify wands");

        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, ((purchase_spells_open or inventory_spells_open) and COLORS.Green or COLORS.Dark));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        local _btn1 = GuiButton(gui, _nid(), x_base + x_offset, y_base - 28, "spells:", 1) or _hotkey==2

        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, (purchase_spells_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        local _btn2 = GuiButton(gui, _nid(), x_base + x_offset, y_base - 19, "purchase", 1) or _hotkey==2
        if _btn1==true or _btn2==true then
          if purchase_spells_open==false then
            present_money();
            present_purchase_spells();
            close_wands();
            close_inventory_spells();
            right_panel_picker(2);
            close_modify_wand();
          else
            _toggle_state();
          end
        end
        GuiGuideTip(gui, "Purchase Spells menu    HOTKEY: Shift+` (aka Tilde / Grave)", "Purchase spells you've researched");

        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, (inventory_spells_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 11, "research", 1) or _hotkey==3 then
          if inventory_spells_open==false then
            present_money();
            present_inventory_spells();
            right_panel_picker(2);
            close_wands();
            close_purchase_spells();
            close_modify_wand();
          else
            _toggle_state();
          end
        end
        GuiGuideTip(gui, "Research Spells menu    HOTKEY: Ctrl+` (aka Tilde / Grave)", "Research spells from your inventory");
      end
    end
  end

  function present_persistence_menu()
    if persistence_open==true then return; end

    draw_persistence_menu();
    persistence_open = true;
  end

  function close_persistence_menu()
    if persistence_open==false then return; end

    active_windows["persistence"] = nil;
    persistence_open = false;
  end

  print("=========================");
  print("persistence: Persistence Menu loaded.");

  persistence_menu_loaded=true;
end