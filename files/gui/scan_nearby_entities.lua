
local function draw_scan_nearby_entities()
  local x_base = 320;
  local x_offset = 40;
  local y_base = 300;
  local _frame_skip=5;
  local _frame_num=5;
  local search_radius = 20;
  local nearby_spell_old = false;
  local nearby_spell_new = false;
  local nearby_wand_old = false;
  local nearby_wand_new = false;

  active_windows["scan_nearby_entities"] = function(_nid)
    if GameGetFrameNum()%_frame_skip==0 then
      nearby_spell_old = false;
      nearby_spell_new = false;
      nearby_wand_old = false;
      nearby_wand_new = false;
      local plr_x, plr_y = EntityGetTransform(player_e_id);
      local _nearby_cards = EntityGetInRadiusWithTag(plr_x, plr_y, search_radius, "card_action");
      for _, _card_e_id in pairs(_nearby_cards) do
        local _tmp_e_id = get_root_entity(_card_e_id);
        local _tmp_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemComponent");
        -- local _vals = ComponentGetMembers(_tmp_c_id);
        local _is_permanent = ComponentGetValueBool(_tmp_c_id or 0, "permanently_attached");
        if _tmp_e_id~=player_e_id and _is_permanent==false then
          local _action_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemActionComponent") or 0;
          local _action_id = ComponentGetValue(_action_c_id, "action_id");
          if does_profile_know_spell(_action_id) then
            nearby_spell_old = true;
          else
            nearby_spell_new = true;
          end
          _frame_num = 10;
        end
      end

      local _nearby_wands = EntityGetInRadiusWithTag(plr_x, plr_y, search_radius, "wand");
      for _, _wand_e_id in pairs(_nearby_wands) do
        local _tmp_e_id = get_root_entity(_wand_e_id);
        if _tmp_e_id~=player_e_id then
          local _result = research_wand_is_new(_tmp_e_id);
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
        GuiText(gui, x_base - x_offset, y_base - 10, nearby_spell_new and "unresearched" or "researched", 1);
        GuiZSet(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, _color);
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiText(gui, x_base - x_offset, y_base, "spell", 1);
      end

      if nearby_wand_new or nearby_wand_old then
        local _color = nearby_wand_new and COLORS.Tip or COLORS.Yellow;
        GuiZSet(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, _color);
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiText(gui, x_base + x_offset, y_base - 10, nearby_wand_new and "unresearched" or "researched", 1);
        GuiZSet(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, _color);
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
        GuiText(gui, x_base + x_offset, y_base, "wand", 1);
      end
    end
  end
end


function present_scan_nearby_entities()
  if scan_nearby_entities_open==false then return; end

  draw_scan_nearby_entities();
  scan_nearby_entities_open = true;
end

function close_scan_nearby_entities()
  if scan_nearby_entities_open == false then return; end

  active_windows["scan_nearby_entities"] = {};
  scan_nearby_entities_open = false;
end