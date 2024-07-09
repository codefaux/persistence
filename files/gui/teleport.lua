if teleport_loaded~=true then
  teleport_open=false;

  local function draw_teleport()
    local teleport_confirmation = 0;
    local x_loc = 275;
    local y_loc = 345;
    active_windows["teleport"] = function(_nid)
      GuiZSetForNextWidget(gui, __layer(1))
      if teleport_confirmation==0 then
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if GuiButton(gui, _nid(), x_loc, y_loc, "Teleport to Lobby") then
          teleport_confirmation = 1;
        end
        GuiGuideTip(gui, "In Persistence Workshop areas, you can teleport to this run's spawn point.", "(Requires confirmation)");
      elseif teleport_confirmation==1 then
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
        if GuiButton(gui, _nid(), x_loc, y_loc, "Press again to teleport to Lobby") then
          if teleport_back_to_lobby() then
            teleport_confirmation = 0;
          else
            teleport_confirmation = -1;
          end
        end
      elseif teleport_confirmation==-1 then
        GuiColorNextWidgetEnum(gui, COLORS.Red);
        GuiText(gui, x_loc, y_loc - 9, "(CAUTION)", small_text_scale);
        GuiTooltip(gui, "Warning: Could not find lobby, must assume location.", "Please be prepared to dig out of rock and soil.");
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
        if GuiButton(gui, _nid(), x_loc, y_loc, "Press again to teleport to Lobby") then
          if teleport_back_to_lobby() then
            teleport_confirmation = 0;
          else
            teleport_confirmation = -1;
          end
        end
        GuiTooltip(gui, "Warning: Could not find lobby, must assume location.", "Please be prepared to dig out of rock and soil.");
      end
    end;
  end

  function present_teleport()
    if teleport_open==true then return; end

    draw_teleport();
    teleport_open = true;
  end

  function close_teleport()
    if teleport_open==false then return; end

    active_windows["teleport"] = nil;
    teleport_open = false;
  end

  print("=========================");
  print("persistence: Teleport loaded.");
  teleport_loaded=true;
end
