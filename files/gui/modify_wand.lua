if modify_wand_loaded~=true then
  modify_wand_open=false;

  modify_wand_table = {
    id = "modify_wand",
    centertext = "CREATE YOUR WAND",
    greentext = "Stats are limited to researched values.",
    redtext = "Better wands cost more. No refunds.",
    slot_title = "Wand slot %i:",
    render_slot_func = __render_wand_slot,
    render_header_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        local row1_y_offset = 2;
        local row2_y_offset = 11;
        local row3_y_offset = 18;
        local x_offset = 6;
        slot_data.price = get_wand_buy_price(slot_data.wand);

        local _tmp_price = slot_data.price;
        if slot_data.origin_e_id~=nil and slot_data.origin_e_id~=0 then
          local _var_comp = EntityGetFirstComponentIncludingDisabled(slot_data.origin_e_id, "VariableStorageComponent", "persistence_wand_price") or 0;
          local _origin_price = ComponentGetValue(_var_comp, "value_int");
          _tmp_price = _tmp_price - _origin_price;
          GuiZSetForNextWidget(gui, __layer(layer));
          GuiColorNextWidgetEnum(gui, COLORS.Dim);
          GuiText(gui, x_base + x_offset, y_base + row2_y_offset, string.format("Paid: $ %i", _origin_price, small_text_scale));
        end

        GuiZSetForNextWidget(gui, __layer(layer));
        GuiColorNextWidgetBool(gui, last_known_money >= _tmp_price);
        if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, string.format("Purchase: $ %1.0f", _tmp_price)) and _tmp_price <= get_player_money() then
          if slot_data.origin_e_id~=nil and slot_data.origin_e_id~=0 then
            modify_wand_entity(slot_data);
            GamePrintImportant("Wand Modified");
          else
            slot_data.wand.price = _tmp_price;
            purchase_wand(slot_data.wand);
            GamePrintImportant("Wand Purchased");
          end
          close_open_windows();
          return true;
        end
      end,
    datum_translation = {
      -- <name>              = {<label>,                        <val_func>,  <height>,  <render_func>,            <widget_func>              cost_formula_func },
      _index = {[0] = 10, [1] = "wand_type", [2] = "shuffle", [3] = "spells_per_cast", [4] = "cast_delay", [5] = "recharge_time", [6] = "mana_max", [7] = "mana_charge_speed", [8] = "capacity", [9] = "spread", [10] = "always_cast_spells"},
      wand_type           = {"",                               __val,      34,       __render_wand_type,     nil,                       __cost_func_wand_type  },
      shuffle             = {"$inventory_shuffle",             __yesno,    9,        __render_gen_stat,      __widget_toggle,           __cost_func_shuffle  },
      spells_per_cast     = {"$inventory_actionspercast",      __val,      9,        __render_gen_stat,      __widget_slider,           __cost_func_spells_per_cast  },
      cast_delay          = {"$inventory_castdelay",           __ctime,    9,        __render_gen_stat,      __widget_slider,           __cost_func_cast_delay  },
      recharge_time       = {"$inventory_rechargetime",        __ctime,    9,        __render_gen_stat,      __widget_slider,           __cost_func_recharge_time  },
      mana_max            = {"$inventory_manamax",             __round,    9,        __render_gen_stat,      __widget_slider,           __cost_func_mana_max  },
      mana_charge_speed   = {"$inventory_manachargespeed",     __val,      9,        __render_gen_stat,      __widget_slider,           __cost_func_mana_charge_speed  },
      capacity            = {"$inventory_capacity",            __val,      9,        __render_gen_stat,      __widget_slider,           __cost_func_capacity  },
      spread              = {"$inventory_spread",              __deg,      9,        __render_gen_stat,      __widget_slider,           __cost_func_spread  },
      always_cast_spells  = {"$inventory_alwayscasts",         __val,      9,        __render_wand_spells,    nil,                      __cost_func_always_cast_spells  },
    },
    slot_func = get_modify_wand_table,
    slot_data = {};
  };


  local function draw_modify_wand(entity_id, slot_id)
    --init
    mod_wand_e_id = entity_id or 0;
    mod_wand_s_id = slot_id or 0;
    local _reload_data = true;
    local datum_sort_funcs = {
      _index = {[0]=10, [1]="sort_name", [2]="sort_cost_name", [3]="sort_type_name", [4]="sort_type_cost", [5]="sort_draw", [6]="sort_uses", [7]="sort_mana", [8]="sort_delay", [9]="sort_recharge", [10]="sort_crit" },
      sort_name = { "Name", function (a, b)
        return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name)));
        end },
      sort_cost_name = {"Cost", function (a, b)
        if (a.price==b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.price<b.price;
        end },
      sort_type_name = {"Type,Name", function (a, b)
        if (a.type==b.type) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.type<b.type;
        end },
      sort_type_cost = {"Type,Cost", function (a, b)
        if (a.type==b.type) and (a.price)==(b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if (a.type==b.type) then return (a.price<b.price); end
        return a.type<b.type;
        end },
      sort_draw = {GameTextGetTranslatedOrNot("$inventory_actiontype_drawmany"), function (a, b)
        if (actions_by_id[a.a_id].c.draw_actions==actions_by_id[b.a_id].c.draw_actions) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].c.draw_actions~=nil and actions_by_id[b.a_id].c.draw_actions==nil then return true; end
        if actions_by_id[a.a_id].c.draw_actions==nil and actions_by_id[b.a_id].c.draw_actions~=nil then return false; end
        if actions_by_id[a.a_id].c.draw_actions>1 and actions_by_id[b.a_id].c.draw_actions<2 then return true; end
        if actions_by_id[a.a_id].c.draw_actions<2 and actions_by_id[b.a_id].c.draw_actions>1 then return false; end
        return actions_by_id[a.a_id].c.draw_actions<actions_by_id[b.a_id].c.draw_actions;
        end },
      sort_uses = {GameTextGetTranslatedOrNot("$inventory_usesremaining"), function (a, b)
        if (actions_by_id[a.a_id].max_uses==actions_by_id[b.a_id].max_uses) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].max_uses~=nil and actions_by_id[b.a_id].max_uses==nil then return true; end
        if actions_by_id[a.a_id].max_uses==nil and actions_by_id[b.a_id].max_uses~=nil then return false; end
        return actions_by_id[a.a_id].max_uses<actions_by_id[b.a_id].max_uses;
        end },
      sort_mana = {GameTextGetTranslatedOrNot("$inventory_manadrain"), function (a, b)
        if (actions_by_id[a.a_id].mana==actions_by_id[b.a_id].mana) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].mana~=nil and actions_by_id[b.a_id].mana==nil then return true; end
        if actions_by_id[a.a_id].mana==nil and actions_by_id[b.a_id].mana~=nil then return false; end
        return actions_by_id[a.a_id].mana<actions_by_id[b.a_id].mana;
        end },
      sort_delay = {GameTextGetTranslatedOrNot("$inventory_castdelay"), function (a, b)
        if (actions_by_id[a.a_id].c.fire_rate_wait==actions_by_id[b.a_id].c.fire_rate_wait) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].c.fire_rate_wait~=nil and actions_by_id[b.a_id].c.fire_rate_wait==nil then return true; end
        if actions_by_id[a.a_id].c.fire_rate_wait==nil and actions_by_id[b.a_id].c.fire_rate_wait~=nil then return false; end
        return actions_by_id[a.a_id].c.fire_rate_wait<actions_by_id[b.a_id].c.fire_rate_wait;
        end },
      sort_recharge = {GameTextGetTranslatedOrNot("$inventory_mod_rechargetime"), function (a, b)
        if (actions_by_id[a.a_id].c.reload_time==actions_by_id[b.a_id].c.reload_time) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].c.reload_time~=nil and actions_by_id[b.a_id].c.reload_time==nil then return true; end
        if actions_by_id[a.a_id].c.reload_time==nil and actions_by_id[b.a_id].c.reload_time~=nil then return false; end
        return actions_by_id[a.a_id].c.reload_time<actions_by_id[b.a_id].c.reload_time;
        end },
      sort_crit = {GameTextGetTranslatedOrNot("$inventory_mod_critchance"), function (a, b)
        if (actions_by_id[a.a_id].c.damage_critical_chance==actions_by_id[b.a_id].c.damage_critical_chance) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if actions_by_id[a.a_id].c.damage_critical_chance~=nil and actions_by_id[b.a_id].c.damage_critical_chance==nil then return false; end
        if actions_by_id[a.a_id].c.damage_critical_chance==nil and actions_by_id[b.a_id].c.damage_critical_chance~=nil then return true; end
        return actions_by_id[a.a_id].c.damage_critical_chance>actions_by_id[b.a_id].c.damage_critical_chance;
        end },
    };

    local _window_display = 0;
    local _active_sort_idx = 1;
    local _active_sort_name = datum_sort_funcs._index[_active_sort_idx];
    local _sorted = false;
    local _search_for = "";
    local _active_filter = 99;
    local _ac_sel_count = 0;
    local _ac_id_hash = {};

    active_windows["modify_wand"] = function(_nid)
      local function _gui_nop(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid) return; end

      if _reload_data~=false then modify_wand_table.slot_data = modify_wand_table.slot_func(mod_wand_e_id); _reload_data=false; end

      local x_base = 30;
      local y_base = 20;
      local margin = 4;
      local width = 448;
      local height = 200;
      local x_offset = x_base + margin;
      local y_offset = y_base + margin;
      local panel_width = 104;
      local panel_height = height - (margin * 2);
      GuiZSet(gui, __layer(0)); ---gui frame
      GuiImageNinePiece(gui, _nid(), x_base, y_base, width, height);

      local panel_x_offset = x_offset;
      GuiZSet(gui, __layer(1)); ---panel border
      GuiImageNinePiece(gui, _nid(), panel_x_offset, y_offset, panel_width, panel_height);

      local panel_sub_width = panel_width - (margin*2);
      local panel_sub_height = panel_height - (margin*2);
      panel_x_offset = panel_x_offset;
      panel_y_offset = y_offset;

      local header_x_pos = panel_x_offset;
      local header_y_pos = panel_y_offset;

      local label_x_pos = panel_x_offset + 23;
      local label_y_pos = header_y_pos + 27;
      GuiZSetForNextWidget(gui, __layer(2)); ---slot label
      GuiText(gui, label_x_pos, label_y_pos, string.format(modify_wand_table.slot_title, mod_wand_s_id), 1);

      local slot_x_pos = panel_x_offset + margin;
      local slot_y_pos = label_y_pos + 12;
      panel_sub_width = panel_width - (margin*2);
      panel_sub_height = panel_sub_height - (slot_y_pos - y_offset - margin);
      (modify_wand_table.render_slot_func or _gui_nop)(slot_x_pos, slot_y_pos, margin, panel_sub_width, panel_sub_height, 2, modify_wand_table.slot_data, _nid);

      local datum_x_pos = panel_x_offset + margin;
      local datum_y_pos = slot_y_pos + margin;

      local widget_x_pos = x_offset + panel_width + (margin * 2);
      local widget_y_pos = y_offset + margin;
      local widget_width = width - panel_width - (margin * 6);

      modify_wand_table.slot_data.cost = {};
      for ii = 1, modify_wand_table.datum_translation._index[0] do
        local _member = modify_wand_table.datum_translation._index[ii];
        local _value = modify_wand_table.slot_data.wand[_member];
        local _valfunc = modify_wand_table.datum_translation[_member][2];
        local _height = modify_wand_table.datum_translation[_member][3] or 0;
        modify_wand_table.slot_data.value = _valfunc(_value);
        modify_wand_table.slot_data.member = _member;
        modify_wand_table.slot_data.label = (modify_wand_table.datum_translation[_member][1]~=nil and modify_wand_table.datum_translation[_member][1]~="") and GameTextGetTranslatedOrNot(modify_wand_table.datum_translation[_member][1]) or "";
        modify_wand_table.slot_data.render_slots_override = get_always_cast_count();
        modify_wand_table.slot_data.research=nil;
        modify_wand_table.slot_data.color_val=nil;
        modify_wand_table.slot_data.cost_func=modify_wand_table.datum_translation[_member][6];
        local _renderfunc = modify_wand_table.datum_translation[_member][4] or _gui_nop;
        _renderfunc(datum_x_pos, datum_y_pos, margin, panel_width - margin, panel_height, 3, modify_wand_table.slot_data, _nid);
        datum_y_pos = datum_y_pos + _height;
        local _widgetfunc = modify_wand_table.datum_translation[_member][5] or _gui_nop;

        if _window_display==0 then ---- Render setting sliders
          if _widgetfunc~=_gui_nop then
            GuiZSet(gui, __layer(2));
            GuiBeginAutoBox(gui);
            local _newvalue = _widgetfunc(widget_x_pos, widget_y_pos, margin, widget_width - (margin * 2), panel_height, 3, modify_wand_table.slot_data, _nid);
            modify_wand_table.slot_data.wand[_member] = _newvalue;
            GuiZSet(gui, __layer(2));
            GuiEndAutoBoxNinePiece(gui, margin-2, widget_width, 10);
            local _height = select(7, GuiGetPreviousWidgetInfo(gui));
            widget_y_pos = widget_y_pos + _height + (margin - 1);
          end
        end
      end

      if _window_display==1 then ---- Render icon picker
        ---right panel border
        GuiZSet(gui, __layer(2));
        GuiBeginScrollContainer(gui, _nid(), widget_x_pos, y_offset, width - panel_width - (margin * 6), panel_height - margin);
        local line_gap = 60;
        local icon_gap_x = 48;
        local _type_idx = 0;
        for _type_name, _type_known in pairs(modify_wand_table.slot_data.bounds["wand_types"]) do
          if _type_known==true then
            local _type_data = wands_by_type[_type_name];

            _type_idx = _type_idx + 1;
            local _type_x_offset = 24 + (((_type_idx - 1) % 6) * icon_gap_x);
            local _type_y_offset = 10 + math.floor((_type_idx - 1) / 6) * (line_gap);

            local wand_offset_x, wand_offset_y = get_wand_rotated_offset(_type_data.grip_x, _type_data.grip_y, -45);

            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter)
            GuiZSetForNextWidget(gui, __layer(3))
            if GuiButton(gui, _nid(), _type_x_offset + 16, widget_y_pos + _type_y_offset - 4, "Select") then
              modify_wand_table.slot_data.wand["wand_type"] = _type_name;
              _window_display=-1;
              break;
            end
            local gui_icon = (select(3, GuiGetPreviousWidgetInfo(gui))) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";

            local frame_offset_x = 7;
            local frame_offset_y = -11;

            GuiZSetForNextWidget(gui, __layer(3))
            GuiImage(gui, _nid(), _type_x_offset, y_offset + _type_y_offset, gui_icon, 1, 1.5, 1.5, math.rad(-90)); -- radians are annoying
            GuiZSetForNextWidget(gui, __layer(4))
            GuiImage(gui, _nid(), _type_x_offset + frame_offset_x + wand_offset_x, widget_y_pos + _type_y_offset + frame_offset_y - wand_offset_y, _type_data.file, 1, 1, 1, math.rad(-45)); -- radians are annoying
          end
        end
      elseif _window_display==2 then --- Render Always Cast Spell picker
        GuiZSetForNextWidget(gui, __layer(2));
        if GuiButton(gui, _nid(), 400, 6, "Sort: " .. datum_sort_funcs[_active_sort_name][1] ) then
          _active_sort_idx = (_active_sort_idx<datum_sort_funcs._index[0]) and (_active_sort_idx + 1) or 1;
          _active_sort_name = datum_sort_funcs._index[_active_sort_idx];
          _sorted = false;
        end
        if select(2, GuiGetPreviousWidgetInfo(gui)) then
          _active_sort_idx = (_active_sort_idx>1) and (_active_sort_idx - 1) or datum_sort_funcs._index[0];
          _active_sort_name = datum_sort_funcs._index[_active_sort_idx];
          _sorted = false;
        end
        GuiGuideTip(gui, "Click to change sort order", "Right-click to move backward");

        if _sorted~=true then table.sort(modify_wand_table.slot_data.ac_spells, datum_sort_funcs[_active_sort_name][2]); _sorted=true;  end

        GuiZSetForNextWidget(gui, __layer(2));
        GuiText(gui, 240, 6, "Search:", 1);
        GuiZSetForNextWidget(gui, __layer(2));
        _search_for = GuiTextInput(gui, _nid(), 270, 5, _search_for, 100, 20);
        GuiGuideTip(gui, "Search by name, #description. Right-click to clear", "Multiple search (AND) by space or comma");
        if select(2, GuiGetPreviousWidgetInfo(gui))  then _search_for = ""; end

        local _f_idx = 1;
        GuiZSetForNextWidget(gui, __layer(2));
        GuiText(gui, 26, 6, "Filter:");
        GuiGuideTip(gui, "Show only spells which match selected type", "")
        for _type_nr, _type_bool in pairs(modify_wand_table.slot_data.ac_spells._index.type_hash) do
          if _type_bool then
            if _type_nr~=99 then
              _f_idx = _f_idx + 1;
            end
            local _filter_x_offset = 40 + ( (_type_nr==99 and 1 or _f_idx) * 20);
            GuiZSetForNextWidget(gui, __layer(2));
            if GuiImageButton(gui, _nid(), _filter_x_offset, 1, "", action_type_to_slot_sprite(_type_nr)) then
              if _active_filter~=_type_nr then
                _active_filter = _type_nr;
              else
                _active_filter = 99;
              end
            end

            GuiZSetForNextWidget(gui, __layer(2));
            GuiTooltip(gui, _type_nr==99 and "ALL" or action_type_to_string(_type_nr), "");
            if _type_nr==_active_filter then
              local _mark_offset_x = 10;
              local _mark_offset_y = 8;
              GuiZSetForNextWidget(gui, __layer(3));
              GuiImage(gui, _nid(), _filter_x_offset + _mark_offset_x, _mark_offset_y, "data/ui_gfx/damage_indicators/explosion.png", 0.5, 1, 1, math.rad(45)); -- radians are annoying
            end
          end
        end


        ---right panel border
        GuiZSet(gui, __layer(2));
        GuiBeginScrollContainer(gui, _nid(), widget_x_pos, y_offset, width - panel_width - (margin * 6), panel_height - margin);
        local spell_y_offset = margin;
        local spell_y_height = 26;
        _ac_id_hash = {};
        _ac_sel_count = 0;

        for _sel_ac_idx, _sel_ac_name in pairs(modify_wand_table.slot_data.wand.always_cast_spells) do
          ---- Render currently selected AC spells -- do not touch
          __render_spell_listentry(margin, spell_y_offset, margin, panel_width, panel_height, 3, get_spell_purchase_single(_sel_ac_name), _nid);
          GuiZSetForNextWidget(gui, __layer(3));
          GuiColorNextWidgetEnum(gui, COLORS.Dim);
          GuiText(gui, margin, spell_y_offset + 10, string.format(" $ %1.0f", math.ceil(__get_ac_raw_cost(_ac_name) * mod_setting.buy_spell_price_multiplier)) );
          GuiZSetForNextWidget(gui, __layer(3));
          GuiColorNextWidgetEnum(gui, COLORS.Yellow);
          if GuiButton(gui, _nid(), margin, spell_y_offset, __yesno(true)) then
              table.remove(modify_wand_table.slot_data.wand.always_cast_spells, _sel_ac_idx);
          end
          GuiGuideTip(gui, "Remove Always Casts spell", "");
          _ac_id_hash[_sel_ac_name]=true;
          _ac_sel_count = _ac_sel_count + 1;
          spell_y_offset = spell_y_offset + 26;
        end

        for _ac_idx = 1, modify_wand_table.slot_data.ac_spells._index.count do
          local _ac_name = modify_wand_table.slot_data.ac_spells[_ac_idx].a_id;
          local show_curr_spell = true;
          if _search_for~="" then show_curr_spell=check_search_for(modify_wand_table.slot_data.ac_spells, _search_for); end
          if _active_filter~=99 and _active_filter~=actions_by_id[_ac_name].type then
            show_curr_spell = false;
          end

          if show_curr_spell==true then
            if _ac_id_hash[_ac_name]~=true then
              __render_spell_listentry(margin, spell_y_offset, margin, panel_width, panel_height, 3, modify_wand_table.slot_data.ac_spells[_ac_idx], _nid);
              GuiZSetForNextWidget(gui, __layer(3));
              GuiColorNextWidgetEnum(gui, COLORS.Tip);
              GuiText(gui, margin, spell_y_offset + 10, string.format(" $ %0.0f", math.ceil(__get_ac_raw_cost(_ac_name) * mod_setting.buy_spell_price_multiplier)));
              GuiZSetForNextWidget(gui, __layer(3));
              local _fit_more = _ac_sel_count < get_always_cast_count();
              GuiColorNextWidgetBool(gui, _fit_more);
              if GuiButton(gui, _nid(), margin, spell_y_offset, __yesno(false)) and (_fit_more) then
                table.insert(modify_wand_table.slot_data.wand.always_cast_spells, _ac_name);
              end
              GuiGuideTip(gui, _fit_more and "Add Always Casts spell" or "Can't fit more", "Quantity limited by researched wands");
              spell_y_offset = spell_y_offset + 26;
            end
          end
        end
      end
      if _window_display~=0 then GuiEndScrollContainer(gui); end;

      if _window_display<0 then _window_display=0; end

      local icon_x_base = x_base + 46;
      local icon_y_base = slot_y_pos + margin + 8;
      ---gui button for icon pick, always cast pick
      GuiZSetForNextWidget(gui, __layer(3));
      if _window_display==1 then 
        GuiColorNextWidgetEnum(gui, COLORS.Green);
      elseif _window_display==2 then 
        GuiColorNextWidgetEnum(gui, COLORS.Dim);
      else
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
      end
      if GuiButton(gui, _nid(), icon_x_base, icon_y_base, "[WAND TYPE]", small_text_scale) then
        _window_display = _window_display~=1 and 1 or 0;
        -- GamePrint("Pick wand type");
      end
      GuiGuideTip(gui, "Adjust Wand Type aka Icon", "Cosmetic only, for visual identification. Click to toggle window");
      local sel_ac_x_base = x_base + 54;
      local sel_ac_y_base = slot_y_pos + panel_sub_height - 10;
      GuiZSetForNextWidget(gui, __layer(3));
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
      if _window_display==1 then 
        GuiColorNextWidgetEnum(gui, COLORS.Dim);
      elseif _window_display==2 then 
        GuiColorNextWidgetEnum(gui, COLORS.Green);
      else
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
      end
      if GuiButton(gui, _nid(), sel_ac_x_base, sel_ac_y_base, "[ALWAYS CASTS]", small_text_scale) then
        _window_display = _window_display~=2 and 2 or 0;
        -- GamePrint("Pick always casts");
      end
      GuiGuideTip(gui, "Adjust Always Casts spells", "Click to toggle window");

      if (modify_wand_table.render_header_func or _gui_nop)(header_x_pos, header_y_pos, margin, panel_sub_width, panel_sub_height, 2, modify_wand_table.slot_data, _nid) then
        _reload_data = true;
      end
      __render_tricolor_footer(x_base, y_base, width, height, modify_wand_table);
    end
  end

  function present_modify_wand(entity_id, slot_id)
    if modify_wand_open==true then return; end

    close_wands();
    draw_modify_wand(entity_id, slot_id);
    modify_wand_open=true;
  end

  function close_modify_wand()
    if modify_wand_open==false then return; end

    active_windows["modify_wand"] = nil;
    modify_wand_open = false;
  end

  print("=========================");
  print("persistence: Modify Wand loaded.");
  modify_wand_loaded=true;
end