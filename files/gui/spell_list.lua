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
    datum_sort_funcs = {
      _index = {[0]=4, [1]="sort_inv_name", [2]="sort_inv_cost_name", [3]="sort_inv_type_name", [4]="sort_inv_type_cost" },
      sort_inv_name        = { "Name",       function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name)));
        end },
      sort_inv_cost_name  = {"Cost,Name",        function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.price==b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.price<b.price;
        end },
      sort_inv_type_name  = {"Type,Name",    function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.type==b.type) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.type<b.type;
        end },
      sort_inv_type_cost  = {"Type,Cost,Name",    function (a, b)
        if (a.researchable and not b.researchable) then return true; end
        if (b.researchable and not a.researchable) then return false; end
        if (b.recyclable and not a.recyclable) then return true; end
        if (a.recyclable and not b.recyclable) then return false; end
        if (a.type==b.type) and (a.price)==(b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if (a.type==b.type) then return (a.price<b.price); end
        return a.type<b.type;
        end },
    },
    datum_render_func = __render_spell_listentry,
    action_render_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        if slot_data.researchable~=nil and slot_data.researchable==true then
          local _price = math.ceil(slot_data.price * ModSettingGet("persistence.research_spell_price_multiplier"));
          if last_known_money < _price then
            GuiColorNextWidgetEnum(gui, COLORS.Red);
            GuiZSetForNextWidget(gui, _layer(layer));
            GuiText(gui, x_base, 3 + y_base, string.format(" $ %1.0f", _price))
          else
            GuiColorNextWidgetEnum(gui, COLORS.Green);
            GuiZSetForNextWidget(gui, _layer(layer));
            if GuiButton(gui, _nid(), x_base, 3 + y_base, string.format(" $ %1.0f", _price)) then
              research_spell_entity(slot_data.e_id);
              GamePrintImportant("Spell Researched", slot_data.name);
              -- table.remove(researchable_spell_entities, r_s_e_idx);
              return true;
            end
          end -- Colorize Button

        elseif slot_data.recyclable~=nil and slot_data.recyclable==true then
          if spell_list_confirmation==slot_data.e_id then
            GuiColorNextWidgetEnum(gui, COLORS.Red);
            GuiZSetForNextWidget(gui, _layer(layer));
            if GuiButton(gui, _nid(), x_base, 10 + y_base, "CONFIRM") then
              GamePrintImportant("Spell Recycled", slot_data.name);
              delete_spell_entity(slot_data.e_id);
              -- table.remove(recyclable_spell_entities, d_s_e_idx);
              return true;
            end
            GuiTooltip(gui, "RECYCLE SPELL", "NO COST. NO GAIN.")
          else
            GuiColorNextWidgetEnum(gui, COLORS.Dim);
            GuiZSetForNextWidget(gui, _layer(layer));
            if GuiButton(gui, _nid(), x_base, 0 + y_base, "-known-") then
              spell_list_confirmation = slot_data.e_id;
            end
            GuiTooltip(gui, "Recycle Spell", "No cost. No gain.")
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
    datum_sort_funcs = {
      _index = {[0]=4, [1]="sort_name", [2]="sort_cost_name", [3]="sort_type_name", [4]="sort_type_cost" },
      sort_name        = { "Name",       function (a, b)
        return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name)));
        end },
      sort_cost_name  = {"Cost,Name",        function (a, b)
        if (a.price==b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.price<b.price;
        end },
      sort_type_name  = {"Type,Name",    function (a, b)
        if (a.type==b.type) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        return a.type<b.type;
        end },
      sort_type_cost  = {"Type,Cost,Name",    function (a, b)
        if (a.type==b.type) and (a.price)==(b.price) then return (string.lower(GameTextGetTranslatedOrNot(a.name))<string.lower(GameTextGetTranslatedOrNot(b.name))); end
        if (a.type==b.type) then return (a.price<b.price); end
        return a.type<b.type;
        end },
    },
    datum_render_func = __render_spell_listentry,
    action_render_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
        local _price = math.ceil(slot_data.price * ModSettingGet("persistence.buy_spell_price_multiplier"));
        if last_known_money < _price then
          GuiColorNextWidgetEnum(gui, COLORS.Red);
          GuiZSetForNextWidget(gui, _layer(layer));
          GuiText(gui, x_base, 3 + y_base, string.format(" $ %1.0f", _price));
        else
          GuiColorNextWidgetEnum(gui, COLORS.Green);
          GuiZSetForNextWidget(gui, _layer(layer));
          if GuiButton(gui, _nid(), x_base, 3 + y_base, string.format(" $ %1.0f", _price)) then
            purchase_spell(slot_data.a_id);
            GamePrintImportant("Spell Purchased", slot_data.name);
            -- table.remove(researchable_spell_entities, r_s_e_idx);
            return true;
          end
        end -- Colorize Button
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
      local width = spell_list_table.slots_data._index.count>8 and 440 or 448;
      local height = 200;
      local x_offset = margin;
      local y_offset = 3;
      local panel_width = 104;
      local panel_height = height - (margin * 2);
      local entry_height = 20;

      GuiZSetForNextWidget(gui, _layer(2));
      if GuiButton(gui, _nid(), 400, 6, "Sort: " .. spell_list_table.datum_sort_funcs[_active_sort_name][1] ) then
        _active_sort_idx = (_active_sort_idx<spell_list_table.datum_sort_funcs._index[0]) and (_active_sort_idx + 1) or 1;
        _active_sort_name = spell_list_table.datum_sort_funcs._index[_active_sort_idx];
        _sorted = false;
      end

      if _sorted~=true then table.sort(spell_list_table.slots_data, spell_list_table.datum_sort_funcs[_active_sort_name][2]); _sorted=true;  end

      GuiZSetForNextWidget(gui, _layer(2));
      GuiText(gui, 240, 6, "Search:", 1);
      GuiZSetForNextWidget(gui, _layer(2));
      _search_for = GuiTextInput(gui, _nid(), 270, 5, _search_for, 100, 20);
      if select(2, GuiGetPreviousWidgetInfo(gui))  then _search_for = ""; end

      local _f_idx = 1;
      GuiZSetForNextWidget(gui, _layer(2));
      GuiText(gui, 26, 6, "Filter:");
      for _type_nr, _type_bool in pairs(spell_list_table.slots_data._index.type_hash) do
        if _type_bool then
          if _type_nr~=99 then
            _f_idx = _f_idx + 1;
          end
          local _filter_x_offset = 40 + ( (_type_nr==99 and 1 or _f_idx) * 20);
          GuiZSetForNextWidget(gui, _layer(2));
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
            GuiZSetForNextWidget(gui, _layer(2));
            GuiImage(gui, _nid(), _filter_x_offset + _mark_offset_x, _mark_offset_y, "data/ui_gfx/damage_indicators/explosion.png", 0.5, 1, 1, math.rad(45)); -- radians are annoying
          end
        end
      end

      GuiZSet(gui, _layer(0)); ---gui frame
      GuiBeginScrollContainer(gui, _nid(), x_base, y_base, width, height);
      if spell_list_table.slots_data._index.count > 0 then  ---Main iteration loop for spell list UI
        for _inv_spell_idx, _inv_spell_members in pairs(spell_list_table.slots_data) do
          if _inv_spell_idx~="_index" then
            local show_curr_spell = true;
            if _search_for~= "" and string.find(string.lower(GameTextGetTranslatedOrNot(_inv_spell_members.name)), string.lower(_search_for), 1, true)==nil then
              show_curr_spell = false;
            end
            if _active_filter~=99 and _active_filter~=_inv_spell_members.type then
              show_curr_spell = false;
            end

            if show_curr_spell then
              _inv_spell_members.idx = _inv_spell_idx;
              (spell_list_table.datum_render_func or _gui_nop)(x_offset, y_offset, margin, panel_width, panel_height, 2, _inv_spell_members, _nid);
              if (spell_list_table.action_render_func or _gui_nop)(x_offset, y_offset, margin, panel_width, panel_height, 2, _inv_spell_members, _nid) then
                _reload_data = true;
              end
              y_offset = y_offset + entry_height;
            end
          end
        end
      else
        GuiText(gui, 40, 40, "No spells in inventory");
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