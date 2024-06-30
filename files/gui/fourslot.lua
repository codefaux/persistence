if fourslot_loaded~=true then
  profile_open=false;
  wands_open=false;

  profile_fourslot = {
    id = "profile_select",
    centertext = "SELECT A PROFILE",
    greentext = "See Auto-Load in Mod Options",
    redtext = "THERE IS NO UNDO",
    slot_title = "Profile slot %i:",
    render_header_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        local row1_y_offset = 4;
        local row2_y_offset = 14;
        local x_offset = 16;

        GuiZSetForNextWidget(gui, _layer(layer));
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if slot_data.quickloaded~=nil and slot_data.quickloaded==true then
          if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "- Load Profile") then
            selected_profile_id = slot_data.id;
          end
          if fourslot_confirmation == slot_data.id then
            GuiZSetForNextWidget(gui, _layer(layer));
            GuiColorNextWidgetEnum(gui, COLORS.Yellow);
            if GuiButton(gui, _nid(), x_base + x_offset, y_base + row2_y_offset, "- Press again to delete") then
              fourslot_confirmation = 0;
              delete_profile(slot_data.id);
              slot_data.quickloaded = nil;
            end
          else
            GuiZSetForNextWidget(gui, _layer(layer));
            GuiColorNextWidgetEnum(gui, COLORS.Yellow);
            if GuiButton(gui, _nid(), x_base + x_offset, y_base + row2_y_offset, "- Delete profile") then
              fourslot_confirmation = slot_data.id;
            end
          end
        else
          GuiZSetForNextWidget(gui, _layer(layer));
          if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "- Create new profile") then
            create_new_profile(slot_data.id)
          end
        end
      end,
    datum_translation = {
      _index = {[0] = 4, [1] = "money", [2] = "spells_known", [3] = "wand_types_known", [4] = "always_cast_spells_known" },
      money                        = {"Stashed Money:",      __val,       9,     __render_gen_stat  },
      spells_known                = {"Spells:",              __val,       9,     __render_gen_stat  },
      wand_types_known            = {"Wand Types:",          __val,       9,     __render_gen_stat  },
      always_cast_spells_known    = {"Always Casts:",        __val,       9,     __render_gen_stat  },
    },
    datum_exists_member = "quickloaded",
    slots_func = get_quick_profiles,
    slots_data = {};
  };

  wands_fourslot = {
    id = "wand_select",
    centertext = "WANDS ARE DESTROYED WHEN RESEARCHED",
    greentext = "Green stats improve your research",
    redtext = "Red stats do not",
    slot_title = "Wand slot %i:",
    render_slot_func = __render_wand_slot,
    render_header_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        local row1_y_offset = 2;
        local row2_y_offset = 11;
        local row3_y_offset = 18;
        local x_offset = 6;

        if slot_data.e_id~=nil then
          if slot_data.research.is_new then
            GuiZSetForNextWidget(gui, _layer(layer));
            GuiColorNextWidgetBool(gui, last_known_money >= slot_data.price);
            if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, string.format("- Research for $ %1.0f", slot_data.price)) and slot_data.price < last_known_money then
              research_wand(slot_data.e_id);
              slot_data = {};
              GamePrintImportant("Wand Researched");
              return true;
            end
          else
            if fourslot_confirmation~=slot_data.id and EntityHasTag(slot_data.e_id, "persistence") then
              GuiZSetForNextWidget(gui, _layer(layer));
              GuiColorNextWidgetEnum(gui, COLORS.Green);
              if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "- Modify wand") then
                GamePrint("Modify Wand");
                present_modify_wand(slot_data.e_id or 0, slot_data.id);
              end
              if select(2, GuiGetPreviousWidgetInfo(gui))==true then
                fourslot_confirmation = slot_data.id;
              end
            else
              if fourslot_confirmation == slot_data.id then
                GuiZSetForNextWidget(gui, _layer(layer));
                GuiColorNextWidgetEnum(gui, COLORS.Yellow);
                if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "- Click to recycle") then
                  fourslot_confirmation = 0;
                  delete_wand_entity(slot_data.e_id);
                  slot_data = {};
                  GamePrintImportant("Wand Recycled");
                  return true;
                end
              else
                GuiZSetForNextWidget(gui, _layer(layer));
                GuiColorNextWidgetEnum(gui, COLORS.Dim);
                if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "No improved stats") then
                  fourslot_confirmation = slot_data.id;
                end
              end
            end
          end
          if #slot_data.wand["spells"]>0 then
            if slot_data.research.b_spells then
              GuiColorNextWidgetEnum(gui, COLORS.Red);
              GuiZSetForNextWidget(gui, _layer(layer));
              GuiText(gui, x_base + 0 + x_offset, y_base + row2_y_offset, "WAND CONTAINS", small_text_scale);
              GuiColorNextWidgetEnum(gui, COLORS.Red);
              GuiZSetForNextWidget(gui, _layer(layer));
              GuiText(gui, x_base + 2 + x_offset, y_base + row3_y_offset, "UNRESEARCHED SPELLS", small_text_scale);
            else
              GuiColorNextWidgetEnum(gui, COLORS.Yellow);
              GuiZSetForNextWidget(gui, _layer(layer));
              GuiText(gui, x_base + 0 + x_offset, y_base + row2_y_offset, "Wand contains spells which", small_text_scale);
              GuiColorNextWidgetEnum(gui, COLORS.Yellow);
              GuiZSetForNextWidget(gui, _layer(layer));
              GuiText(gui, x_base + 2 + x_offset, y_base + row3_y_offset, "will be lost on research", small_text_scale);
            end
          end
        else
          GuiZSetForNextWidget(gui, _layer(layer));
          GuiColorNextWidgetEnum(gui, COLORS.Green);
          if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, "- Create new wand") then
            GamePrint("Create Wand");
            present_modify_wand(slot_data.e_id or 0, slot_data.id);
            ---TODO: CREATE WAND
          end
        end
      end,
    datum_submember = "wand",
    datum_translation = {
        _index = {[0] = 11, [1] = "sprite", [2] = "spells", [3] = "shuffle", [4] = "spells_per_cast", [5] = "cast_delay", [6] = "recharge_time", [7] = "mana_max", [8] = "mana_charge_speed", [9] = "capacity", [10] = "spread", [11] = "always_cast_spells"},
        sprite              = {"",                            __val,      0,      __render_wand_sprite,    "b_wand_types"  },
        spells              =  {"",                            __val,      34,      __render_wand_spells,    "b_capacity"  },
        shuffle              = {"$inventory_shuffle",          __yesno,    9,      __render_gen_stat,      "b_shuffle"  },
        spells_per_cast      = {"$inventory_actionspercast",    __val,      9,      __render_gen_stat,      "b_spells_per_cast"  },
        cast_delay          = {"$inventory_castdelay",        __ctime,    9,      __render_gen_stat,      "b_cast_delay"  },
        recharge_time        = {"$inventory_rechargetime",      __ctime,    9,      __render_gen_stat,      "b_recharge_time"  },
        mana_max            = {"$inventory_manamax",          __round,    9,      __render_gen_stat,      "b_mana_max"  },
        mana_charge_speed    = {"$inventory_manachargespeed",  __round,    9,      __render_gen_stat,      "b_mana_charge_speed"  },
        capacity            =  {"$inventory_capacity",          __val,      9,      __render_gen_stat,      "b_capacity"  },
        spread              = {"$inventory_spread",            __deg,      9,      __render_gen_stat,      "b_spread"  },
        always_cast_spells  = {"$inventory_alwayscasts",      __val,      9,      __render_wand_spells,    "b_always_cast_spells"  },
      },
    datum_exists_member = "wand",
    slots_func = get_player_wands,
    slots_data = {};
  };

  local function draw_fourslot_ui(fourslot_table)
    local _reload_data=true;
    fourslot_confirmation=0;

    active_windows[fourslot_table.id] = function (_nid)
      local function _gui_nop(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid) return; end

      if _reload_data~=false then fourslot_table.slots_data = fourslot_table.slots_func(); _reload_data=false; end

      local x_base = 30;
      local y_base = 20;
      local margin = 4;
      local width = 448;
      local height = 200;
      local x_offset = x_base + margin;
      local y_offset = y_base + margin;
      local panel_width = 104;
      local panel_height = height - (margin * 2);
      GuiZSet(gui, _layer(0)); ---gui frame
      GuiImageNinePiece(gui, _nid(), x_base, y_base, width, height);

      for _panel_id = 1, 4 do
        fourslot_table.slots_data[_panel_id].id = _panel_id;
        local panel_x_offset = x_offset + ((_panel_id-1) * (panel_width + (margin*2)));
        GuiZSet(gui, _layer(1)); ---per-panel border
        GuiImageNinePiece(gui, _nid(), panel_x_offset, y_offset, panel_width, panel_height);

        local panel_sub_width = panel_width - (margin*2);
        local panel_sub_height = panel_height - (margin*2);
        panel_x_offset = panel_x_offset;
        panel_y_offset = y_offset;

        local header_x_pos = panel_x_offset;
        local header_y_pos = panel_y_offset;
        if (fourslot_table.render_header_func or _gui_nop)(header_x_pos, header_y_pos, margin, panel_sub_width, panel_sub_height, 2, fourslot_table.slots_data[_panel_id], _nid) then
          _reload_data = true;
        end

        local label_x_pos = panel_x_offset + 23;
        local label_y_pos = header_y_pos + 27;
        GuiZSetForNextWidget(gui, _layer(2)); ---slot label
        GuiText(gui, label_x_pos, label_y_pos, string.format(fourslot_table.slot_title, _panel_id), 1);

        local slot_x_pos = panel_x_offset + margin;
        local slot_y_pos = label_y_pos + 12;
        panel_sub_width = panel_width - (margin*2);
        panel_sub_height = panel_sub_height - (slot_y_pos - y_offset - margin);
        (fourslot_table.render_slot_func or _gui_nop)(slot_x_pos, slot_y_pos, margin, panel_sub_width, panel_sub_height, 2, fourslot_table.slots_data[_panel_id], _nid)
        local datum_x_pos = panel_x_offset + margin;
        local datum_y_pos = slot_y_pos + margin;
        for _order_i = 1, fourslot_table.datum_translation._index[0] do
          if fourslot_table.slots_data[_panel_id][fourslot_table.datum_exists_member]~=nil then
            local _datum_name = fourslot_table.datum_translation._index[_order_i];
            local _datum_value = fourslot_table.datum_submember~=nil and fourslot_table.slots_data[_panel_id][fourslot_table.datum_submember][_datum_name] or fourslot_table.slots_data[_panel_id][_datum_name];
            local _trans_label = (fourslot_table.datum_translation[_datum_name][1] or "");
            local _value_func = (fourslot_table.datum_translation[_datum_name][2] or __val);
            local _height = (fourslot_table.datum_translation[_datum_name][3] or 0);
            local _render_func = (fourslot_table.datum_translation[_datum_name][4] or _gui_nop);
            local _datum_table = fourslot_table.slots_data[_panel_id];
            if fourslot_table.slots_data[_panel_id].research~=nil then
              local _improves_member = fourslot_table.datum_translation[_datum_name][5];
              local _improves_bool = fourslot_table.slots_data[_panel_id].research==nil and nil or fourslot_table.slots_data[_panel_id].research[_improves_member];
              _datum_table.color_val = _improves_bool;
            end

            _datum_table.label = _trans_label;
            _datum_table.value = _value_func(_datum_value);
            _render_func(datum_x_pos, datum_y_pos, margin, panel_sub_width, panel_sub_height, 4, _datum_table, _nid);
            datum_y_pos = datum_y_pos + _height;
          end
        end
      end
      __render_tricolor_footer(x_base, y_base, width, height, fourslot_table);
    end
  end

  function present_profile_select()
    if profile_open==true then return; end

    draw_fourslot_ui(profile_fourslot);
    profile_open = true;
  end

  function close_profile_select()
    if profile_open==false then return; end

    active_windows[profile_fourslot.id] = nil;
    profile_open = false;
  end

  function present_wands()
    if wands_open==true then return; end

    draw_fourslot_ui(wands_fourslot);
    wands_open = true;
  end

  function close_wands()
    if wands_open==false then return; end

    active_windows[wands_fourslot.id] = nil;
    wands_open = false;
  end

  print("=========================");
  print("persistence: fourslot loaded.");
  fourslot_loaded = true;
end