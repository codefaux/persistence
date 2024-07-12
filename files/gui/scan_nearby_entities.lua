if scan_nearby_entities_loaded~=true then
  scan_nearby_entities_open=false;

  local function draw_scan_nearby_entities()
    local x_base = 320;
    local x_offset = 50;
    local y_base = 300;
    local _frame_skip = 15; --- only actually *scan* entities every x frames
    local _frame_overshoot = 5; --- show indicator for x frames longer than previous detection, in case an event doesn't fire for a frame or two
    local _show_tip_frames = 0; --- counter indicating how long remains
    local _search_radius = 20;
    local _nearby_spell_old = false;
    local _nearby_spell_new = false;
    local _nearby_wand_old = false;
    local _nearby_wand_new = false;
    local _nearby_wand_spell_new = false;
    local _nearby_wand_new_type = 0;

    active_windows["scan_nearby_entities"] = function(_nid)
      if mod_setting.allow_scanner and GameGetFrameNum()%_frame_skip==0 then
        _nearby_spell_old = false;
        _nearby_spell_new = false;
        _nearby_wand_old = false;
        _nearby_wand_new = false;
        _nearby_wand_spell_new = false;
        local _plr_x, _plr_y = EntityGetTransform(player_e_id);
        local _nearby_card_pool = EntityGetInRadiusWithTag(_plr_x, _plr_y + 5, _search_radius, "card_action");
        local _nearby_wand_pool = EntityGetInRadiusWithTag(_plr_x, _plr_y, _search_radius, "wand");

        _nearby_wand_new_type = 0;
        for _, _wand_e_id in pairs(_nearby_wand_pool) do
          local _wand_parent_e_id = EntityGetParent(_wand_e_id);
          local _parent_is_quick_inv = EntityGetName(_wand_parent_e_id)=="inventory_quick";

          if not _parent_is_quick_inv then
            local _result = get_wand_entity_research(_wand_e_id);

            if _result.b_spells==true then _nearby_wand_spell_new=true; end
            if _result.is_new then
              _nearby_wand_new_type = _nearby_wand_new_type + (_result.b_new_is_only_type and 1 or 0);
              _nearby_wand_new = true;
            else
              _nearby_wand_old = true;
            end
            _show_tip_frames = _frame_skip + _frame_overshoot;
          end
        end

        for _, _card_e_id in pairs(_nearby_card_pool) do
          local _card_parent_e_id = EntityGetParent(_card_e_id);
          local _parent_is_player_inv = EntityGetName(_card_parent_e_id)=="inventory_full" or EntityGetName(_card_parent_e_id)=="inventory_quick";
          local _parent_is_wand = EntityHasTag(_card_parent_e_id, "wand");
          if not _parent_is_player_inv then
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
                  if _is_permanent==true then _nearby_wand_spell_new=true; end
                end
              else
                _nearby_spell_new = true;
              end
            end
            _show_tip_frames = _frame_skip + _frame_overshoot;
          end
        end
      elseif _show_tip_frames>0 then
        _show_tip_frames = _show_tip_frames - 1;
      end

      if _show_tip_frames>0 then
        if _nearby_spell_new or _nearby_spell_old then
          local _color = _nearby_spell_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base - 10, _nearby_spell_new and "unresearched" or "researched", _nearby_spell_new and 1 or small_text_scale);
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base - x_offset, y_base, "spell", _nearby_spell_new and 1 or small_text_scale);
        end

        if _nearby_wand_new or _nearby_wand_old then
          local _color = _nearby_wand_new and COLORS.Tip or COLORS.Yellow;
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base - 10, _nearby_wand_new and "unresearched" or "researched", _nearby_wand_new and 1 or small_text_scale);
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base + x_offset, y_base, "wand", _nearby_wand_new and 1 or small_text_scale);
          GuiZSet(gui, __layer(1));
          if _nearby_wand_new_type>0 then
            GuiColorNextWidgetEnum(gui, _color);
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
            GuiText(gui, x_base + x_offset, y_base + 10, string.format("(%i type only)", _nearby_wand_new_type), small_text_scale);
          end
        end

        if _nearby_wand_spell_new then
          local _color = COLORS.Tip;
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base, y_base, "unresearched", 1);
          GuiZSet(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, _color);
          GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
          GuiText(gui, x_base, y_base + 10, "spell ON wand", 1);
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