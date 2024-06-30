if wand_template_loaded~=true then
  template_open=false;

  local function draw_wand_template()
    local _reload_data = true;
    local template_previews = {};
    local template_confirmation = 0;
    local template_hover = 0;
    local margin=5;
    local x_base = 485;
    local y_base = 150;
    local width = 140;
    local height = 200;
    local line_height = 11;
    local block_height = (line_height * 3) + margin;

    active_windows["template"] = function (_nid)
      local function _gui_nop(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid) return; end

      if _reload_data then template_previews = get_templates(); _reload_data=false; end

      GuiZSetForNextWidget(gui, _layer(0));
      GuiImageNinePiece(gui, _nid(), x_base, y_base, width, height);
      template_hover = 0;
      for i = 1, get_template_count() do
        local x_offset = x_base + margin;
        local y_offset = y_base + margin + ((i - 1) * block_height);
        local col_a = 45;
        local col_b = 90;
        GuiZSetForNextWidget(gui, _layer(1));
        GuiText(gui, x_offset, y_offset, "Template Slot " .. i .. ":");
        if modify_wand_open then
          if template_previews[i]==nil or template_previews[i].capacity==nil then  -- Template empty
            GuiZSetForNextWidget(gui, _layer(1));
            GuiColorNextWidgetEnum(gui, COLORS.Green);
            if GuiButton(gui, _nid(), x_offset + col_b, y_offset + (line_height * 1), "Save") then
              set_template(i, modify_wand_table.slot_data.wand);
              _reload_data = true;
            end
          else
            if template_confirmation == i then
              GuiZSetForNextWidget(gui, _layer(1));
              GuiColorNextWidgetEnum(gui, COLORS.Green);
              if GuiButton(gui, _nid(), x_offset + col_b, y_offset + (line_height * 1), "CONFIRM") then
                set_template(i, modify_wand_table.slot_data.wand);
                template_confirmation = 0;
                _reload_data = true;
              end
            else
              GuiZSetForNextWidget(gui, _layer(1));
              GuiColorNextWidgetEnum(gui, COLORS.Green);
              if GuiButton(gui, _nid(), x_offset + col_b, y_offset + (line_height * 1), "Update") then
                template_confirmation = i;
              end
            end
            GuiZSetForNextWidget(gui, _layer(1));
            GuiColorNextWidgetEnum(gui, COLORS.Green);
            if GuiButton(gui, _nid(), x_offset + col_b, y_offset + (line_height * 2), "Load") then
              -- GamePrint("Load Template");
              modify_wand_table.slot_data.wand = get_template(i);
            end

          end
        end

        if template_previews~=nil and template_previews[i]~=nil and template_previews[i].capacity~=nil then        
          local _affordable = template_previews[i].price<=last_known_money;

          GuiZSetForNextWidget(gui, _layer(1));
          GuiImage(gui, _nid(), x_offset + 10, y_offset + 12, wand_type_to_sprite_file(template_previews[i].wand_type), 1, 1, 1, math.rad(0)); -- radians are annoying

          GuiZSetForNextWidget(gui, _layer(1));
          GuiColorNextWidgetBool(gui, _affordable);
          if GuiButton(gui, _nid(), x_offset, y_offset + (line_height * 2), string.format(" $ %i", template_previews[i].price)) then
            -- GamePrint("Buy Template");
            purchase_wand(get_template(i));
          end

          GuiZSetForNextWidget(gui, _layer(1));
          GuiColorNextWidgetBool(gui, _affordable);
          if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 1), "Buy") then
            -- GamePrint("Buy Template");
            purchase_wand(get_template(i));
          end

          if template_confirmation == -i then
            GuiZSetForNextWidget(gui, _layer(1));
            GuiColorNextWidgetEnum(gui, COLORS.Yellow);
            if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 2), "CONFIRM") then
              template_confirmation = 0;
              delete_template(i);
              _reload_data = true;
              -- GamePrint("Delete Template");
            end
          else
            GuiZSetForNextWidget(gui, _layer(1));
            GuiColorNextWidgetEnum(gui, COLORS.Yellow);
            if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 2), "Delete") then
              template_confirmation = -i;
            end
          end

          local _x_mouse, _y_mouse = InputGetMousePosOnScreen();
          local _x_min = x_base;
          local _width = width;
          local _y_min = y_offset;
          local _height = line_height * 3;

          if _x_mouse/2>_x_min and _x_mouse/2<_x_min+_width then
            if _y_mouse/2>_y_min and _y_mouse/2<_y_min+_height then
              template_hover = i;
            end
          end
        end

        if template_hover == i then
          local _preview_datum_x_pos = 2;
          local _preview_datum_y_pos = 2;
          local _preview_x_loc = 375;
          local _preview_y_loc = 240;
          local _preview_panel_width = 90;
          local _preview_panel_height = 105;
          GuiZSetForNextWidget(gui, _layer(2));
          GuiBeginScrollContainer(gui, _nid(), _preview_x_loc, _preview_y_loc, _preview_panel_width, _preview_panel_height);
          for ii = 2, modify_wand_table.datum_translation._index[0] do
            local _member = modify_wand_table.datum_translation._index[ii];
            local _value = template_previews[i][_member];
            local _valfunc = modify_wand_table.datum_translation[_member][2];
            local _height = modify_wand_table.datum_translation[_member][3] or 0;
            local _data = {cost = {}};
            _data.wand = template_previews[i];
            _data.value = _valfunc(_value);
            _data.member = _member;
            _data.label = (modify_wand_table.datum_translation[_member][1]~=nil and modify_wand_table.datum_translation[_member][1]~="") and GameTextGetTranslatedOrNot(modify_wand_table.datum_translation[_member][1]) or "";
            _data.cost[_member] = (modify_wand_table.datum_translation[_member][6]~=nil and modify_wand_table.datum_translation[_member][6](_value) or 0) * ModSettingGet("persistence.buy_wand_price_multiplier");
            _data.render_slots_override = get_always_cast_count();
            local _renderfunc = modify_wand_table.datum_translation[_member][4] or _gui_nop;
            _renderfunc(_preview_datum_x_pos, _preview_datum_y_pos, margin, _preview_panel_width - margin, _preview_panel_height, 3, _data, _nid);
            _preview_datum_y_pos = _preview_datum_y_pos + _height;
          end
          GuiEndScrollContainer(gui);
        end
      end
    end
  end

  function present_wand_template()
    if template_open==true then return; end

    draw_wand_template();
    template_open = true;
  end

  function close_wand_template()
    if template_open==false then return; end

    active_windows["template"] = nil;
    template_open = false;
  end

  print("=========================");
  print("persistence: Wand template loaded.");
  wand_template_loaded=true;
end