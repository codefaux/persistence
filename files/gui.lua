if persistence_active==false then return; end
if persistence_gui_loaded~=true then
	-- once, on load
	dofile_once("data/scripts/debug/keycodes.lua");
	dofile_once(mod_dir .. "files/data_store.lua");
	dofile_once(mod_dir .. "files/gui_subfunc.lua");

	gui = GuiCreate();
	active_windows = {};
	fourslot_table = {};
	fourslot_confirmation = 0;
	spell_list_confirmation = 0;
	small_text_scale = 0.9;
	setting_buy_price_x = ModSettingGet("persistence.buy_wand_price_multiplier");
	spell_tooltip_id = "";

	profile_open=false;
	money_open=false;
	wands_open=false;
	inventory_spells_open=false;
	purchase_spells_open=false;
	modify_wand_open=false;
	template_open=false;

	function _nil(...) return; end
	function _layer(n) return 1000 - ((n+1) * 50); end

	dofile(mod_dir .. "files/gui/fourslot.lua");
	dofile(mod_dir .. "files/gui/spell_list.lua");


	modify_wand_table = {
		id = "modify_wand",
		centertext = "CREATE YOUR WAND",
		greentext = "Stats are limited to researched values.",
		redtext = "Better wands cost more. No refunds.",
		slot_title = "Wand slot %i:",
		render_slot_func = __render_wand_slot,
		render_header_func = function (x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
				local row1_y_offset = 2;
				local row2_y_offset = 11;
				local row3_y_offset = 18;
				local x_offset = 6;
				local _price = 0;
				if slot_data.cost~=nil then
					for _member, _cost in pairs(slot_data.cost) do
						_price = _price + _cost;
					end
				end
				slot_data.price = math.ceil(_price * ModSettingGet("persistence.buy_wand_price_multiplier"));
				if slot_data.origin_cost~=nil and slot_data.origin_cost~=0 then GuiText(gui, x_base + x_offset, y_base + row2_y_offset, string.format(" - $ %1.0f (PAID) ", slot_data.origin_cost )); end
				GuiZSetForNextWidget(gui, _layer(layer));
				GuiColorNextWidgetBool(gui, last_known_money >= slot_data.price);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base + row1_y_offset, string.format("Purchase: $ %1.0f", slot_data.price)) and slot_data.price <= get_player_money() then 
					slot_data.wand.price = slot_data.price - slot_data.origin_cost;
					local _create_success = create_wand(slot_data.wand);
					if _create_success and slot_data.origin_entity~=nil and slot_data.origin_entity~=0 then
						EntityKill(slot_data.origin_entity);
					end
					close_modify_wand();
					GamePrintImportant("Wand Purchased");
					return true;
				end
			end,
		datum_translation = {
			-- <name>							= {<label>,												<val_func>,	<height>,	<render_func>,						<widget_func>							cost_formula_func },
			_index = {[0] = 10, [1] = "wand_type", [2] = "shuffle", [3] = "spells_per_cast", [4] = "cast_delay", [5] = "recharge_time", [6] = "mana_max", [7] = "mana_charge_speed", [8] = "capacity", [9] = "spread", [10] = "always_cast_spells"},
			wand_type						= {"",															__val,			34,				__render_wand_type,			nil,											function (_) return 200; end	},
			shuffle							= {"$inventory_shuffle",						__yesno,		9,				__render_gen_stat,			__widget_toggle,					function (_shuffle) return _shuffle and 0 or 100; end	},
			spells_per_cast			= {"$inventory_actionspercast",			__val,			9,				__render_gen_stat,			__widget_slider,					function (a_p_c) return math.max(a_p_c-1,0)*500; end 	},
			cast_delay					= {"$inventory_castdelay",					__ctime,		9,				__render_gen_stat,			__widget_slider,					function (_castdelay) return (0.01 ^ ((_castdelay/60) - 1.8) + 200) * 0.1; end	},
			recharge_time				= {"$inventory_rechargetime",				__ctime,		9,				__render_gen_stat,			__widget_slider,					function (_rechargetime) return (0.01 ^ ((_rechargetime/60) - 1.8) + 200) * 0.1; end	},
			mana_max						= {"$inventory_manamax",						__round,		9,				__render_gen_stat,			__widget_slider,					function (_manamax) return _manamax; end	},
			mana_charge_speed		= {"$inventory_manachargespeed",		__val,			9,				__render_gen_stat,			__widget_slider,					function (_manachargespeed) return _manachargespeed * 2; end	},
			capacity						=	{"$inventory_capacity",						__val,			9,				__render_gen_stat,			__widget_slider,					function (_capacity) return (math.max(_capacity - 1, 0)) * 50; end	},
			spread							= {"$inventory_spread",							__deg,			9,				__render_gen_stat,			__widget_slider,					function (_spread) return math.abs(10 - _spread) * 5; end	},
			always_cast_spells	= {"$inventory_alwayscasts",				__val,			9,				__render_wand_spells,		nil,											function (_alwayscasts)  
				local _val = 0;
				for _, _a_c_id in ipairs(_alwayscasts) do
					if (_a_c_id~=nil and actions_by_id[_a_c_id]~=nil and actions_by_id[_a_c_id].price~=nil) then
						_val = _val + get_ac_cost(_a_c_id);
					end;
				end;
				return _val;
			end	},
		},
		slot_func = get_modify_wand_table,
		slot_data = {};
	};


	function draw_modify_wand(entity_id, slot_id)
		--init
		mod_wand_e_id = entity_id or 0;
		mod_wand_s_id = slot_id or 0;
		local _reload_data = true;
		local datum_sort_funcs = {
			_index = {[0]=4, [1]="sort_name", [2]="sort_cost_name", [3]="sort_type_name", [4]="sort_type_cost" },
			sort_name				= { "Name", 			function (a, b)
				return (GameTextGetTranslatedOrNot(a.name)<GameTextGetTranslatedOrNot(b.name));
				end },
			sort_cost_name	= {"Cost,Name",				function (a, b)
				if (a.price==b.price) then return (GameTextGetTranslatedOrNot(a.name)<GameTextGetTranslatedOrNot(b.name)); end
				return a.price<b.price;
				end },
			sort_type_name	= {"Type,Name",		function (a, b)
				if (a.type==b.type) then return (GameTextGetTranslatedOrNot(a.name)<GameTextGetTranslatedOrNot(b.name)); end
				return a.type<b.type;
				end },
			sort_type_cost	= {"Type,Cost,Name",		function (a, b)
				if (a.type==b.type) and (a.price)==(b.price) then return (GameTextGetTranslatedOrNot(a.name)<GameTextGetTranslatedOrNot(b.name)); end
				if (a.type==b.type) then return (a.price<b.price); end
				return a.type<b.type;
				end },
		};

		local _window_display = 0;
		local _active_sort_idx = 1;
		local _active_sort_name = datum_sort_funcs._index[_active_sort_idx];
		local _sorted = false;
		local _search_for = "";
		local _active_filter = 99;
		local _ac_sel_count = 0;
		local _ac_id_hash = {};

		active_windows["modify_wand"] = function(_nid)
			local function _gui_nop(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid) return; end

			if _reload_data~=false then modify_wand_table.slot_data = modify_wand_table.slot_func(mod_wand_e_id); _reload_data=false; end

			local x_base = 30;
			local y_base = 20;
			local margin = 4;
			local width = 448;
			local height = 200;
			local x_offset = x_base + margin;
			local y_offset = y_base + margin;
			local panel_width = 104;
			local panel_height = height - (margin * 2);
			GuiZSet(gui, _layer(0)); ---gui frame
			GuiImageNinePiece(gui, _nid(), x_base, y_base, width, height);

			local panel_x_offset = x_offset;
      GuiZSet(gui, _layer(1)); ---panel border
      GuiImageNinePiece(gui, _nid(), panel_x_offset, y_offset, panel_width, panel_height);

      local panel_sub_width = panel_width - (margin*2);
      local panel_sub_height = panel_height - (margin*2);
      panel_x_offset = panel_x_offset;
      panel_y_offset = y_offset;

      local header_x_pos = panel_x_offset;
      local header_y_pos = panel_y_offset;

      local label_x_pos = panel_x_offset + 23;
      local label_y_pos = header_y_pos + 27;
      GuiZSetForNextWidget(gui, _layer(2)); ---slot label
      GuiText(gui, label_x_pos, label_y_pos, string.format(modify_wand_table.slot_title, mod_wand_s_id), 1);

			local slot_x_pos = panel_x_offset + margin;
      local slot_y_pos = label_y_pos + 12;
      panel_sub_width = panel_width - (margin*2);
      panel_sub_height = panel_sub_height - (slot_y_pos - y_offset - margin);
      (modify_wand_table.render_slot_func or _gui_nop)(slot_x_pos, slot_y_pos, margin, panel_sub_width, panel_sub_height, 2, modify_wand_table.slot_data, _nid);

      local datum_x_pos = panel_x_offset + margin;
      local datum_y_pos = slot_y_pos + margin;

			local widget_x_pos = x_offset + panel_width + (margin * 2);
			local widget_y_pos = y_offset + margin;
			local widget_width = width - panel_width - (margin * 6);

			modify_wand_table.slot_data.cost = {};
			for ii = 1, modify_wand_table.datum_translation._index[0] do
				local _member = modify_wand_table.datum_translation._index[ii];
				local _value = modify_wand_table.slot_data.wand[_member];
				local _valfunc = modify_wand_table.datum_translation[_member][2];
				local _height = modify_wand_table.datum_translation[_member][3] or 0;
				modify_wand_table.slot_data.value = _valfunc(_value);
				modify_wand_table.slot_data.member = _member;
				modify_wand_table.slot_data.label = (modify_wand_table.datum_translation[_member][1]~=nil and modify_wand_table.datum_translation[_member][1]~="") and GameTextGetTranslatedOrNot(modify_wand_table.datum_translation[_member][1]) or "";
				modify_wand_table.slot_data.cost[_member] = (modify_wand_table.datum_translation[_member][6]~=nil and modify_wand_table.datum_translation[_member][6](_value) or 0) * ModSettingGet("persistence.buy_wand_price_multiplier");
				modify_wand_table.slot_data.render_slots_override = get_always_cast_count();
				local _renderfunc = modify_wand_table.datum_translation[_member][4] or _gui_nop;
				_renderfunc(datum_x_pos, datum_y_pos, margin, panel_width - margin, panel_height, 3, modify_wand_table.slot_data, _nid);
				datum_y_pos = datum_y_pos + _height;
				local _widgetfunc = modify_wand_table.datum_translation[_member][5] or _gui_nop;

				if _window_display==0 then ---- Render setting sliders
					if _widgetfunc~=_gui_nop then
						GuiZSet(gui, _layer(2));
						GuiBeginAutoBox(gui);
						local _newvalue = _widgetfunc(widget_x_pos, widget_y_pos, margin, widget_width - (margin * 2), panel_height, 3, modify_wand_table.slot_data, _nid);
						modify_wand_table.slot_data.wand[_member] = _newvalue;
						modify_wand_table.slot_data.cost[_member] = modify_wand_table.datum_translation[_member][6] and modify_wand_table.datum_translation[_member][6](_value) or 0;
						GuiZSet(gui, _layer(2));
						GuiEndAutoBoxNinePiece(gui, margin-2, widget_width, 10);
						local _height = select(7, GuiGetPreviousWidgetInfo(gui));
						widget_y_pos = widget_y_pos + _height + (margin - 1);
					end
				end
			end

			if _window_display==1 then ---- Render icon picker
				---right panel border
				GuiZSet(gui, _layer(2));
				GuiBeginScrollContainer(gui, _nid(), widget_x_pos, y_offset, width - panel_width - (margin * 6), panel_height - margin);
				local line_gap = 60;
				local icon_gap_x = 48;
				local _type_idx = 0;
				for _type_name, _type_known in pairs(modify_wand_table.slot_data.bounds["wand_types"]) do
					if _type_known==true then
						local _type_data = wands_by_type[_type_name];

						_type_idx = _type_idx + 1;
						local _type_x_offset = 24 + (((_type_idx - 1) % 6) * icon_gap_x);
						local _type_y_offset = 10 + math.floor((_type_idx - 1) / 6) * (line_gap);

						local wand_offset_x, wand_offset_y = get_wand_rotated_offset(_type_data.grip_x, _type_data.grip_y, -45);

						GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter)
						GuiZSetForNextWidget(gui, _layer(3))
						if GuiButton(gui, _nid(), _type_x_offset + 16, widget_y_pos + _type_y_offset - 4, "Select") then
							modify_wand_table.slot_data.wand["wand_type"] = _type_name;
							_window_display=-1;
							break;
						end
						local gui_icon = (select(3, GuiGetPreviousWidgetInfo(gui))) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";

						local frame_offset_x = 9;
						local frame_offset_y = -13;

						GuiZSetForNextWidget(gui, _layer(3))
						GuiImage(gui, _nid(), _type_x_offset, y_offset + _type_y_offset, gui_icon, 1, 1.5, 1.5, math.rad(-90)); -- radians are annoying
						GuiZSetForNextWidget(gui, _layer(4))
						GuiImage(gui, _nid(), _type_x_offset + frame_offset_x + wand_offset_x, widget_y_pos + _type_y_offset + frame_offset_y - wand_offset_y, _type_data.file, 1, 1, 1, math.rad(-45)); -- radians are annoying
					end
				end
			elseif _window_display==2 then --- Render Always Cast Spell picker
				GuiZSetForNextWidget(gui, _layer(2));
				if GuiButton(gui, _nid(), 400, 6, "Sort: " .. datum_sort_funcs[_active_sort_name][1] ) then
					_active_sort_idx = (_active_sort_idx<datum_sort_funcs._index[0]) and (_active_sort_idx + 1) or 1;
					_active_sort_name = datum_sort_funcs._index[_active_sort_idx];
					_sorted = false;
				end

				if _sorted~=true then table.sort(modify_wand_table.slot_data.ac_spells, datum_sort_funcs[_active_sort_name][2]); _sorted=true;	end

				GuiZSetForNextWidget(gui, _layer(2));
				GuiText(gui, 240, 6, "Search:", 1);
				_search_for = GuiTextInput(gui, _nid(), 270, 5, _search_for, 100, 20);
				if select(2, GuiGetPreviousWidgetInfo(gui))  then _search_for = ""; end

				local _f_idx = 1;
				GuiText(gui, 26, 6, "Filter:");
				for _type_nr, _type_bool in pairs(modify_wand_table.slot_data.ac_spells._index.type_hash) do
					if _type_bool then
						if _type_nr~=99 then
							_f_idx = _f_idx + 1;
						end
						local _filter_x_offset = 40 + ( (_type_nr==99 and 1 or _f_idx) * 20);
						if GuiImageButton(gui, _nid(), _filter_x_offset, 1, "", action_type_to_slot_sprite(_type_nr)) then
							if _active_filter~=_type_nr then
								_active_filter = _type_nr;
							else
								_active_filter = 99;
							end
						end
						GuiTooltip(gui, _type_nr==99 and "ALL" or action_type_to_string(_type_nr), "");
						if _type_nr==_active_filter then
							local _mark_offset_x = 10;
							local _mark_offset_y = 8;
							GuiImage(gui, _nid(), _filter_x_offset + _mark_offset_x, _mark_offset_y, "data/ui_gfx/damage_indicators/explosion.png", 0.5, 1, 1, math.rad(45)); -- radians are annoying
						end
					end
				end


				---right panel border
				GuiZSet(gui, _layer(2));
				GuiBeginScrollContainer(gui, _nid(), widget_x_pos, y_offset, width - panel_width - (margin * 6), panel_height - margin);
				local spell_y_offset = margin;
				local spell_y_height = 26;
				_ac_id_hash = {};
				_ac_sel_count = 0;

				for _sel_ac_idx, _sel_ac_name in pairs(modify_wand_table.slot_data.wand.always_cast_spells) do
					---- Render currently selected AC spells -- do not touch
					__render_inv_spell_single(margin, spell_y_offset, margin, panel_width, panel_height, 3, get_spell_purchase_single(_sel_ac_name), _nid);
					GuiZSetForNextWidget(gui, _layer(3));
					GuiColorNextWidgetEnum(gui, COLORS.Dim);
					GuiText(gui, margin, spell_y_offset + 10, string.format(" $ %1.0f", get_ac_cost(_sel_ac_name)) );
					GuiZSetForNextWidget(gui, _layer(3));
					GuiColorNextWidgetEnum(gui, COLORS.Yellow);
					if GuiButton(gui, _nid(), margin, spell_y_offset, __yesno(true)) then
							table.remove(modify_wand_table.slot_data.wand.always_cast_spells, _sel_ac_idx);
					end
					_ac_id_hash[_sel_ac_name]=true;
					_ac_sel_count = _ac_sel_count + 1;
					spell_y_offset = spell_y_offset + 26;
				end

				for _ac_idx = 1, modify_wand_table.slot_data.ac_spells._index.count do
					local _ac_name = modify_wand_table.slot_data.ac_spells[_ac_idx].a_id;
					local show_curr_spell = true;
          if _search_for~= "" and string.find(string.lower(GameTextGetTranslatedOrNot(actions_by_id[_ac_name].name)), string.lower(_search_for), 1, true)==nil then
            show_curr_spell = false;
          end
					if _active_filter~=99 and _active_filter~=actions_by_id[_ac_name].type then
						show_curr_spell = false;
					end

					if show_curr_spell==true then
						if _ac_id_hash[_ac_name]~=true then
							__render_inv_spell_single(margin, spell_y_offset, margin, panel_width, panel_height, 3, modify_wand_table.slot_data.ac_spells[_ac_idx], _nid);
							GuiZSetForNextWidget(gui, _layer(3));
							GuiColorNextWidgetEnum(gui, COLORS.Tip);
							GuiText(gui, margin, spell_y_offset + 10, string.format(" $ %0.0f", get_ac_cost(_ac_name)));
							GuiZSetForNextWidget(gui, _layer(3));
							local _fit_more = _ac_sel_count < get_always_cast_count();
							GuiColorNextWidgetBool(gui, _fit_more);
							if GuiButton(gui, _nid(), margin, spell_y_offset, __yesno(false)) and (_fit_more) then
								table.insert(modify_wand_table.slot_data.wand.always_cast_spells, _ac_name);
							end
							spell_y_offset = spell_y_offset + 26;
						end
					end
				end
			end
			if _window_display~=0 then GuiEndScrollContainer(gui); end;

			if _window_display<0 then _window_display=0; end

			local icon_x_base = x_base + 46;
			local icon_y_base = slot_y_pos + margin + 8;
			---gui button for icon pick, always cast pick
			GuiZSetForNextWidget(gui, _layer(3));
			if _window_display==1 then 
				GuiColorNextWidgetEnum(gui, COLORS.Green);
			elseif _window_display==2 then 
				GuiColorNextWidgetEnum(gui, COLORS.Dim);
			else
				GuiColorNextWidgetEnum(gui, COLORS.Yellow);
			end
			if GuiButton(gui, _nid(), icon_x_base, icon_y_base, "[WAND TYPE]", small_text_scale) then
				_window_display = _window_display~=1 and 1 or 0;
				GamePrint("Pick wand type");
			end 
			local sel_ac_x_base = x_base + 54;
			local sel_ac_y_base = slot_y_pos + panel_sub_height - 10;
			GuiZSetForNextWidget(gui, _layer(3));
			GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
			if _window_display==1 then 
				GuiColorNextWidgetEnum(gui, COLORS.Dim);
			elseif _window_display==2 then 
				GuiColorNextWidgetEnum(gui, COLORS.Green);
			else
				GuiColorNextWidgetEnum(gui, COLORS.Yellow);
			end
			if GuiButton(gui, _nid(), sel_ac_x_base, sel_ac_y_base, "[ALWAYS CASTS]", small_text_scale) then
				_window_display = _window_display~=2 and 2 or 0;
				GamePrint("Pick wand type");
			end 

			if (modify_wand_table.render_header_func or _gui_nop)(header_x_pos, header_y_pos, margin, panel_sub_width, panel_sub_height, 2, modify_wand_table.slot_data, _nid) then
        _reload_data = true;
      end
			__render_tricolor_footer(x_base, y_base, width, height, modify_wand_table);
		end
	end

	function present_modify_wand(entity_id, slot_id)
		if modify_wand_open==true then return; end

		close_wands();
		draw_modify_wand(entity_id, slot_id);
		present_template_window();
		modify_wand_open=true;
	end

	function close_modify_wand()
		if modify_wand_open==false then return; end

		active_windows["modify_wand"] = nil;
		close_template_window();
		modify_wand_open = false;
	end

	function draw_template_window()
		local _reload_data = true;
		local template_previews = {};
		local delete_template_confirmation = 0;

		active_windows["template"] = function (_nid)
			local margin=5;
			local x_base = 485;
			local y_base = 150;
			local width = 140;
			local height = 200;
			local line_height = 11;
			local block_height = (line_height * 3) + margin;
			if _reload_data then template_previews = get_templates(); _reload_data=false; end

			GuiZSetForNextWidget(gui, _layer(0));
			GuiImageNinePiece(gui, _nid(), x_base, y_base, width, height);

			for i = 1, get_template_count() do
				local x_offset = x_base + margin;
				local y_offset = y_base + margin + ((i - 1) * block_height);
				local col_a = 25;
				-- GuiLayoutBeginVertical(gui, 80, 44 + ((i-1) * 11));
				GuiText(gui, x_offset, y_offset, "Template Slot " .. i .. ":");
				if template_previews[i]==nil or template_previews[i].capacity==nil then	-- Template empty
					GuiColorNextWidgetEnum(gui, COLORS.Green);
					if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 1), "Save template") then
						set_template(i, modify_wand_table.slot_data.wand);
					end
				else -- Template exists
					-- GuiLayoutBeginHorizontal(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					GuiImage(gui, _nid(), x_offset, y_offset + 23, wand_type_to_sprite_file(template_previews[i]["wand_type"]), 1, 1, 1, math.rad(-45)); -- radians are annoying

					-- GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					GuiColorNextWidgetEnum(gui, COLORS.Green);
					if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 1), "Load template") then
						GamePrint("Load Template");
						modify_wand_table.slot_data.wand = get_template(i);
					end
					if delete_template_confirmation == i then
						GuiColorNextWidgetEnum(gui, COLORS.Yellow);
						if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 2), "Press again to delete") then
							delete_template_confirmation = 0;
							delete_template(i);
							GamePrint("Delete Template");
						end
					else
						GuiColorNextWidgetEnum(gui, COLORS.Yellow);
						if GuiButton(gui, _nid(), x_offset + col_a, y_offset + (line_height * 2), "Delete template") then
							delete_template_confirmation = i;
						end
					end
					-- -- GuiLayoutEnd(gui);
					-- -- GuiLayoutEnd(gui);
				end
				-- GuiLayoutEnd(gui);
			end
		end
	end

	function show_spell_tooltip_gui(in_x_loc, in_y_loc)
		if spell_tooltip_id~="" and spell_tooltip_open==false then
			spell_tooltip_open = true;
			local x_loc = in_x_loc or 120;
			local y_loc = in_y_loc or 245;

			local curr_spell = actions_by_id[spell_tooltip_id];
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

				GuiZSetForNextWidget(gui, _layer(3));
				local action_struct_pool = get_action_struct(curr_spell);
				for _, action_struct in ipairs(action_struct_pool) do
					if action_struct.name=="name" then
						GuiText(gui, col_a, y_loc, action_struct.value);			-- NAME
					elseif action_struct.name=="description" then
						GuiText(gui, col_a, y_loc + 3 + line_h, action_struct.value);			-- Description
					elseif action_struct.name=="sprite" then
						GuiImage(gui, _nid(), col_d, y_loc + 28, action_struct.icon, 1, 1.5, 1.5, 0);		-- ICON
					else
						line_cnt = line_cnt + 1;
						line_y = base_y + (line_h * line_cnt);
						GuiImage(gui, _nid(), col_a, line_y + 2, action_struct.icon, 1, 1, 1, 0);
						GuiZSetForNextWidget(gui, _layer(3));
						GuiText(gui, col_b, line_y, action_struct.label);
						GuiZSetForNextWidget(gui, _layer(3));
						GuiText(gui, col_c, line_y, action_struct.value);
					end
				end

				GuiZSetForNextWidget(gui, _layer(2));
				GuiZSet(gui, _layer(2));
				GuiEndAutoBoxNinePiece(gui, 4, 100, 25);
				-- GuiLayoutEndLayer(gui);
			end;
		elseif spell_tooltip_id~="" and spell_tooltip_open==true then
			close_spell_tooltip_gui();
		end
	end

	function close_spell_tooltip_gui()
		spell_tooltip_open = false
		active_windows["spell_tooltip"] = nil;
	end

	function present_template_window()
		if template_open==true then return; end

		draw_template_window();
		template_open = true;
	end

	function close_template_window()
		if template_open==false then return; end

		active_windows["template"] = nil;
		template_open = false;
	end


	function present_inventory_spells()
		if inventory_spells_open==true then return; end

		draw_spell_list_ui(inventory_spell_list_table);
		inventory_spells_open = true;
	end

	function close_inventory_spells()
		if inventory_spells_open==false then return; end

		active_windows[inventory_spell_list_table.id] = nil;
		inventory_spells_open = false;
	end

	function present_purchase_spells()
		if purchase_spells_open==true then return; end

		draw_spell_list_ui(purchase_spell_list_table);
		purchase_spells_open = true;
	end

	function close_purchase_spells()
		if purchase_spells_open==false then return; end

		active_windows[purchase_spell_list_table.id] = nil;
		purchase_spells_open = false;
	end

	function present_profile_ui()
		if profile_open==true then return; end

		draw_fourslot_ui(profile_fourslot);
		profile_open = true;
	end

	function close_profile_ui()
		if profile_open==false then return; end

		active_windows[profile_fourslot.id] = nil;
		profile_open = false;
	end

	function present_wands()
		if wands_open==true then return; end

		draw_fourslot_ui(wands_fourslot);
		wands_open = true;
	end

	function close_wands()
		if wands_open==false then return; end

		active_windows[wands_fourslot.id] = nil;
		wands_open = false;
	end

	function present_teleport_gui()
		if teleport_open==true then return; end

		local teleport_confirmation = false;
		local x_loc = 275;
		local y_loc = 345;
		active_windows["teleport"] = function(_nid)
			GuiZSetForNextWidget(gui, _layer(1))
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
			end
		end;
		teleport_open = true;
	end

	function close_teleport_gui()
		if teleport_open==false then return; end

		active_windows["teleport"] = nil;
		teleport_open = false;
	end

	function present_money()
	if money_open==true then return; end

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

	function close_money()
		if money_open==false then return; end

		active_windows["money"] = nil;
		money_open = false;
	end

	function present_persistence_menu()
		if persistence_visible==true then return; end

		persistence_expanded = false;
		active_windows["persistence"] = function (_nid)
			local function scanEntities_for_persistence_color()
				local player_owned = false;
				local nearby_known = false;
				local plr_x, plr_y = EntityGetTransform(player_e_id);
				local _nearby_cards = EntityGetInRadiusWithTag(plr_x, plr_y, 20, "card_action");
				for _, _card_e_id in pairs(_nearby_cards) do
					local _tmp_e_id = _card_e_id;
					while _tmp_e_id~=0 and _tmp_e_id~=nil do
						_tmp_e_id = EntityGetParent(_tmp_e_id);
						if _tmp_e_id==player_e_id then player_owned=true; end
					end
					if not player_owned then
						local _action_c_id = EntityGetFirstComponentIncludingDisabled(_card_e_id, "ItemActionComponent") or 0;
						local _action_id = ComponentGetValue(_action_c_id, "action_id");
						local _known = does_profile_know_spell(_action_id)
						if not _known then
							return COLORS.Tip;
						else
							nearby_known = true;
						end
					end
				end
				return nearby_known and COLORS.Yellow or COLORS.White;
			end

			local x_base = 2;
			local x_offset = 25;
			local y_base = 348;
			local y_expand = 40;
			if persistence_expanded==false then
				GuiZSet(gui, _layer(0)); ---gui frame
				GuiImageNinePiece(gui, _nid(), x_base, y_base, 50, 10);
				GuiZSet(gui, _layer(1));

				local _btn_color = scanEntities_for_persistence_color();
				GuiColorNextWidgetEnum(gui, _btn_color);
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base, "persistence", 1) then
					persistence_expanded = true;
					present_money();
					present_wands();
					close_purchase_spells();
					close_inventory_spells();
					close_modify_wand();
				end
			else
				GuiZSet(gui, _layer(0)); ---gui frame
				GuiImageNinePiece(gui, _nid(), x_base, y_base - y_expand, 48, 10 + y_expand);
				GuiZSet(gui, _layer(1));
				GuiColorNextWidgetEnum(gui, (wands_open and COLORS.Green or COLORS.Bright));
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base - 40, "wands", 1) then
					present_money();
					close_purchase_spells();
					close_inventory_spells();
					present_wands();
					close_modify_wand();
				end

				GuiZSet(gui, _layer(1));
				GuiColorNextWidgetEnum(gui, ((purchase_spells_open or inventory_spells_open) and COLORS.Green or COLORS.Dark));
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base - 28, "spells:", 1) then
					present_money();
					close_wands();
					close_inventory_spells();
					present_purchase_spells();
					close_modify_wand();
				end

				GuiZSet(gui, _layer(1));
				GuiColorNextWidgetEnum(gui, (purchase_spells_open and COLORS.Green or COLORS.Bright));
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base - 19, "purchase", 1) then
					present_money();
					close_wands();
					close_inventory_spells();
					present_purchase_spells();
					close_modify_wand();
				end


				GuiZSet(gui, _layer(1));
				GuiColorNextWidgetEnum(gui, (inventory_spells_open and COLORS.Green or COLORS.Bright));
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base - 11, "research", 1) then
					present_money();
					close_wands();
					close_purchase_spells();
					present_inventory_spells();
					close_modify_wand();
				end

				GuiZSet(gui, _layer(1));
				GuiColorNextWidgetEnum(gui, COLORS.Yellow);
				GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
				if GuiButton(gui, _nid(), x_base + x_offset, y_base, "-close-", 1) then
					close_money();
					close_wands();
					close_purchase_spells();
					close_inventory_spells();
					close_modify_wand();
					persistence_expanded=false;
				end
			end
		end
		persistence_visible = true;
	end

	function close_persistence_menu()
		persistence_visible = false;
		active_windows["persistence"] = nil;
	end
	---end function declarations, run code here;

  print("=========================");
  print("persistence: GUI loaded.");
	persistence_gui_loaded=true;
end

-- every frame;
local _lobby = GlobalsGetValue("lobby_collider_triggered", "0")~="0";
local _workshop = GlobalsGetValue("workshop_collider_triggered", "0")~="0";
local _persistence_area = _lobby==true or _workshop==true;

data_store_everyframe();

if loaded_profile_id>0 then
	---profile loaded, proceed as normal
	if profile_open then close_profile_ui(); end

	if isLocked() then UnlockPlayer(); end

	if InputIsKeyJustDown(Key_TAB) then
		close_money();
		close_wands();
		close_modify_wand();
		close_purchase_spells();
		close_inventory_spells();
	end
	if _workshop then
		present_teleport_gui();
	else
		close_teleport_gui();
	end
	if _persistence_area then
		present_persistence_menu();
	else
		close_persistence_menu();
	end
else
	if not isLocked() then LockPlayer(); end
	present_profile_ui();
end

local window_open = profile_open or money_open or wands_open or inventory_spells_open;

if gui~=nil and active_windows~=nil and (window_open or persistence_visible) and EntityGetIsAlive(player_e_id) then
	-- if not isLocked() then LockPlayer(); end
	GuiStartFrame(gui);
	local start_gui_id = 319585;
	if window_open then
		if not isLocked() then LockPlayer(); end
		GuiZSetForNextWidget(gui, 1000);
		GuiImage(gui, start_gui_id - 1, 0, 0, mod_dir .. "files/img/gui_darken.png", 1, 1, 1, 0);
	end
	for name, window in pairs(active_windows) do
		if window~=nil then
			local gui_id = start_gui_id + simple_string_hash(name);
			window(function()
				gui_id = gui_id + 1;
				return gui_id;
			end);
		end
	end
else
	if isLocked() then UnlockPlayer(); end
end