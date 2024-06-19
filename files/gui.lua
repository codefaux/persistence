if persistence_gui_loaded==nil then persistence_gui_loaded=false; end
if persistence_gui_loaded==false then
  -- once, on load

  persistence_gui_loaded=true;
end


-- every frame;
if player_e_id==nil then return; end
if persistence_active then
  -- GamePrint("e_id: " .. (lobby_e_id or "x"));
  -- GamePrint("x_loc: " .. GlobalsGetValue("persistence_lobby_x", "x"));
  -- GamePrint("y_loc: " .. GlobalsGetValue("persistence_lobby_y", "x"));
  local x_loc, y_loc = EntityGetTransform(player_e_id);
  -- GamePrint("player: " .. x_loc .. " .. " .. y_loc);
  if GlobalsGetValue("lobby_collider_triggered", "x")=="1" then
    GamePrint("lobby triggered");
  end
  if GlobalsGetValue("workshop_collider_triggered", "x")=="1" then
    GamePrint("workshop triggered");
  end
end