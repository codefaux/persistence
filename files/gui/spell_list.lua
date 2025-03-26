if spell_list_loaded~=true then
  inventory_spells_open=false;
  purchase_spells_open=false;

  inventory_spell_list_table= {
    id = "inventory_spells",
    centertext = "SPELLS ARE DESTROYED WHEN RESEARCHED",
    greentext = "Purchases drop at your feet",
    redtext = "Recycle at no cost, for no gain",
    slots_data = {},
    slots_func = get_spell_inv_research_table,
    empty_message_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
      local _empty_message = "No spells in inventory";
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
      GuiColorNextWidgetEnum(gui, COLORS.Yellow);
      GuiText(gui, x_base + (panel_width/2), y_base - 5 + (panel_width/2), _empty_message);
      end,
    datum_sort_funcs = {
      _index = {[0]=10, [1]="sort_inv_name", [2]="sort_inv_cost_name", [3]="sort_inv_type_name", [4]="sort_inv_type_cost", [5]="sort_inv_draw", [6]="sort_inv_uses", [7]="sort_inv_mana", [8]="sort_inv_delay", [9]="sort_inv_recharge", [10]="sort_inv_crit" },
      sort_inv_name = { "Name", function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name)));
        end },
      sort_inv_cost_name = {"Cost", function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.price==b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.price<b.price;
        end },
      sort_inv_type_name = {"Type,Name", function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.type==b.type) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.type<b.type;
        end },
      sort_inv_type_cost = {"Type,Cost", function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.type==b.type) and (a.price)==(b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if (a.type==b.type) then return (a.price<b.price); end
        return a.type<b.type;
        end },
        sort_draw = {GameTextGetTranslatedOrNot("$inventory_actiontype_drawmany"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].c.draw_actions==actions_by_id[b.a_id].c.draw_actions) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].c.draw_actions~=nil and actions_by_id[b.a_id].c.draw_actions==nil then return true; end
          if actions_by_id[a.a_id].c.draw_actions==nil and actions_by_id[b.a_id].c.draw_actions~=nil then return false; end
          if actions_by_id[a.a_id].c.draw_actions>1 and actions_by_id[b.a_id].c.draw_actions<2 then return true; end
          if actions_by_id[a.a_id].c.draw_actions<2 and actions_by_id[b.a_id].c.draw_actions>1 then return false; end
          return actions_by_id[a.a_id].c.draw_actions<actions_by_id[b.a_id].c.draw_actions;
          end },
        sort_uses = {GameTextGetTranslatedOrNot("$inventory_usesremaining"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].max_uses==actions_by_id[b.a_id].max_uses) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].max_uses~=nil and actions_by_id[b.a_id].max_uses==nil then return true; end
          if actions_by_id[a.a_id].max_uses==nil and actions_by_id[b.a_id].max_uses~=nil then return false; end
          return actions_by_id[a.a_id].max_uses<actions_by_id[b.a_id].max_uses;
          end },
        sort_mana = {GameTextGetTranslatedOrNot("$inventory_manadrain"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].mana==actions_by_id[b.a_id].mana) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].mana~=nil and actions_by_id[b.a_id].mana==nil then return true; end
          if actions_by_id[a.a_id].mana==nil and actions_by_id[b.a_id].mana~=nil then return false; end
          return actions_by_id[a.a_id].mana<actions_by_id[b.a_id].mana;
          end },
        sort_delay = {GameTextGetTranslatedOrNot("$inventory_castdelay"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].c.fire_rate_wait==actions_by_id[b.a_id].c.fire_rate_wait) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].c.fire_rate_wait~=nil and actions_by_id[b.a_id].c.fire_rate_wait==nil then return true; end
          if actions_by_id[a.a_id].c.fire_rate_wait==nil and actions_by_id[b.a_id].c.fire_rate_wait~=nil then return false; end
          return actions_by_id[a.a_id].c.fire_rate_wait<actions_by_id[b.a_id].c.fire_rate_wait;
          end },
        sort_recharge = {GameTextGetTranslatedOrNot("$inventory_mod_rechargetime"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].c.reload_time==actions_by_id[b.a_id].c.reload_time) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].c.reload_time~=nil and actions_by_id[b.a_id].c.reload_time==nil then return true; end
          if actions_by_id[a.a_id].c.reload_time==nil and actions_by_id[b.a_id].c.reload_time~=nil then return false; end
          return actions_by_id[a.a_id].c.reload_time<actions_by_id[b.a_id].c.reload_time;
          end },
        sort_crit = {GameTextGetTranslatedOrNot("$inventory_mod_critchance"), function (a, b)
          if (a.researchable and not b.researchable) then return true; end
          if (b.researchable and not a.researchable) then return false; end
          if (b.recyclable and not a.recyclable) then return true; end
          if (a.recyclable and not b.recyclable) then return false; end
          if (actions_by_id[a.a_id].c.damage_critical_chance==actions_by_id[b.a_id].c.damage_critical_chance) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
          if actions_by_id[a.a_id].c.damage_critical_chance~=nil and actions_by_id[b.a_id].c.damage_critical_chance==nil then return false; end
          if actions_by_id[a.a_id].c.damage_critical_chance==nil and actions_by_id[b.a_id].c.damage_critical_chance~=nil then return true; end
          return actions_by_id[a.a_id].c.damage_critical_chance>actions_by_id[b.a_id].c.damage_critical_chance;
          end },
      },
    datum_render_func = __render_spell_listentry,
    action_render_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        if slot_data.researchable~=nil and slot_data.researchable==true then
          local _price = math.ceil(slot_data.price * mod_setting.research_spell_price_multiplier);

          GuiColorNextWidgetBool(gui, last_known_money >= _price);
            GuiZSetForNextWidget(gui, __layer(layer));
            if GuiButton(gui, _nid(), x_base, 3 + y_base, string.format(" $ %1.0f", _price)) then
            if (last_known_money >= _price) then
              research_spell_entity(slot_data.e_id);
              GamePrintImportant("Spell Researched", slot_data.name);
              -- table.remove(researchable_spell_entities, r_s_e_idx);
              return true;
            end
          end

        elseif slot_data.recyclable~=nil and slot_data.recyclable==true then
          if spell_list_confirmation==slot_data.e_id then
            GuiColorNextWidgetEnum(gui, COLORS.Red);
            GuiZSetForNextWidget(gui, __layer(layer));
            if GuiButton(gui, _nid(), x_base, 10 + y_base, "CONFIRM") then
              GamePrintImportant("Spell Recycled", slot_data.name);
              delete_spell_entity(slot_data.e_id);
              -- table.remove(recyclable_spell_entities, d_s_e_idx);
              return true;
            end
            GuiGuideTip(gui, "Recycle spell", "NO COST. NO GAIN.")
          else
            GuiColorNextWidgetEnum(gui, COLORS.Dim);
            GuiZSetForNextWidget(gui, __layer(layer));
            if GuiButton(gui, _nid(), x_base, 0 + y_base, slot_data.known and "-known-" or "-ineligible-") then
              spell_list_confirmation = slot_data.e_id;
            end
            GuiGuideTip(gui, "Recycle Spell. No cost. No gain. ", "Partially used spells cannot be researched.")
          end -- Colorize Button
        end
      end
  }


  purchase_spell_list_table= {
    id = "purchase_spells",
    centertext = "PURCHASES CAN SAFELY OVERFILL INVENTORY",
    greentext = "Click a spell to purchase it",
    redtext = "No refunds",
    slots_data = {},
    slots_func = get_spell_purchase_table,
    empty_message_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
      local _empty_message = "No spells have been researched";
      GuiZSetForNextWidget(gui, __layer(layer));
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
      GuiColorNextWidgetEnum(gui, COLORS.Yellow);
      GuiText(gui, x_base + (panel_width/2), y_base - 5 + (panel_width/2), _empty_message);
    end,
  datum_sort_funcs = {
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
      },
    datum_render_func = __render_spell_listentry,
    action_render_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        local _price = math.ceil(slot_data.price * mod_setting.buy_spell_price_multiplier);

        GuiColorNextWidgetBool(gui, last_known_money >= _price);
          GuiZSetForNextWidget(gui, __layer(layer));
          if GuiButton(gui, _nid(), x_base, 3 + y_base, string.format(" $ %1.0f", _price)) then
          if (last_known_money > _price) then
            purchase_spell(slot_data.a_id);
            GamePrintImportant("Spell Purchased", slot_data.name);
            return true;
          end
        end
      end
  }

  local function draw_spell_list_ui(spell_list_table)
    local _active_sort_idx = 1;
    local _active_sort_name = spell_list_table.datum_sort_funcs._index[_active_sort_idx];
    local _sorted = false;
    local _search_for = "";
    local _active_filter = 99;
    local _reload_data=true;
    spell_list_confirmation = 0;

    active_windows[spell_list_table.id] = function (_nid)
      local function _gui_nop(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid) return; end

      if _reload_data~=false then spell_list_table.slots_data = spell_list_table.slots_func(); _reload_data=false; _sorted=false; end

      local x_base = 30;
      local y_base = 20;
      local margin = 4;
      local width = spell_list_table.slots_data._index.count>8 and 438 or 446;
      local height = 200;
      local x_offset = margin;
      local y_offset = 3;
      local panel_width = 104;
      local panel_height = height - (margin * 2);
      local entry_height = 20;

      GuiZSetForNextWidget(gui, __layer(2));
      if GuiButton(gui, _nid(), 400, 6, "Sort: " .. spell_list_table.datum_sort_funcs[_active_sort_name][1] ) then
        _active_sort_idx = (_active_sort_idx<spell_list_table.datum_sort_funcs._index[0]) and (_active_sort_idx + 1) or 1;
        _active_sort_name = spell_list_table.datum_sort_funcs._index[_active_sort_idx];
        _sorted = false;
      end
      if select(2, GuiGetPreviousWidgetInfo(gui)) then
        _active_sort_idx = (_active_sort_idx>1) and (_active_sort_idx - 1) or spell_list_table.datum_sort_funcs._index[0];
        _active_sort_name = spell_list_table.datum_sort_funcs._index[_active_sort_idx];
        _sorted = false;
      end
      GuiGuideTip(gui, "Click to change sort order", "Right-click to move backward");

      if _sorted~=true then table.sort(spell_list_table.slots_data, spell_list_table.datum_sort_funcs[_active_sort_name][2]); _sorted=true;  end

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
      for _type_nr, _type_bool in pairs(spell_list_table.slots_data._index.type_hash) do
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
          GuiTooltip(gui, _type_nr==99 and "ALL" or action_type_to_string(_type_nr), "");
          if _type_nr==_active_filter then
            local _mark_offset_x = 10;
            local _mark_offset_y = 8;
            GuiZSetForNextWidget(gui, __layer(3));
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive);
            GuiImage(gui, _nid(), _filter_x_offset + _mark_offset_x, _mark_offset_y, "data/ui_gfx/damage_indicators/explosion.png", 0.5, 1, 1, math.rad(45)); -- radians are annoying
          end
        end
      end

      GuiZSet(gui, __layer(0)); ---gui frame
      GuiBeginScrollContainer(gui, _nid(), x_base, y_base, width, height);
      if spell_list_table.slots_data._index.count > 0 then  ---Main iteration loop for spell list UI
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.GamepadDefaultWidget);
        for _inv_spell_idx, _inv_spell_members in pairs(spell_list_table.slots_data) do
          if _inv_spell_idx~="_index" then
            local show_curr_spell = true;
            if _search_for~="" then show_curr_spell=check_search_for(_inv_spell_members, _search_for); end
            if _active_filter~=99 and _active_filter~=_inv_spell_members.type then
              show_curr_spell = false;
            end

            if show_curr_spell then
              _inv_spell_members.idx = _inv_spell_idx;
              if (spell_list_table.action_render_func or _gui_nop)(x_offset, y_offset, margin, panel_width, panel_height, 2, _inv_spell_members, _nid) then
                _reload_data = true;
              end
              (spell_list_table.datum_render_func or _gui_nop)(x_offset, y_offset, margin, panel_width, panel_height, 2, _inv_spell_members, _nid);
              y_offset = y_offset + entry_height;
            end
          end
        end
      else
        (spell_list_table.empty_message_func or _gui_nop)(x_offset, y_offset, margin, panel_width, panel_height, 2, nil, _nid);
      end
      GuiEndScrollContainer(gui);
      __render_tricolor_footer(x_base, y_base, width, height, spell_list_table);
    end
  end

  function present_inventory_spells()
    if inventory_spells_open==true then return; end

    draw_spell_list_ui(inventory_spell_list_table);
    inventory_spells_open = true;
  end

  function close_inventory_spells()
    if inventory_spells_open==false then return; end

    active_windows[inventory_spell_list_table.id] = nil;
    inventory_spells_open = false;
  end

  function present_purchase_spells()
    if purchase_spells_open==true then return; end

    draw_spell_list_ui(purchase_spell_list_table);
    purchase_spells_open = true;
  end

  function close_purchase_spells()
    if purchase_spells_open==false then return; end

    active_windows[purchase_spell_list_table.id] = nil;
    purchase_spells_open = false;
  end

  print("=========================");
  print("persistence: Spell list loaded.");
 spell_list_loaded=true;
end