if teleport_loaded~=true then
  teleport_open=false;

  local function draw_teleport()
    local teleport_confirmation = false;
    local x_loc = 275;
    local y_loc = 345;
    active_windows["teleport"] = function(_nid)
      GuiZSetForNextWidget(gui, __layer(1))
      if teleport_confirmation then
        GuiColorNextWidgetEnum(gui, COLORS.Yellow);
        if GuiButton(gui, _nid(), x_loc, y_loc, "Press again to teleport to Lobby") then
          teleport_back_to_lobby();
        end
      else
        GuiColorNextWidgetEnum(gui, COLORS.Green);
        if GuiButton(gui, _nid(), x_loc, y_loc, "Teleport to Lobby") then
          teleport_confirmation = true;
        end
        GuiGuideTip(gui, "In Persistence Workshop areas, you can teleport to this run's spawn point.", "(Requires confirmation)");
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
