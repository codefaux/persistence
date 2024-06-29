
local function draw_money()
  active_windows["money"] = function (_nid)
    local stash_money = get_stash_money();
    local player_money = get_player_money();
    local money_amts = {1, 10, 100, 1000};
    local base_x = 485;
    local base_y = 30;
    local offset_y = base_y + 3;
    local idx = 0;
    local col_a = base_x + 9;
    local col_b = base_x + 69;

    GuiZSetForNextWidget(gui, _layer(0));
    GuiImageNinePiece(gui, _nid(), base_x, base_y, 140, 75);

    GuiZSetForNextWidget(gui, _layer(1));
    GuiText(gui, col_a + 20, offset_y + (idx * 10), string.format("Player: $ %1.0f", player_money));
    idx = idx + 1;

    for _, money_amt in ipairs(money_amts) do
      if stash_money < money_amt then
        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Dark)
        GuiText(gui, col_a, offset_y + (idx * 10), string.format("Take $ %1.0f", money_amt));
      else
        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if GuiButton(gui, _nid(), col_a, offset_y + (idx * 10), string.format("Take $ %1.0f", money_amt)) then
          transfer_money_stash_to_player(money_amt);
        end
      end

      if player_money < money_amt then
        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Dark);
        GuiText(gui, col_b, offset_y + (idx * 10), string.format("Stash $ %1.0f", money_amt));
      else
        GuiZSetForNextWidget(gui, _layer(1));
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if GuiButton(gui, _nid(), col_b, offset_y + (idx * 10), string.format("Stash $ %1.0f", money_amt)) then
          transfer_money_player_to_stash(money_amt);
        end
      end
      idx = idx + 1;
    end

    GuiZSetForNextWidget(gui, _layer(1));
    GuiColorNextWidgetEnum(gui, COLORS.Green);
    if GuiButton(gui, _nid(), col_a, offset_y + (idx * 10), "Take ALL") then
      transfer_money_stash_to_player(stash_money);
    end

    GuiZSetForNextWidget(gui, _layer(1));
    GuiColorNextWidgetEnum(gui, COLORS.Green);
    if GuiButton(gui, _nid(), col_b, offset_y + (idx * 10), "Stash ALL") then
      transfer_money_player_to_stash(player_money);
    end
    idx = idx + 1;
    GuiZSetForNextWidget(gui, _layer(1));
    GuiText(gui, col_a + 20, offset_y + (idx * 10), string.format("Stashed: $ %1.0f", stash_money));
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
