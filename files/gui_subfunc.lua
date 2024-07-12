if gui_subfunc_loaded~=true then
  dofile_once("data/scripts/debug/keycodes.lua");

  ---@enum colors
  COLORS = {
    Red = {1, 0.5, 0.5, 1},
    Green = {0.5, 1, 0.5, 1},
    Blue = {0.25, 0.25, 1, 1},
    Yellow = {1, 1, 0.5, 1},
    Dim = {0.75, 0.75, 0.75, 1},
    Dark = {0.333, 0.333, 0.333, 1},
    Tip = {0.666, 0.666, 0.80, 1},
    Bright = {0.85, 0.9, 1, 1},
    Purple = {1, 0.25, 1, 1},
    White = {1, 1, 1, 1},
    Black = {0, 0, 0, 1}
  }

  table.unpack=table.unpack or unpack;

  ---@param value colors
  function GuiColorNextWidgetEnum(gui, value)
    GuiColorSetForNextWidget(gui, table.unpack(value))
    end

  function GuiColorNextWidgetBool(gui, value)
    if value then
      GuiColorNextWidgetEnum(gui, COLORS.Green);
    else
      GuiColorNextWidgetEnum(gui, COLORS.Red);
    end
  end

  function GuiGuideTip(gui, text, subtext)
    if mod_setting.show_guide_tips==true then
      GuiTooltip(gui, text or "", subtext or "");
    end
  end

  function __render_tricolor_footer(x_base, y_base, width, height, textdata)
    GuiColorNextWidgetEnum(gui, COLORS.Green); ---green text
    GuiZSetForNextWidget(gui, __layer(2));
    GuiText(gui, x_base, height + 25, textdata.greentext, small_text_scale);

    GuiColorNextWidgetEnum(gui, COLORS.Red); ---red text
    GuiZSetForNextWidget(gui, __layer(2));
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
    GuiText(gui, x_base + width, height + 25, textdata.redtext, small_text_scale);

    GuiColorNextWidgetEnum(gui, COLORS.Tip); ---middle text
    GuiZSetForNextWidget(gui, __layer(2));
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
    GuiText(gui, x_base + (width / 2), height + 25, textdata.centertext, 1);
  end

  __show_always = function(_) return true; end
  __show_nz = function(value) return (value~=nil and value~=0) and true or false; end
  __show_many = function(value) return (value~=nil and value>1) and true or false; end

  __val = function(value) if type(value)=="table" then return value; elseif type(value)=="number" then return tostring(value); end return value; end
  __trans = function(value) return GameTextGetTranslatedOrNot(value); end
  __yesno = function(value) return value and "$menu_yes" or "$menu_no"; end
  __time = function(value) return GameTextGet("$inventory_seconds", string.format("%1.2f", value)); end
  __ctime = function(value) return GameTextGet("$inventory_seconds", string.format("%1.2f", math.floor((value / 60) * 100 + 0.5) / 100)); end
  __deg = function(value) return GameTextGet("$inventory_degrees", string.format("%d", value)); end
  __pct = function(value) return GameTextGet("$menu_slider_percentage", value); end
  __round = function(value) return math.floor(value + 0.5); end
  __nil = function(_) return nil; end
  __type = function(value) return action_type_to_string(value); end
  __cntarr = function(value) if type(value)=="table" then return #value; end return -1; end

  function __render_wand_slot(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
    GuiZSet(gui, __layer(layer)); ---gui frame
    GuiImageNinePiece(gui, _nid(), x_base, y_base, panel_width, panel_height);

    local gui_icon = (slot_data.research~=nil and slot_data.research.is_new) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";
    GuiZSetForNextWidget(gui, __layer(layer+1));
    GuiImage(gui, _nid(), x_base, y_base, gui_icon, 1, 1.75, 1.75, 0);
  end


  function __render_wand_sprite(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
    local wand_offset_x, wand_offset_y = get_wand_rotated_offset(0, 0, -45);
    GuiZSetForNextWidget(gui, __layer(layer+1));
    GuiImage(gui, _nid(), x_base + (wand_offset_x * 1.333) + 6, y_base + (-wand_offset_y * 1.333) + 18, slot_data.value, 1, 1.333, 1.333, math.rad(-45));

    if slot_data.research~=nil and slot_data.research.b_wand_types then
      local new_icon = "data/ui_gfx/damage_indicators/explosion.png";
      local new_offset_x = 6;
      local new_offset_y = 0;
      GuiZSetForNextWidget(gui, __layer(layer+2));
      GuiImage(gui, _nid(), x_base + new_offset_x, y_base + new_offset_y, new_icon, 1, 2, 2, math.rad(30)); -- radians are annoying
      GuiGuideTip(gui, "This wand provides a new design", "");
    end
  end


  function __render_wand_type(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
    local wand_offset_x, wand_offset_y = get_wand_rotated_offset(0, 0, -45);
    GuiZSetForNextWidget(gui, __layer(layer+1));
    GuiImage(gui, _nid(), x_base + (wand_offset_x * 1.333) + 6, y_base + (-wand_offset_y * 1.333) + 18, wand_type_to_sprite_file(slot_data.value), 1, 1.333, 1.333, math.rad(-45));

    if slot_data.research~=nil and slot_data.research.b_wand_types then
      local new_icon = "data/ui_gfx/damage_indicators/explosion.png";
      local new_offset_x = 6;
      local new_offset_y = 0;
      GuiZSetForNextWidget(gui, __layer(layer+2));
      GuiImage(gui, _nid(), x_base + new_offset_x, y_base + new_offset_y, new_icon, 1, 2, 2, math.rad(30)); -- radians are annoying
      GuiGuideTip(gui, "This wand provides a new design", "");
    end
  end

  function __render_wand_spells(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
    local _capacity = _data.wand["capacity"] or _data["capacity"];
    local grid_y_offset = _capacity>10 and -5 or 0;
    local grid_x_offset = 34;
    local grid_columns = 5;
    if _data.label~=nil and _data.label~="" then
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiText(gui, x_base + margin, y_base, _data.label, small_text_scale);
      if _data.color_val~=nil then
        if type(_data.color_val)=="boolean" then
          GuiColorNextWidgetBool(gui, _data.color_val);
        elseif type(_data.color_val)=="table" then
          GuiColorNextWidgetEnum(gui, _data.color_val);
        end
      end
      _capacity=#_data.value;
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiText(gui, x_base + panel_width - margin, y_base, tostring(_capacity), small_text_scale);
      if _data.research~=nil then GuiGuideTip(gui, (_data.research~=nil and type(_data.color_val)=="boolean" and _data.color_val==true) and "Contributes to research" or "Does not contribute to research", ""); end
      grid_y_offset = 10;
      grid_x_offset = 6;
      grid_columns = 8;
    end
    for cap_idx = 1, _data.render_slots_override or _capacity do
      local grid_h = 12;
      local grid_x = (((cap_idx-1)%grid_columns) * grid_h);
      local grid_y = (math.floor((cap_idx-1)/grid_columns) * grid_h);
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiImage(gui, _nid(), x_base + grid_x_offset + grid_x, y_base + grid_y_offset + grid_y, "data/ui_gfx/inventory/inventory_box.png", 1, 0.8, 0.8, 0);
      if _data.value[cap_idx] ~= nil then
        local curr_spell_id = _data.value[cap_idx];
        local s_hover = select(3, GuiGetPreviousWidgetInfo(gui));
        if s_hover then
          spell_tooltip_id = curr_spell_id;
          present_spell_tooltip();
        end
        GuiZSetForNextWidget(gui, __layer(layer + 1));
        GuiImage(gui, _nid(), x_base + grid_x_offset + grid_x, y_base + grid_y_offset + grid_y, actions_by_id[curr_spell_id].sprite, 1, 0.8, 0.8, 0);
      end
    end
  end

  function __render_gen_stat(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiText(gui, x_base + margin, y_base, _data.label, small_text_scale);
    if _data.color_val~=nil then
      if type(_data.color_val)=="boolean" then
        GuiColorNextWidgetBool(gui, _data.color_val);
      elseif type(_data.color_val)=="table" then
        GuiColorNextWidgetEnum(gui, _data.color_val);
      end
    end
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiText(gui, x_base + panel_width - margin, y_base, _data.value, small_text_scale);
    if _data.research~=nil then GuiGuideTip(gui, (_data.research~=nil and type(_data.color_val)=="boolean" and _data.color_val==true) and "Contributes to research" or "Does not contribute to research", ""); end
  end

  function __render_spell_listentry(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
    local _offset_x = x_base + 45;
    local _after_icon_x = _offset_x + 20;

    GuiZSetForNextWidget(gui, __layer(layer));
    GuiImage(gui, _nid(), _offset_x-4, y_base -3, _data.type_sprite, 1, 1.2, 1.2); -- background type slot

    GuiZSetForNextWidget(gui, __layer(layer+1));
    GuiImage(gui, _nid(), _offset_x, y_base + 1, _data.sprite, (_data.recyclable~=nil and _data.recyclable==true) and 0.5 or 1, 1, 1, 0); -- Icon
    if _data.recyclable~=nil and _data.recyclable==true then
      GuiColorNextWidgetEnum(gui, COLORS.Dim);
    elseif _data.name_color~=nil then
      GuiColorNextWidgetEnum(gui, _data.name_color);
    end
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiText(gui, _after_icon_x, y_base - 1, GameTextGetTranslatedOrNot(_data.name)); -- Name
    local _edge_x, _edge_y1 = select(8, GuiGetPreviousWidgetInfo(gui));
    if _data.max_uses ~= nil then
      local _x_text_width = select(6, GuiGetPreviousWidgetInfo(gui))
      local _uses_string = "";
      if _data.curr_uses~=nil and _data.curr_uses>-1 and _data.curr_uses~=_data.max_uses then
        _uses_string = _data.curr_uses .. "/" .. _data.max_uses;
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
      else
        _uses_string = _data.max_uses;
        GuiColorNextWidgetEnum(gui, COLORS.Tip);
      end
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiText(gui, _after_icon_x + _x_text_width + 3, y_base - 1, "(" .. _uses_string .. ")"); -- uses
    end

    if _data.recyclable~=nil and _data.recyclable==true then
      GuiColorNextWidgetEnum(gui, COLORS.Dark);
    elseif _data.description_color~=nil then
      GuiColorNextWidgetEnum(gui, _data.description_color);
    else
      GuiColorNextWidgetEnum(gui, COLORS.Dim);
    end
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiText(gui, _after_icon_x, y_base + 8, GameTextGetTranslatedOrNot(_data.description), small_text_scale); -- Description
    local _edge_y2, _, _line_height = select(9, GuiGetPreviousWidgetInfo(gui));

    local _x_mouse, _y_mouse = InputGetMousePosOnScreen();
    if _x_mouse/2>_edge_x-60 and _x_mouse/2<475 then
      if _y_mouse/2>math.max(20, _edge_y1) and _y_mouse/2<math.min(_edge_y2+_line_height, 225) then
        spell_tooltip_id = _data.a_id;
        present_spell_tooltip();
      end
    end
  end

  function __render_spell_gridtile(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiImage(gui, _nid(), x_base, y_base, _data.type_sprite, 1, 1.2, 1.2, 0); -- background type slot

    if _data.empty_slot==nil or _data.empty_slot~=true then
      GuiZSetForNextWidget(gui, __layer(layer+1));
      GuiImage(gui, _nid(), x_base+4, y_base+4, _data.sprite, 1, 1, 1, 0); -- Icon
      if select(3, GuiGetPreviousWidgetInfo(gui)) then
        spell_tooltip_id = _data.a_id or "";
        present_spell_tooltip();
      end

      if _data.max_uses ~= nil then
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiColorNextWidgetEnum(gui, COLORS.Black);
        GuiZSetForNextWidget(gui, __layer(layer+2));
        GuiText(gui, x_base + 12, y_base + 12, "(" .. _data.max_uses .. ")", small_text_scale); -- uses

        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiColorNextWidgetEnum(gui, COLORS.Black);
        GuiZSetForNextWidget(gui, __layer(layer+2));
        GuiText(gui, x_base + 11, y_base + 13, "(" .. _data.max_uses .. ")", small_text_scale); -- uses

        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiColorNextWidgetEnum(gui, COLORS.Black);
        GuiZSetForNextWidget(gui, __layer(layer+2));
        GuiText(gui, x_base + 12, y_base + 14, "(" .. _data.max_uses .. ")", small_text_scale); -- uses

        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiColorNextWidgetEnum(gui, COLORS.Black);
        GuiZSetForNextWidget(gui, __layer(layer+2));
        GuiText(gui, x_base + 13, y_base + 13, "(" .. _data.max_uses .. ")", small_text_scale); -- uses

        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiColorNextWidgetEnum(gui, COLORS.White);
        GuiZSetForNextWidget(gui, __layer(layer+3));
        GuiText(gui, x_base + 12, y_base + 13, "(" .. _data.max_uses .. ")", small_text_scale); -- uses
      end
    end
  end


  function __widget_toggle(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiColorNextWidgetEnum(gui, COLORS.White);
    GuiText(gui, x_base + margin, y_base, slot_data.label, small_text_scale);

    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
    GuiZSetForNextWidget(gui, __layer(layer));
    local _ret = nil;
    GuiColorNextWidgetEnum(gui, COLORS.Yellow);
    if GuiButton(gui, _nid(), x_base + (panel_width / 2), y_base, " [ " .. GameTextGetTranslatedOrNot(slot_data.value) .. " ] ", small_text_scale) then
      _ret = not slot_data.wand[slot_data.member];
    else
      _ret = slot_data.wand[slot_data.member];
    end
    GuiGuideTip(gui, "Click to toggle", "");

    local _cost = math.ceil((slot_data.cost_func(slot_data.wand[slot_data.member]) or 0) * mod_setting.buy_wand_price_multiplier);
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiColorNextWidgetEnum(gui, COLORS.Tip);
    GuiText(gui, x_base + panel_width, y_base, string.format(" $ %1.0f", _cost), small_text_scale);
    GuiGuideTip(gui, "Cost contribution from this stat", "");
    return _ret;
  end

  function __widget_slider(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
    local _x_mouse, _y_mouse = InputGetMousePosOnScreen();
    local _mouse_hover = false;
    local _height = 20;
    local _mouse_scroll = (InputIsMouseButtonJustDown(Mouse_wheel_up) and 1 or 0) + (InputIsMouseButtonJustDown(Mouse_wheel_down) and -1 or 0);
    local _bounds_min = slot_data.bounds[slot_data.member][1];
    local _bounds_max = slot_data.bounds[slot_data.member][2];

    GuiZSetForNextWidget(gui, __layer(layer));
    GuiColorNextWidgetEnum(gui, COLORS.White);
    GuiText(gui, x_base + margin, y_base, slot_data.label, small_text_scale); ---- LABEL
    local _x_min, _y_min = select(8, GuiGetPreviousWidgetInfo(gui));

    GuiZSetForNextWidget(gui, __layer(layer));  ---- SLIDER
    local _ret = math.floor(GuiSlider(gui, _nid(), x_base + margin, y_base + 10, "", slot_data.wand[slot_data.member], _bounds_min, _bounds_max, 0, 1, " ", panel_width ) + 0.5);
    GuiGuideTip(gui, "Scroll Mouse Wheel to quickly adjust", "Hold Shift for 5x\nHold Ctrl for 10x");

    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiColorNextWidgetEnum(gui,  _mouse_hover and COLORS.Green or COLORS.Yellow);
    GuiText(gui, x_base + (panel_width / 2), y_base, slot_data.value, small_text_scale); ---- VALUE
    GuiGuideTip(gui, "Scroll Mouse Wheel to quickly adjust", "Hold Shift for 5x\nHold Ctrl for 10x");

    local _cost = math.ceil((slot_data.cost_func(_ret) or 0) * mod_setting.buy_wand_price_multiplier);

    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
    GuiColorNextWidgetEnum(gui, COLORS.Tip);
    GuiZSetForNextWidget(gui, __layer(layer));
    GuiText(gui, x_base + panel_width, y_base, string.format(" $ %1.0f", _cost), small_text_scale); ---- COST
    GuiGuideTip(gui, "Cost contribution from this stat", "");
    local _x_offset, _, _width = select(8, GuiGetPreviousWidgetInfo(gui));

    if _x_mouse/2>_x_min and _x_mouse/2<_x_offset+_width+15 then
      if _y_mouse/2>_y_min-2 and _y_mouse/2<_y_min+_height then
        _mouse_hover = true;
      end
    end

    if _mouse_hover and _mouse_scroll~=0 then
      local _factor = 1;
      if InputIsKeyDown(Key_LSHIFT) then _factor = _factor * 5; end
      if InputIsKeyDown(Key_LCTRL) then _factor = _factor * 10; end

      _ret =  math.min(math.max( _ret + (_factor * _mouse_scroll), _bounds_min), _bounds_max);
    end

    return math.floor(_ret);
  end

  print("=========================");
  print("persistence: GUI subfunctions loaded.");
  gui_subfunc_loaded=true;
end