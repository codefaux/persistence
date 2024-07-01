if persistence_menu_loaded~=true then
  dofile_once("data/scripts/debug/keycodes.lua");
  persistence_open=false;

  local function draw_persistence_menu()
    persistence_expanded = false;
    local _right_panel_id = 0;

    active_windows["persistence"] = function (_nid)
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

      local function _toggle_state()
        if persistence_expanded then
          _right_panel_id = 0;
          close_open_windows();
          persistence_expanded=false;
        else
          -- Windows to open w/ Persistence menu
          present_money();
          present_wands();
          right_panel_picker(1);
          -- close_wand_template();
          -- present_spell_loadouts();
          -- -- present_wand_template();
          -- -- close_spell_loadouts();
          close_purchase_spells();
          close_inventory_spells();
          close_modify_wand();

          persistence_expanded=true;
        end
      end

      if InputIsKeyJustDown(Key_GRAVE) and not _keywait then
        _keywait = true;
        _toggle_state();
      end
      if _keywait and not InputIsKeyJustDown(Key_GRAVE) then
        _keywait = false;
      end

      local _picker_x_base = 488;
      local _picker_y_base = 134;
      local _picker_height = 10;
      local _picker_width = 134;

      if _right_panel_id~=0 then
        -- GuiZSetForNextWidget(gui, _layer(3));
        GuiBeginAutoBox(gui);
        GuiZSetForNextWidget(gui, _layer(4));
        GuiColorNextWidgetEnum(gui, _right_panel_id==1 and COLORS.Green or COLORS.Dim);
        if GuiButton(gui, _nid(), _picker_x_base, _picker_y_base, "Templates", 1) then
          right_panel_picker(1);
        end
        GuiZSetForNextWidget(gui, _layer(3));
        GuiEndAutoBoxNinePiece(gui, 2);

        -- GuiZSetForNextWidget(gui, _layer(3));
        GuiBeginAutoBox(gui);
        GuiZSetForNextWidget(gui, _layer(4));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
        GuiColorNextWidgetEnum(gui, _right_panel_id==2 and COLORS.Green or COLORS.Dim);
        if GuiButton(gui, _nid(), _picker_x_base + _picker_width, _picker_y_base, "Loadouts", 1) then
          right_panel_picker(2);
        end
        GuiZSetForNextWidget(gui, _layer(3));
        GuiEndAutoBoxNinePiece(gui, 2);
      end

      local x_base = 2;
      local x_offset = 25;
      local y_base = 348;
      local y_expand = 40;

      GuiZSetForNextWidget(gui, _layer(1));
      GuiColorNextWidgetEnum(gui, COLORS.Tip);
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
      if GuiButton(gui, _nid(), x_base + x_offset, y_base, persistence_expanded and "-close-" or "persistence", 1) then
        _toggle_state();
      end

      if persistence_expanded==false then
        GuiZSet(gui, _layer(0)); ---gui frame
        GuiImageNinePiece(gui, _nid(), x_base, y_base, 50, 10);
      else
        GuiZSet(gui, _layer(0)); ---gui frame
        GuiImageNinePiece(gui, _nid(), x_base, y_base - y_expand, 48, 10 + y_expand);
        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, (wands_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 40, "wands", 1) then
          present_money();
          present_wands();
          right_panel_picker(1);
          -- present_spell_loadouts();
          -- -- present_wand_template();
          -- close_wand_template();
          -- -- close_spell_loadouts();
          close_purchase_spells();
          close_inventory_spells();
          close_modify_wand();
        end

        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, ((purchase_spells_open or inventory_spells_open) and COLORS.Green or COLORS.Dark));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 28, "spells:", 1) then
          present_money();
          present_purchase_spells();
          right_panel_picker(2);
          -- present_spell_loadouts();
          -- close_wand_template();
          close_wands();
          close_inventory_spells();
          close_modify_wand();
        end

        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, (purchase_spells_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 19, "purchase", 1) then
          present_money();
          present_purchase_spells();
          close_wands();
          close_inventory_spells();
          right_panel_picker(2);
          -- present_spell_loadouts();
          -- close_wand_template();
          close_modify_wand();
        end


        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, (inventory_spells_open and COLORS.Green or COLORS.Bright));
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base - 11, "research", 1) then
          present_money();
          present_inventory_spells();
          right_panel_picker(2);
          -- present_spell_loadouts();
          -- close_wand_template();
          close_wands();
          close_purchase_spells();
          close_modify_wand();
        end
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