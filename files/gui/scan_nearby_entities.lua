if scan_nearby_entities_loaded~=true then
  scan_nearby_entities_open=false;

  local function draw_scan_nearby_entities()
    local x_base = 320;
    local x_offset = 45;
    local y_base = 300;
    local _frame_skip=5;
    local _frame_num=5;
    local search_radius = 20;
    local nearby_spell_old = false;
    local nearby_spell_new = false;
    local nearby_wand_old = false;
    local nearby_wand_new = false;
    local nearby_wand_spell_new = false;

    active_windows["scan_nearby_entities"] = function(_nid)
      if GameGetFrameNum()%_frame_skip==0 then
        nearby_spell_old = false;
        nearby_spell_new = false;
        nearby_wand_old = false;
        nearby_wand_new = false;
        nearby_wand_spell_new = false;
        local plr_x, plr_y = EntityGetTransform(player_e_id);
        local _nearby_cards = EntityGetInRadiusWithTag(plr_x, plr_y, search_radius, "card_action");
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
                nearby_spell_old = true;
              end
            else
              if _parent_is_wand then
                local _card_item_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemComponent");
                local _is_permanent = ComponentGetValueBool(_card_item_c_id or 0, "permanently_attached");
                nearby_wand_spell_new = _is_permanent==false;
              else
                nearby_spell_new = true;
              end
            end
            _frame_num = 10;
          end
        end

        local _nearby_wands = EntityGetInRadiusWithTag(plr_x, plr_y, search_radius, "wand");
        for _, _wand_e_id in pairs(_nearby_wands) do
          local _wand_parent_e_id = EntityGetParent(_wand_e_id);
          local _parent_is_quick_inv = EntityGetName(_wand_parent_e_id)=="inventory_quick";
          if not _parent_is_quick_inv then
            local _result = research_wand_is_new(_wand_parent_e_id);
            if _result.is_new then
              nearby_wand_new = true;
            else
              nearby_wand_old = true;
            end
            _frame_num = 10;
          end
        end
      elseif _frame_num>0 then
        _frame_num = _frame_num - 1;
      -- else
      end

      if _frame_num>0 then
        if nearby_spell_new or nearby_spell_old then
          local _color = nearby_spell_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base - 10, nearby_spell_new and "unresearched" or "researched", nearby_spell_new and 1 or small_text_scale);
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base, "spell", nearby_spell_new and 1 or small_text_scale);
        end

        if nearby_wand_new or nearby_wand_old then
          local _color = nearby_wand_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base - 10, nearby_wand_new and "unresearched" or "researched", nearby_wand_new and 1 or small_text_scale);
          GuiZSet(gui, _layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base, "wand", nearby_wand_new and 1 or small_text_scale);
        end

        if nearby_wand_spell_new then
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

    active_windows["scan_nearby_entities"] = {};
    scan_nearby_entities_open = false;
  end

  print("=========================");
  print("persistence: Scan nearby entities loaded.");
  scan_nearby_entities_loaded=true;
end