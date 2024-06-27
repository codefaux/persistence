
---@enum colors
	COLORS = {
		Red = {1, 0.5, 0.5, 1},
		Green = {0.5, 1, 0.5, 1},
		Blue = {0.25, 0.25, 1, 1},
		Yellow = {1, 1, 0.5, 1},
		Dim = {0.75, 0.75, 0.75, 1},
		Dark = {0.333, 0.333, 0.333, 1},
		Tip = {0.666, 0.666, 0.80, 1},
		Bright = {0.85, 0.9, 1, 1},
		Purple = {1, 0.25, 1, 1},
		White = {1, 1, 1, 1}
	}

	table.unpack=table.unpack or unpack;

	---@param value colors
	function GuiColorNextWidgetEnum(gui, value)
		GuiColorSetForNextWidget(gui, table.unpack(value))
		end

	function GuiColorNextWidgetBool(gui, value)
		if value then
			GuiColorNextWidgetEnum(gui, COLORS.Green);
		else
			GuiColorNextWidgetEnum(gui, COLORS.Red);
		end
	end

	function __render_tricolor_footer(x_base, y_base, width, height, textdata)
    GuiColorNextWidgetEnum(gui, COLORS.Green); ---green text
    GuiZSetForNextWidget(gui, _layer(2));
    GuiText(gui, x_base, height + 25, textdata.greentext, small_text_scale);

    GuiColorNextWidgetEnum(gui, COLORS.Red); ---red text
    GuiZSetForNextWidget(gui, _layer(2));
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
    GuiText(gui, x_base + width, height + 25, textdata.redtext, small_text_scale);

    GuiColorNextWidgetEnum(gui, COLORS.Tip); ---middle text
    GuiZSetForNextWidget(gui, _layer(2));
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
    GuiText(gui, x_base + (width / 2), height + 25, textdata.centertext, 1);
	end

	__show_always = function(_) return true; end
	__show_nz = function(value) return (value~=nil and value~=0) and true or false; end
	__show_many = function(value) return (value~=nil and value>1) and true or false; end

	__val = function(value) if type(value)=="table" then return value; elseif type(value)=="number" then return tostring(value); end return value; end
	__trans = function(value) return GameTextGetTranslatedOrNot(value); end
	__yesno = function(value) return value and "$menu_yes" or "$menu_no"; end
	__time = function(value) return GameTextGet("$inventory_seconds", string.format("%1.2f", value)); end
	__ctime = function(value) return GameTextGet("$inventory_seconds", string.format("%1.2f", math.floor((value / 60) * 100 + 0.5) / 100)); end
	__deg = function(value) return GameTextGet("$inventory_degrees", string.format("%d", value)); end
	__pct = function(value) return GameTextGet("$menu_slider_percentage", value); end
	__round = function(value) return math.floor(value + 0.49999999999999994); end
	__nil = function(_) return nil; end
	__type = function(value) return action_type_to_string(value); end
	__cntarr = function(value) if type(value)=="table" then return #value; end return -1; end

	function __render_wand_slot(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
		GuiZSet(gui, _layer(layer)); ---gui frame
		GuiImageNinePiece(gui, _nid(), x_base, y_base, panel_width, panel_height);

		local gui_icon = (slot_data.research~=nil and slot_data.research.is_new) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";
		GuiZSetForNextWidget(gui, _layer(layer+1));
		GuiImage(gui, _nid(), x_base, y_base, gui_icon, 1, 1.75, 1.75, 0);
	end


	function __render_wand_sprite(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
		local wand_offset_x, wand_offset_y = get_wand_rotated_offset(0, 0, -45);
		GuiZSetForNextWidget(gui, _layer(layer+1));
		GuiImage(gui, _nid(), x_base + (wand_offset_x * 1.333) + 6, y_base + (wand_offset_y * 1.333) + 18, slot_data.value, 1, 1.333, 1.333, math.rad(-45));

		if slot_data.research~=nil and slot_data.research.b_wand_types then
			local new_icon = "data/ui_gfx/damage_indicators/explosion.png";
			local new_offset_x = 6;
			local new_offset_y = 0;
			GuiZSetForNextWidget(gui, _layer(layer+2));
			GuiImage(gui, _nid(), x_base + new_offset_x, y_base + new_offset_y, new_icon, 1, 2, 2, math.rad(30)); -- radians are annoying
			GuiTooltip(gui, "This wand provides a new design.", "");
		end
	end


	function __render_wand_type(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
		local wand_offset_x, wand_offset_y = get_wand_rotated_offset(0, 0, -45);
		GuiZSetForNextWidget(gui, _layer(layer+1));
		GuiImage(gui, _nid(), x_base + (wand_offset_x * 1.333) + 6, y_base + (wand_offset_y * 1.333) + 18, wand_type_to_sprite_file(slot_data.value), 1, 1.333, 1.333, math.rad(-45));

		if slot_data.research~=nil and slot_data.research.b_wand_types then
			local new_icon = "data/ui_gfx/damage_indicators/explosion.png";
			local new_offset_x = 6;
			local new_offset_y = 0;
			GuiZSetForNextWidget(gui, _layer(layer+2));
			GuiImage(gui, _nid(), x_base + new_offset_x, y_base + new_offset_y, new_icon, 1, 2, 2, math.rad(30)); -- radians are annoying
			GuiTooltip(gui, "This wand provides a new design.", "");
		end
	end

	function __render_wand_spells(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
		local grid_y_offset = 0;
		local grid_x_offset = 34;
		local grid_columns = 5;
		local _capacity = _data.wand["capacity"] or _data["capacity"];
		if _data.label~=nil and _data.label~="" then
			GuiZSetForNextWidget(gui, _layer(layer));
			GuiText(gui, x_base + margin, y_base, _data.label, small_text_scale);
			if _data.color_val~=nil then
				if type(_data.color_val)=="boolean" then
					GuiColorNextWidgetBool(gui, _data.color_val);
				elseif type(_data.color_val)=="table" then
					GuiColorNextWidgetEnum(gui, _data.color_val);
				end
			end
			_capacity=#_data.value;
			GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
			GuiZSetForNextWidget(gui, _layer(layer));
			GuiText(gui, x_base + panel_width - margin, y_base, tostring(_capacity), small_text_scale);
			grid_y_offset = 10;
			grid_x_offset = 6;
			grid_columns = 8;
		end
		for cap_idx = 1, _data.render_slots_override or _capacity do
			local grid_h = 12;
			local grid_x = (((cap_idx-1)%grid_columns) * grid_h);
			local grid_y = (math.floor((cap_idx-1)/grid_columns) * grid_h);
			GuiZSetForNextWidget(gui, _layer(layer));
			GuiImage(gui, _nid(), x_base + grid_x_offset + grid_x, y_base + grid_y_offset + grid_y, "data/ui_gfx/inventory/inventory_box.png", 1, 0.8, 0.8, 0);
			if _data.value[cap_idx] ~= nil then
				local curr_spell_id = _data.value[cap_idx];
				local s_hover = select(3, GuiGetPreviousWidgetInfo(gui));
				if s_hover then
					spell_tooltip_id = curr_spell_id;
					-- if not spell_tooltip_open then
					-- 	show_spell_tooltip_gui();
					-- end
				end
				GuiZSetForNextWidget(gui, _layer(layer + 1));
				GuiImage(gui, _nid(), x_base + grid_x_offset + grid_x, y_base + grid_y_offset + grid_y, actions_by_id[curr_spell_id].sprite, 1, 0.8, 0.8, 0);
			end
		end
	end

	function __render_gen_stat(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiText(gui, x_base + margin, y_base, _data.label, small_text_scale);
		if _data.color_val~=nil then
			if type(_data.color_val)=="boolean" then
				GuiColorNextWidgetBool(gui, _data.color_val);
			elseif type(_data.color_val)=="table" then
				GuiColorNextWidgetEnum(gui, _data.color_val);
			end
		end
		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiText(gui, x_base + panel_width - margin, y_base, _data.value, small_text_scale);
	end

	function __render_inv_spell_single(x_base, y_base, margin, panel_width, panel_height, layer, _data, _nid)
		local _offset_x = x_base + 45;
		local _after_icon_x = _offset_x + 20;
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiImage(gui, _nid(), _offset_x-4, y_base -3, _data.type_sprite, 1, 1.2, 1.2); -- background type slot

		GuiZSetForNextWidget(gui, _layer(layer+1));
		GuiImage(gui, _nid(), _offset_x, y_base + 1, _data.sprite, (_data.recyclable~=nil and _data.recyclable==true) and 0.5 or 1, 1, 1, 0); -- Icon
		-- local s_hover, x_loc, y_loc = select(3, GuiGetPreviousWidgetInfo(gui));
		-- if s_hover then
		-- 	spell_tooltip_id = curr_spell.id;
		-- 	if not spell_tooltip_open then
		-- 		show_spell_tooltip_gui(120, 285);
		-- 	end
		-- end
		if _data.recyclable~=nil and _data.recyclable==true then
			GuiColorNextWidgetEnum(gui, COLORS.Dim);
		elseif _data.name_color~=nil then
			GuiColorNextWidgetEnum(gui, _data.name_color);
		end
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiText(gui, _after_icon_x, y_base + 0, GameTextGetTranslatedOrNot(_data.name)); -- Name
		if _data.max_uses ~= nil then
			local _x_text_width = select(6, GuiGetPreviousWidgetInfo(gui))
			GuiColorNextWidgetEnum(gui, COLORS.Tip);
			GuiZSetForNextWidget(gui, _layer(layer));
			GuiText(gui, _after_icon_x + _x_text_width + 3, y_base + 0, "(" .. _data.max_uses .. ")"); -- uses
		end

		if _data.recyclable~=nil and _data.recyclable==true then
			GuiColorNextWidgetEnum(gui, COLORS.Dark);
		elseif _data.description_color~=nil then
			GuiColorNextWidgetEnum(gui, _data.description_color);
		else
			GuiColorNextWidgetEnum(gui, COLORS.Tip);
		end
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiText(gui, _after_icon_x, y_base + 10, GameTextGetTranslatedOrNot(_data.description)); -- Description
	end



	function __widget_toggle(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiColorNextWidgetEnum(gui, COLORS.White);
		GuiText(gui, x_base + margin, y_base, slot_data.label, small_text_scale);

		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
		GuiZSetForNextWidget(gui, _layer(layer));
		local _ret = nil;
		GuiColorNextWidgetEnum(gui, COLORS.Yellow);
		if GuiButton(gui, _nid(), x_base + (panel_width / 2), y_base, " [ " .. GameTextGetTranslatedOrNot(slot_data.value) .. " ] ", small_text_scale) then
			_ret = not slot_data.wand[slot_data.member];
		else
			_ret = slot_data.wand[slot_data.member];
		end

		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiColorNextWidgetEnum(gui, COLORS.Tip);
		GuiText(gui, x_base + panel_width, y_base, string.format(" $ %1.0f", slot_data.cost[slot_data.member]), small_text_scale);
		return _ret;
	end

	function __widget_slider(x_base, y_base, margin, panel_width, panel_height, layer, slot_data, _nid)
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiColorNextWidgetEnum(gui, COLORS.White);
		GuiText(gui, x_base + margin, y_base, slot_data.label, small_text_scale);

		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiColorNextWidgetEnum(gui, COLORS.Yellow);
		GuiText(gui, x_base + (panel_width / 2), y_base, slot_data.value, small_text_scale);

		GuiZSetForNextWidget(gui, _layer(layer));
		local _ret = GuiSlider(gui, _nid(), x_base + margin, y_base + 10, "", slot_data.wand[slot_data.member], slot_data.bounds[slot_data.member][1], slot_data.bounds[slot_data.member][2], 0, 1, " ", panel_width );

		GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_Left);
		GuiColorNextWidgetEnum(gui, COLORS.Tip);
		GuiZSetForNextWidget(gui, _layer(layer));
		GuiText(gui, x_base + panel_width, y_base, string.format(" $ %1.0f", slot_data.cost[slot_data.member]), small_text_scale);
		return math.floor(_ret);
	end
