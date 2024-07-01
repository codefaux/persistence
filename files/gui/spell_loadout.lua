if spell_loadouts_loaded~=true then
  dofile("data/scripts/debug/keycodes.lua");

  spell_loadouts_open=false;
  local _saved_spell_loadouts;
  reload_ui_data = true;

  -- ModSettingSetNextValue("persistence.loadout_1", "Kaboom,SUMMON_HOLLOW_EGG,BOMB,PROPANE_TANK,BOMB,BOMB,BOMB,BOMB,BOMB,BOMB,BOMB,EXPANDING_ORB,BOMB,BOMB,BOMB,BOMB,BOMB,BOMB,BOMB,SUMMON_ROCK", false);
  -- ModSettingSetNextValue("persistence.loadout_3", "Kaboom 2,SUMMON_HOLLOW_EGG,PROPANE_TANK,BOMB,EXPANDING_ORB,BOMB,SUMMON_ROCK", false);
  -- ModSettingSetNextValue("persistence.loadout_4", "Simple,BURST_2,LIGHT_BULLET,CHAINSAW", false);

  local function draw_spell_loadouts(in_x_loc, in_y_loc)

    local function _get_stored_loadouts()
      local _return = {};
      local _stored_loadout;
      local _stored_loadout_idx=0;
      repeat
        _stored_loadout_idx = _stored_loadout_idx + 1;
        _stored_loadout = ModSettingGetNextValue("persistence.loadout_" .. _stored_loadout_idx);
        if _stored_loadout then
          _return[_stored_loadout_idx] = {price = 0};
          local _word_idx = 0;
          for _word in string.gmatch(_stored_loadout,'([^,]+)') do
            if _word_idx==0 then
              _return[_stored_loadout_idx].name = _word;
              _return[_stored_loadout_idx].spells = {};
            else
              if actions_by_id[_word]~=nil then
                _return[_stored_loadout_idx].price = _return[_stored_loadout_idx].price + math.ceil(actions_by_id[_word].price * mod_setting.buy_spell_price_multiplier);
                _return[_stored_loadout_idx].spells[_word_idx] = _word;
              end
            end
            _word_idx = _word_idx + 1;
          end
        end

      until _stored_loadout==nil;

      return _return;
    end

    local function save_spell_loadout(idx, spell_loadout)
      local _spell_string = spell_loadout.name;
      for _, _spell_a_id in ipairs(spell_loadout.spells) do
        _spell_string = _spell_string .. "," .. _spell_a_id;
      end
      print("persistence.loadout_" .. idx);
      print("{" .. _spell_string .. "}");
      ModSettingSetNextValue("persistence.loadout_" .. idx, _spell_string, false);
      -- spell_loadout{name, spells[]}
    end

    local x_base = in_x_loc or 485;
    local y_base = in_y_loc or 150;

    local _panel_width = 140;
    local _panel_height = 200;
    local _unit_margin = 2;
    local _unit_width = 20;
    local _unit_height = 20;
    local _unit_columns = 6;
    local _unit_datas = {};
    local _list_confirm = 0;
    local _name_temp = "";
    local _reload_data = true;
    local _wands = {};
    local _new_loadout_spells = {};
    local _saved_spell_loadouts = {};

    active_windows["spell_loadout"] = function(_nid)
      local _y_offset = 0;

      if _reload_data==true then _wands = get_player_wands(); _saved_spell_loadouts = _get_stored_loadouts(); _reload_data=false; end;


      GuiZSetForNextWidget(gui, _layer(2));
      GuiBeginScrollContainer(gui, _nid(), x_base, y_base, _panel_width, _panel_height);

      for _loadout_idx = 1, 10 do
        if _saved_spell_loadouts[_loadout_idx]~=nil and _saved_spell_loadouts[_loadout_idx].name~=nil then
          _loadout_data = _saved_spell_loadouts[_loadout_idx];
          GuiZSetForNextWidget(gui, _layer(2));
          GuiText(gui, 0, _y_offset, string.format("Loadout %i: %s ($ %i)", _loadout_idx, _loadout_data.name, _loadout_data.price), 1);
          _y_offset = _y_offset + 10;
          GuiZSetForNextWidget(gui, _layer(3));
          GuiColorNextWidgetEnum(gui, COLORS.Yellow);
          if _list_confirm==-_loadout_idx then
            if GuiButton(gui, _nid(), 15, _y_offset, "CONFIRM", 1) then
              ModSettingSetNextValue("persistence.loadout_" .. _loadout_idx, "", false);
              _reload_data=true;
              _list_confirm=0;
            end
          else
            if GuiButton(gui, _nid(), 15, _y_offset, "Clear", 1) then
              _list_confirm=-_loadout_idx;
            end
          end
          GuiZSetForNextWidget(gui, _layer(3));
          GuiColorNextWidgetBool(gui, _loadout_data.price<=last_known_money);
          if GuiButton(gui, _nid(), 65, _y_offset, "Purchase", 1) and _loadout_data.price<=last_known_money then
            for _, _spell in pairs(_loadout_data.spells) do
              if does_profile_know_spell(_spell) then
                purchase_spell(_spell);
                GamePrintImportant("Purchased Spell", actions_by_id[_spell].name);
              end
            end
          end
          _y_offset = _y_offset + 9;
          local _y_loc = 0;
          for _loadout_spell_idx, _loadout_spell_a_id in pairs(_loadout_data.spells) do
            local _x_loc = (((_loadout_spell_idx-1) % _unit_columns) * (_unit_width + _unit_margin)) + _unit_margin;
            _y_loc = (math.floor((_loadout_spell_idx-1) / _unit_columns) * (_unit_height + _unit_margin)) + _unit_margin + _y_offset;
            if actions_by_id[_loadout_spell_a_id]~=nil then
              __render_spell_gridtile(_x_loc, _y_loc, 4, _panel_width, _panel_height, 3, get_spell_purchase_single(_loadout_spell_a_id), _nid );
            else
              -- render blank tile?
            end
          end
          _y_offset = _y_loc + _unit_height + (_unit_margin * 3);
        else
          _y_offset = _y_offset + 2 + _unit_margin;
          GuiZSetForNextWidget(gui, _layer(3));
          GuiText(gui, 0, _y_offset, string.format("Loadout %i: Create from Wand:", _loadout_idx), 1);
          _y_offset = _y_offset + 9;
          if _list_confirm~=_loadout_idx then
            for _slot_idx = 1, 4 do -- save loadout from slot buttons
              local _slot_exists = _wands[_slot_idx].e_id~=nil and _wands[_slot_idx].e_id~=0 and #_wands[_slot_idx].wand.spells>0;
              GuiZSetForNextWidget(gui, _layer(3));
              GuiColorNextWidgetEnum(gui, _slot_exists and COLORS.White or COLORS.Dark);
              if GuiButton(gui, _nid(), _unit_margin + (35 * (_slot_idx-1)), _y_offset, "Slot " .. _slot_idx, 1) then
                if _slot_exists then
                  _list_confirm = _loadout_idx;
                  _name_temp = "";
                  _new_loadout_spells = _wands[_slot_idx].wand.spells;
                end
              end
            end
          else
            _y_offset = _y_offset + 2;
            GuiZSetForNextWidget(gui, _layer(3));
            _name_temp = GuiTextInput(gui, _nid(), _unit_margin, _y_offset, _name_temp, 80, 16, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789 -/+");
            GuiZSetForNextWidget(gui, _layer(4));
            if GuiButton(gui, _nid(), 86, _y_offset, "Save", 1) or InputIsKeyJustDown(Key_RETURN) then
              save_spell_loadout(_loadout_idx, {name = _name_temp, spells = _new_loadout_spells});
              _list_confirm = 0;
              _reload_data = true;
            end
            GuiZSetForNextWidget(gui, _layer(4));
            GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
            if GuiButton(gui, _nid(), _panel_width - _unit_margin, _y_offset, "Cancel", 1) then
              _list_confirm = 0;
              _reload_data = true;
            end
            _y_offset = _y_offset - 2;
          end
          _y_offset = _y_offset + 9 + (_unit_margin * 3);

        end
      end

      GuiEndScrollContainer(gui);
    end;
  end

  function present_spell_loadouts(in_x_loc, in_y_loc)
    if spell_loadouts_open==true then return; end

    draw_spell_loadouts(in_x_loc, in_y_loc);
    spell_loadouts_open = true;
  end

  function close_spell_loadouts()
    if spell_loadouts_open==false then return; end

    active_windows["spell_loadout"] = nil;
    spell_loadouts_open = false;
  end

  print("=========================");
  print("persistence: Spell loadouts loaded.");
  spell_loadouts_loaded=true;
end