if money_loaded~=true then
  money_open=false;
  dofile("data/scripts/debug/keycodes.lua");

  local function draw_money()
    if mod_setting.allow_stash==0 then money_open=true; return; end

      active_windows["money"] = function (_nid)
      local stash_money = get_stash_money();
      local player_money = get_player_money();
      local money_amts = {1, 10, 100, 1000};
      local base_x = 485;
      local base_y = 30;
      local offset_y = base_y + 3;
      local idx = 0;
      local col_a = base_x + 5;
      local col_b = base_x + 70;
      local _multiplier = 1;
      if InputIsKeyDown(Key_LSHIFT) then _multiplier = _multiplier * 5; end
      if InputIsKeyDown(Key_LCTRL) then _multiplier = _multiplier * 10; end

      GuiZSetForNextWidget(gui, __layer(0));
      GuiImageNinePiece(gui, _nid(), base_x, base_y, 140, 75);

      GuiZSetForNextWidget(gui, __layer(1));
      GuiText(gui, col_a + 20, offset_y + (idx * 10), string.format("Player: $ %1.0f", player_money));
      idx = idx + 1;

      for _, _money_amt in ipairs(money_amts) do
        _new_money_amt = _money_amt * _multiplier;

        if stash_money < _new_money_amt or mod_setting.allow_stash~=1 then
          GuiZSetForNextWidget(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, COLORS.Dark);
          GuiText(gui, col_a, offset_y + (idx * 10), string.format("Take $ %1.0f", _new_money_amt));
        else
          GuiZSetForNextWidget(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, COLORS.Green);
          if GuiButton(gui, _nid(), col_a, offset_y + (idx * 10), string.format("Take $ %1.0f", _new_money_amt)) then
            transfer_money_stash_to_player(_new_money_amt);
          end
        end
        GuiGuideTip(gui, "Hold Shift for 5x", "Hold Ctrl for 10x");

        if player_money < _new_money_amt then
          GuiZSetForNextWidget(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, COLORS.Dark);
          GuiText(gui, col_b, offset_y + (idx * 10), string.format("Stash $ %1.0f", _new_money_amt));
        else
          GuiZSetForNextWidget(gui, __layer(1));
          GuiColorNextWidgetEnum(gui, COLORS.Green);
          if GuiButton(gui, _nid(), col_b, offset_y + (idx * 10), string.format("Stash $ %1.0f", _new_money_amt)) then
            transfer_money_player_to_stash(_new_money_amt);
          end
        end
        GuiGuideTip(gui, "Hold Shift for 5x", "Hold Ctrl for 10x");
        idx = idx + 1;
      end

      if mod_setting.allow_stash==1 then
        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if GuiButton(gui, _nid(), col_a, offset_y + (idx * 10), "Take ALL") then
          transfer_money_stash_to_player(stash_money);
        end
        if select(2, GuiGetPreviousWidgetInfo(gui)) and _multiplier==50 then
          set_player_money(get_stash_money() * _multiplier);
        end
      else
        GuiZSetForNextWidget(gui, __layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Dark);
        GuiText(gui, col_a, offset_y + (idx * 10), "Take ALL");
      end

      GuiZSetForNextWidget(gui, __layer(1));
      GuiColorNextWidgetEnum(gui, COLORS.Green);
      if GuiButton(gui, _nid(), col_b, offset_y + (idx * 10), "Stash ALL") then
        transfer_money_player_to_stash(player_money);
      end

      idx = idx + 1;
      GuiZSetForNextWidget(gui, __layer(1));
      GuiText(gui, col_a + 20, offset_y + (idx * 10), string.format("Stashed: $ %1.0f", stash_money));
      GuiGuideTip(gui, "Stashed money from previous runs", "See Mod Options for auomatic withdrawals");
    end
    money_open = true;
  end

  function present_money()
    if money_open==true then return; end

    draw_money();
    money_open = true;
  end

  function close_money()
    if money_open==false then return; end

    active_windows["money"] = nil;
    money_open = false;
  end

  print("=========================");
  print("persistence: Money loaded.");
  money_loaded=true;
end