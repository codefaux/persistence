if spell_tooltip_loaded~=true then
  spell_tooltip_open=false;
  local curr_spell = {};

  local function draw_spell_tooltip(in_x_loc, in_y_loc)
      local x_loc = in_x_loc or 120;
      local y_loc = in_y_loc or 245;

      curr_spell = actions_by_id[spell_tooltip_id];
      if curr_spell.metadata==nil then get_action_metadata(curr_spell.id); end

      active_windows["spell_tooltip"] = function(_nid)

        local col_a = x_loc + 0;
        local col_b = x_loc + 15;
        local col_c = x_loc + 100;
        local col_d = x_loc + 145;

        local line_h = 8;
        local base_y = y_loc + 6;
        local line_y = 3;
        local line_cnt = 1;

        -- GuiLayoutBeginLayer(gui);
        GuiZSetForNextWidget(gui, _layer(2));
        GuiBeginAutoBox(gui);

        local action_struct_pool = get_action_struct(curr_spell);
        for _, action_struct in ipairs(action_struct_pool) do
          if action_struct.name=="name" then
            GuiZSetForNextWidget(gui, _layer(3));
            GuiText(gui, col_a, y_loc, action_struct.value);      -- NAME
          elseif action_struct.name=="description" then
            GuiZSetForNextWidget(gui, _layer(3));
            GuiText(gui, col_a, y_loc + 3 + line_h, action_struct.value);      -- Description
          elseif action_struct.name=="sprite" then
            GuiZSetForNextWidget(gui, _layer(3));
            GuiImage(gui, _nid(), col_d, y_loc + 28, action_struct.icon, 1, 1.5, 1.5, 0);    -- ICON
          else
            line_cnt = line_cnt + 1;
            line_y = base_y + (line_h * line_cnt);
            GuiZSetForNextWidget(gui, _layer(3));
            GuiImage(gui, _nid(), col_a, line_y + 2, action_struct.icon, 1, 1, 1, 0);
            GuiZSetForNextWidget(gui, _layer(3));
            GuiText(gui, col_b, line_y, action_struct.label);
            GuiZSetForNextWidget(gui, _layer(3));
            GuiText(gui, col_c, line_y, action_struct.value);
          end
        end

        GuiZSetForNextWidget(gui, _layer(2));
        GuiEndAutoBoxNinePiece(gui, 4, 100, 25);
        -- GuiLayoutEndLayer(gui);
      end;
      spell_tooltip_open = true;
  end

  function present_spell_tooltip(in_x_loc, in_y_loc)
    if spell_tooltip_id~="" and (spell_tooltip_id~=curr_spell.id or spell_tooltip_open==false) then
      draw_spell_tooltip(in_x_loc, in_y_loc);
    elseif spell_tooltip_id=="" and spell_tooltip_open==true then
      close_spell_tooltip();
    end
  end

  function close_spell_tooltip()
    if spell_tooltip_open==false then return; end

    spell_tooltip_id="";
    active_windows["spell_tooltip"] = nil;
    spell_tooltip_open = false;
  end

  print("=========================");
  print("persistence: Spell tooltip loaded.");
  spell_tooltip_loaded=true;
end