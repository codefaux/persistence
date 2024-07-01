if scan_nearby_entities_loaded~=true then
  scan_nearby_entities_open=false;

  local function draw_scan_nearby_entities()
    local x_base = 320;
    local x_offset = 45;
    local y_base = 300;
    local _frame_skip=5;
    local _frame_num=5;
    local _search_radius = 20;
    local _nearby_spell_old = false;
    local _nearby_spell_new = false;
    local _nearby_wand_old = false;
    local _nearby_wand_new = false;
    local _nearby_wand_spell_new = false;
    local _nearby_wand_new_type = 0;

    active_windows["scan_nearby_entities"] = function(_nid)
      if GameGetFrameNum()%_frame_skip==0 then
        _nearby_spell_old = false;
        _nearby_spell_new = false;
        _nearby_wand_old = false;
        _nearby_wand_new = false;
        _nearby_wand_spell_new = false;
        local _plr_x, _plr_y = EntityGetTransform(player_e_id);
        local _nearby_cards = EntityGetInRadiusWithTag(_plr_x, _plr_y + 5, _search_radius, "card_action");
        for _, _card_e_id in pairs(_nearby_cards) do
          local _card_parent_e_id = EntityGetParent(_card_e_id);
          local _parent_is_full_inv = EntityGetName(_card_parent_e_id)=="inventory_full";
          local _parent_is_wand = EntityHasTag(_card_parent_e_id, "wand");
          if not _parent_is_full_inv then
            local _action_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemActionComponent") or 0;
            local _action_id = ComponentGetValue(_action_c_id, "action_id");
            if does_profile_know_spell(_action_id) then
              if _parent_is_wand then
                -- nearby_wand_spell_old = true;
              else
                _nearby_spell_old = true;
              end
            else
              if _parent_is_wand then
                local _wand_parent_e_id = EntityGetParent(_card_parent_e_id);
                local _parent_is_quick_inv = EntityGetName(_wand_parent_e_id)=="inventory_quick";
                if not _parent_is_quick_inv then
                  local _card_item_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemComponent");
                  local _is_permanent = ComponentGetValueBool(_card_item_c_id or 0, "permanently_attached");
                  _nearby_wand_spell_new = _is_permanent==false;
                end
              else
                _nearby_spell_new = true;
              end
            end
            _frame_num = 10;
          end
        end

        local _nearby_wands = EntityGetInRadiusWithTag(_plr_x, _plr_y, _search_radius, "wand");
        _nearby_wand_new_type = 0;
        for _, _wand_e_id in pairs(_nearby_wands) do
          local _wand_parent_e_id = EntityGetParent(_wand_e_id);
          local _parent_is_quick_inv = EntityGetName(_wand_parent_e_id)=="inventory_quick";
          if not _parent_is_quick_inv then
            local _result = research_wand_is_new(_wand_parent_e_id);
            if _result.is_new then
              _nearby_wand_new_type = _nearby_wand_new_type + (_result.b_new_is_only_type and 1 or 0);
              _nearby_wand_new = true;
            else
              _nearby_wand_old = true;
            end
            _frame_num = 10;
          end
        end
      elseif _frame_num>0 then
        _frame_num = _frame_num - 1;
      -- else
      end

      if _frame_num>0 then
        if _nearby_spell_new or _nearby_spell_old then
          local _color = _nearby_spell_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base - 10, _nearby_spell_new and "unresearched" or "researched", _nearby_spell_new and 1 or small_text_scale);
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base, "spell", _nearby_spell_new and 1 or small_text_scale);
        end

        if _nearby_wand_new or _nearby_wand_old then
          local _color = _nearby_wand_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base - 10, _nearby_wand_new and "unresearched" or "researched", _nearby_wand_new and 1 or small_text_scale);
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base, "wand", _nearby_wand_new and 1 or small_text_scale);
          GuiZSet(gui, _layer(1));
          if _nearby_wand_new_type>0 then
            GuiColorNextWidgetEnum(gui, _color);
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
            GuiText(gui, x_base + x_offset, y_base, string.format("(%i type only)", _nearby_wand_new_type), small_text_scale);
          end
        end

        if _nearby_wand_spell_new then
          local _color = COLORS.Tip;
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base, y_base - 10, "unresearched", 1);
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base, y_base, "spell ON wand", 1);
        end
      end
    end
  end


  function present_scan_nearby_entities()
    if scan_nearby_entities_open==true then return; end

    draw_scan_nearby_entities();
    scan_nearby_entities_open = true;
  end

  function close_scan_nearby_entities()
    if scan_nearby_entities_open == false then return; end

    active_windows["scan_nearby_entities"] = nil;
    scan_nearby_entities_open = false;
  end

  print("=========================");
  print("persistence: Scan nearby entities loaded.");
  scan_nearby_entities_loaded=true;
end