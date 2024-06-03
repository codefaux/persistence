dofile_once("mods/persistence/config.lua");
dofile_once("mods/persistence/files/data_store.lua");
dofile_once("mods/persistence/files/helper.lua");
dofile_once("data/scripts/gun/procedural/wands.lua");
dofile_once("mods/persistence/files/wand_spell_helper.lua");
dofile_once("data/scripts/gun/gun_actions.lua")

local gui = GuiCreate();
local active_windows = {};

local gui_margin_x = 8;
local gui_margin_y = 1;


-- SAVE SELECTOR

function show_save_selector_gui()
	local delete_save_confirmation = 0;
	active_windows["save_selector"] = { true, function (get_next_id)
		GuiLayoutBeginVertical(gui, 1, 20);
		for i = 1, get_save_count() do
			GuiText(gui, 0, 0, "Save slot " .. pad_number(i, #tostring(get_save_count())) .. ":");
			if get_save_ids()[i] == nil then
				if GuiButton(gui, 20, 0, "Create new save", get_next_id()) then
					set_selected_save_id(i);
					create_new_save(i);
					hide_save_selector_gui();
					OnSaveAvailable(i);
					enable_controls();
				end
			else
				if GuiButton(gui, 20, 0, "Load save", get_next_id()) then
					set_selected_save_id(i);
					load(i);
					hide_save_selector_gui();
					OnSaveAvailable(i);
					enable_controls();
				end
				if delete_save_confirmation == i then
					if GuiButton(gui, 20, 0, "Press again to delete", get_next_id()) then
						delete_save_confirmation = 0;
						delete_save(i);
					end
				else
					if GuiButton(gui, 20, 0, "Delete save", get_next_id()) then
						delete_save_confirmation = i;
					end
				end
			end
		end
		if GuiButton(gui, 0, 20, "Play without this mod", get_next_id()) then
			set_selected_save_id(0);
			hide_save_selector_gui();
			enable_controls();
		end
		GuiLayoutEnd(gui);
	end };
end

function hide_save_selector_gui()
	active_windows["save_selector"] = nil;
end


-- MONEY

local money_open = false;
function show_money_gui()
	money_open = true;
	active_windows["money"] = { true, function(get_next_id)
		local save_id = get_selected_save_id();
		local safe_money = get_safe_money(save_id);
		local player_money = get_player_money();
		local money_amts = {1, 10, 100, 1000};

		GuiLayoutBeginVertical(gui, 80, 15, false, gui_margin_x, gui_margin_y);
		GuiLayoutBeginHorizontal(gui, 0, 0, false, 0, 0);
		GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);

		for _, money_amt in ipairs(money_amts) do
			if safe_money < money_amt then
				GuiColorSetForNextWidget(gui, 0.33, 0.33, 0.33, 1);
				GuiText(gui, 0, 0, "Take $ " .. money_amt);
			else
				if GuiButton(gui, 0, 0, "Take $ " .. money_amt, get_next_id()) then
					transfer_money_to_player(save_id, money_amt);
				end
			end
		end

		if GuiButton(gui, 0, 0, "Take ALL", get_next_id()) then
			transfer_money_to_player(save_id, safe_money);
		end

		GuiLayoutEnd(gui);

		GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);

		for _, money_amt in ipairs(money_amts) do
			if player_money < money_amt then
				GuiColorSetForNextWidget(gui, 0.33, 0.33, 0.33, 1);
				GuiText(gui, 0, 0, "Stash $ " .. money_amt);
			else
				if GuiButton(gui, 0, 0, "Stash $ " .. money_amt, get_next_id()) then
					transfer_money_to_safe(save_id, money_amt);
				end
			end
		end

		if GuiButton(gui, 0, 0, "Stash ALL", get_next_id()) then
			transfer_money_to_safe(save_id, player_money);
		end
		GuiLayoutEnd(gui);
		GuiLayoutEnd(gui);
		GuiLayoutEnd(gui);

		GuiLayoutBeginHorizontal(gui, 84, 33);
		GuiText(gui, 0, 0, "Stashed: $ " .. tostring(safe_money));
		GuiLayoutEnd(gui);
	end };
end

function hide_money_gui()
	money_open = false;
	active_windows["money"] = nil;
end


-- TELEPORT

function show_teleport_gui()
	local teleport_confirmation = false;
	active_windows["teleport"] = { false, function(get_next_id)
		GuiLayoutBeginHorizontal(gui, 45, 1);
		if teleport_confirmation then
			if GuiButton(gui, 0, 0, "Press again to teleport to Lobby", get_next_id()) then
				teleport_back_to_lobby();
			end
		else
			if GuiButton(gui, 0, 0, "Teleport to Lobby", get_next_id()) then
				teleport_confirmation = true;
			end
		end
		GuiLayoutEnd(gui);
	end };
end

function hide_teleport_gui()
	active_windows["teleport"] = nil;
end


-- RESEARCH WANDS

local research_wands_open = false;
function show_research_wands_gui()
	local save_id = get_selected_save_id();
	if not data_store_safe(save_id) then
		return;
	end

	research_wands_open = true;
	local wand_entity_ids = get_all_wands();

	active_windows["research_wands"] = { true, function(get_next_id)
		local player_money = get_player_money();
		GuiLayoutBeginVertical(gui, 30, 30, false, gui_margin_x, gui_margin_y);
		for i = 0, 3 do
			GuiLayoutBeginHorizontal(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			GuiText(gui, 0, 0, "Wand Slot " .. tostring(i+1) .. ":");
				if wand_entity_ids[i] ~= nil then
					local price = research_wand_price(get_selected_save_id(), wand_entity_ids[i]);
					local is_new = research_wand_is_new(get_selected_save_id(), wand_entity_ids[i]);
					if is_new then
						if price > player_money then
							GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
							GuiText(gui, 0, 0, " $" .. tostring(price));
							GuiText(gui, 0, 0, "(Too expensive)");
						else
							local spell_count = #read_wand(wand_entity_ids[i])["spells"];
							if spell_count > 0 then
								GuiColorSetForNextWidget(gui, 1, 1, 0.5, 1);
							else
								GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
							end
							if GuiButton(gui, 0, 0, " $" .. tostring(price), get_next_id()) then
								research_wand(get_selected_save_id(), wand_entity_ids[i]);
								wand_entity_ids[i] = nil; -- Verify this works
							end
							if spell_count > 0 then
								GuiText(gui, 0, 0, "(WARNING: Spells on this wand will be lost)");
							else
								GuiText(gui, 0, 0, " ");
							end
						end
					else
						GuiColorSetForNextWidget(gui, 1, 0.75, 0.75, 0.75);
						GuiText(gui, 0, 0, " $0");
					end
				else
					GuiColorSetForNextWidget(gui, 1, 0.75, 0.75, 0.75);
					GuiText(gui, 0, 0, " x ");
				end
			GuiLayoutEnd(gui);
		end
		GuiLayoutEnd(gui);
	end };
end

function hide_research_wands_gui()
	research_wands_open = false;
	active_windows["research_wands"] = nil;
end


-- RESEARCH SPELLS

local research_spells_open = false;
function show_research_spells_gui()
	local save_id = get_selected_save_id();
	if not data_store_safe(save_id) or not spells_safe(save_id) then
		return;
	end

	research_spells_open = true;
	local inv_spell_entity_ids = get_all_inv_spells();
	local researched_spells = get_spells(get_selected_save_id());
	local inv_spell_data_temp = {};
	local spell_data = {};

	for i, spell_entity_id in ipairs(inv_spell_entity_ids) do
		local action_id = get_spell_entity_action_id(spell_entity_id);
		if action_id ~= nil then
			if researched_spells == nil or researched_spells[action_id] == nil then
				table.insert(spell_data, {
					["entity_id"] = spell_entity_id,
					["id"] = action_id,
					["name"] = GameTextGetTranslatedOrNot(actions_by_id[action_id].name),
					["price"] = research_spell_entity_price(spell_entity_id)
				});
				-- inv_spell_data_temp[action_id] = inv_spell_entity_ids[i];
			end
		end
	end

	-- for i = 1, #actions do -- build spell_data table w/ entity_id, id, name, price for get_all_inv_spells()
	-- 	local entity_id = inv_spell_data_temp[actions[i].id];
	-- 	if entity_id ~= nil then
	-- 		table.insert(spell_data, {
	-- 			["entity_id"] = entity_id,
	-- 			["id"] = actions[i].id,
	-- 			["name"] = GameTextGetTranslatedOrNot(actions[i].name),
	-- 			["price"] = research_spell_price(entity_id)
	-- 		});
	-- 	end
	-- end



	table.sort(spell_data, function(a, b) return a.name < b.name end);

	active_windows["research_spells"] = { true, function(get_next_id)
		if #spell_data > 0 then
			local player_money = get_player_money();
			GuiLayoutBeginHorizontal(gui, 30, 10);
			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(spell_data) do
				if player_money < value.price then
					GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
					GuiText(gui, 0, 0, " $ " .. tostring(value.price));
				else
					GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
					if GuiButton(gui, 0, 0, " $ " .. tostring(value.price), get_next_id()) then
						research_spell_entity(get_selected_save_id(), value.entity_id);
						hide_research_spells_gui();
						show_research_spells_gui();
					end
				end
			end
			GuiLayoutEnd(gui);
			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(spell_data) do
				GuiText(gui, 0, 0, value.name);
			end
			GuiLayoutEnd(gui);
			GuiLayoutEnd(gui);
		else
			GuiLayoutBeginHorizontal(gui, 40, 30);
			GuiText(gui, 0, 0, "No new spells to research");
			GuiLayoutEnd(gui);
		end
	end };
end

function hide_research_spells_gui()
	research_spells_open = false;
	active_windows["research_spells"] = nil;
end


-- BUY WANDS

local buy_wands_open = false;
function show_buy_wands_gui()
	local save_id = get_selected_save_id();
	if not data_store_safe(save_id) or not wand_types_safe(save_id) or not always_cast_safe(save_id) or not templates_safe(save_id) then
		return;
	end

	buy_wands_open = true;

	if can_create_wand(save_id) then
		local WINDOW_ID = { id_base=0, id_pick_alwayscast=1, id_pick_icon=2};
		local window_nr = WINDOW_ID.id_base;
		local gui_margin_y = 2; -- Override
		local gui_margin_short_x = 5;
		local spells_per_cast_min = 1;
		local spells_per_cast_max = get_spells_per_cast(save_id);
		local cast_delay_min = get_cast_delay_min(save_id);
		local cast_delay_max = get_cast_delay_max(save_id);
		local recharge_time_min = get_recharge_time_min(save_id);
		local recharge_time_max = get_recharge_time_max(save_id);
		local mana_min = 1;
		local mana_max = get_mana_max(save_id);
		local mana_charge_speed_min = 1;
		local mana_charge_speed_max = get_mana_charge_speed(save_id);
		local capacity_min = 1;
		local capacity_max = get_capacity(save_id);
		local spread_min = get_spread_min(save_id);
		local spread_max = get_spread_max(save_id);
		local wand_types = get_wand_types(save_id);
		local always_cast_spells = get_always_cast_spells(save_id);
		local wand_data_selected = {
			["shuffle"] = true,
			["spells_per_cast"] = math.floor((spells_per_cast_min + spells_per_cast_max)/2),
			["cast_delay"] = math.floor((cast_delay_min + cast_delay_max)/2),
			["recharge_time"] = math.floor((recharge_time_min + recharge_time_max)/2),
			["mana_max"] = math.floor((mana_min + mana_max)/2),
			["mana_charge_speed"] = math.floor((mana_charge_speed_min + mana_charge_speed_max)/2),
			["capacity"] = math.floor((capacity_min + capacity_max) / 2),
			["spread"] = math.floor((spread_min + spread_max) / 2),
			["always_cast_spells"] = {},
			["wand_type"] = "default_1";
		};
		local delete_template_confirmation = 0;

		local spells_page_number = 1;
		local spell_data = {};

		local wand_stat_names = {"spells_per_cast", "cast_delay",  "recharge_time",        "mana_max",  "mana_charge_speed",  "capacity",     "spread" };
		local wand_stat_scales = {      {1, 5, 10},   {1, 6, 60},      {1, 6, 60},       {1, 10, 100},         {1, 10, 100},  {1, 5, 10},  {.1, 1, 10},  };
		local wand_stat_limits = {};
		wand_stat_limits.min = {spells_per_cast_min, cast_delay_min, recharge_time_min, mana_min, mana_charge_speed_min, capacity_min, spread_min };
		wand_stat_limits.max = {spells_per_cast_max, cast_delay_max, recharge_time_max, mana_max, mana_charge_speed_max, capacity_max, spread_max };

		for _, always_cast_id in ipairs(always_cast_spells) do -- -- load spell_data with id, name, selected from always_cast_spells[] by action_id
			table.insert(spell_data, {
				["id"] = always_cast_id,
				["name"] = GameTextGetTranslatedOrNot(actions_by_id[always_cast_id].name),
				["selected"] = false
			});
		end
		-- for i = 1, #actions do -- -- load spell_data with id, name, selected from always_cast_spells[] by action_id
		-- 	if always_cast_spells ~= nil and always_cast_spells[actions[i].id] ~= nil then
		-- 		table.insert(spell_data, {
		-- 			["id"] = actions[i].id,
		-- 			["name"] = GameTextGetTranslatedOrNot(actions[i].name),
		-- 			["selected"] = false
		-- 		});
		-- 	end
		-- end

		local function toggle_select_spell(action_id)
			local selected = false;
			for i = 1, #spell_data do
				if spell_data[i].id == action_id then
					selected = not spell_data[i].selected;
					spell_data[i].selected = selected;
					break;
				end
			end
			for i = 1, #wand_data_selected["always_cast_spells"] do
				if wand_data_selected["always_cast_spells"][i] == action_id then
					table.remove(wand_data_selected["always_cast_spells"], i);
					break;
				end
			end
			if selected then
				table.insert(wand_data_selected["always_cast_spells"], action_id);
			end
		end

		table.sort(spell_data, function(a, b) return a.name < b.name end);
		local spell_columns = split_array(spell_data, 20);

		local wand_types_page_number = 1;
		local wand_type_list = {};

		for wand_type, _ in pairs(wand_types) do
			table.insert(wand_type_list, {
				["wand_type"] = wand_type,
				["sprite_file"] = wand_type_to_sprite_file(wand_type)
			});
		end

		table.sort(wand_type_list, function(a, b) return a.wand_type < b.wand_type end);
		local wand_type_columns = split_array(wand_type_list, 5);

		active_windows["buy_wands"] = { true, function(get_next_id)
			local player_money = get_player_money();
			local price = create_wand_price(wand_data_selected);
			if window_nr == WINDOW_ID.id_base then
				GuiLayoutBeginLayer(gui);
				GuiLayoutBeginHorizontal(gui, 43, 17);
				GuiImage(gui, get_next_id(), 0, 0, wand_type_to_sprite_file(wand_data_selected["wand_type"]), 1, 1, 1, math.rad(-45)); -- radians are annoying
				GuiLayoutEnd(gui);
				GuiLayoutEndLayer(gui);

				GuiLayoutBeginHorizontal(gui, 25, 20);
				GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
				GuiText(gui, 0, 0, "Wand design");
				GuiText(gui, 0, 0, "$inventory_shuffle");
				GuiText(gui, 0, 0, "$inventory_actionspercast");
				GuiText(gui, 0, 0, "$inventory_castdelay");
				GuiText(gui, 0, 0, "$inventory_rechargetime");
				GuiText(gui, 0, 0, "$inventory_manamax");
				GuiText(gui, 0, 0, "$inventory_manachargespeed");
				GuiText(gui, 0, 0, "$inventory_capacity");
				GuiText(gui, 0, 0, "$inventory_spread");
				GuiText(gui, 0, 0, "$inventory_alwayscasts");
				GuiLayoutEnd(gui);

				for scale=3, 1, -1 do
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_short_x, gui_margin_y);
					GuiText(gui, 0, 0, " "); -- filler for select

					if (scale == 1 and wand_data_selected["shuffle"] == true) then
						if GuiButton(gui, 0, 0, "<", get_next_id()) then
							wand_data_selected["shuffle"] = false;
						end
						-- GuiTooltip(gui, "$menu_no",);
					else
						GuiButton(gui, 0, 0, " ", get_next_id());
					end

					for arr_idx, wand_stat_name in ipairs(wand_stat_names) do
						local stat_data = wand_data_selected[wand_stat_name];
						local stat_step = wand_stat_scales[arr_idx][scale];
						local lower_scale = scale-1>=1 and scale-1 or 1;
						local stat_smstep = wand_stat_scales[arr_idx][lower_scale];
						local stat_min = wand_stat_limits.min[arr_idx];


						if stat_data - stat_smstep >= stat_min  then
							if stat_data - stat_step <= stat_min then
								if GuiButton(gui, 0, 0, "|" .. string.rep("<", scale-1), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_min;
								end
							else
								if GuiButton(gui, 0, 0, string.rep("<", scale), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_data - stat_step;
								end
							end
							-- GuiTooltip(gui, "-" .. stat_lgstep, "");
						else
							GuiButton(gui, 0, 0, " ", get_next_id());
						end
					end -- ipairs(wand_stat_names)
					GuiLayoutEnd(gui);
				end -- scale

				GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
				if GuiButton(gui, 0, 0, "Select", get_next_id()) then
					window_nr = WINDOW_ID.id_pick_icon;
				end
				GuiText(gui, 0, 0, wand_data_selected["shuffle"] and "$menu_yes" or "$menu_no");
				GuiText(gui, 0, 0, tostring(wand_data_selected["spells_per_cast"]));
				GuiText(gui, 0, 0, tostring(math.floor((wand_data_selected["cast_delay"] / 60) * 100 + 0.5) / 100));
				GuiText(gui, 0, 0, tostring(math.floor((wand_data_selected["recharge_time"] / 60) * 100 + 0.5) / 100));
				GuiText(gui, 0, 0, tostring(wand_data_selected["mana_max"]));
				GuiText(gui, 0, 0, tostring(wand_data_selected["mana_charge_speed"]));
				GuiText(gui, 0, 0, tostring(wand_data_selected["capacity"]));
				GuiText(gui, 0, 0, tostring(math.floor(wand_data_selected["spread"] * 10 + 0.5) / 10));
				if GuiButton(gui, 0, 0, "Select", get_next_id()) then
					window_nr = WINDOW_ID.id_pick_alwayscast;
				end
				GuiLayoutEnd(gui);


				for scale=1, 3, 1 do
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_short_x, gui_margin_y);
					GuiText(gui, 0, 0, " "); -- filler for img select

					if (scale == 1 and wand_data_selected["shuffle"] == false) then
						if GuiButton(gui, 0, 0, ">", get_next_id()) then
							wand_data_selected["shuffle"] = true;
						end
						-- GuiTooltip(gui, "$menu_yes",);
					else
						GuiButton(gui, 0, 0, " ", get_next_id());
					end

					for arr_idx, wand_stat_name in ipairs(wand_stat_names) do
						local stat_data = wand_data_selected[wand_stat_name];
						local stat_step = wand_stat_scales[arr_idx][scale];
						local lower_scale = scale-1>0 and scale-1 or 1;
						local stat_smstep = wand_stat_scales[arr_idx][lower_scale];
						local stat_max = wand_stat_limits.max[arr_idx];

						if stat_data + stat_smstep <= stat_max then
						 if stat_data + stat_step >= stat_max  then
							if GuiButton(gui, 0, 0, string.rep(">", scale-1) .. "|", get_next_id()) then
								wand_data_selected[wand_stat_name] = stat_max;
							end
						else
								if GuiButton(gui, 0, 0, string.rep(">", scale), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_data + stat_step;
								end
							end
							-- GuiTooltip(gui, "+" .. stat_step, "");
						else
							GuiButton(gui, 0, 0, " ", get_next_id());
						end
					end
					GuiLayoutEnd(gui);
				end
				GuiLayoutEnd(gui);

				GuiLayoutBeginHorizontal(gui, 31, 60, false, gui_margin_x, gui_margin_y);
				GuiText(gui, 0, 0, "Purchase Price:");
				if player_money < price then
					GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
					GuiText(gui, 0, 0, " $ " .. tostring(price));
				else
					GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
					if GuiButton(gui, 0, 0, " $ " .. tostring(price), get_next_id()) then
						create_wand(wand_data_selected);
					end
				end
				GuiLayoutEnd(gui);

				for i = 1, get_template_count() do
					local template_preview = get_template(save_id, i);
					local template_hover = 0;
					GuiLayoutBeginVertical(gui, 80, 44 + ((i-1) * 11));
					GuiText(gui, 0, 0, "Template Slot " .. pad_number(i, #tostring(get_template_count())) .. ":");
					if template_preview == nil then	-- Template empty
						if GuiButton(gui, 16, 6, "Save template", get_next_id()) then
							set_template(save_id, i, wand_data_selected);
						end
					else -- Template exists
						if select(3, GuiGetPreviousWidgetInfo(gui)) then
							template_hover = i;
						end
						GuiLayoutBeginHorizontal(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						GuiImage(gui, get_next_id(), 0, 15, wand_type_to_sprite_file(template_preview["wand_type"]), 1, 1, 1, math.rad(-45)); -- radians are annoying
						if select(3, GuiGetPreviousWidgetInfo(gui)) then
							template_hover = i;
						end

						GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						if GuiButton(gui, 0, 0, "Load template", get_next_id()) then
							wand_data_selected = template_preview;
						end
						if select(3, GuiGetPreviousWidgetInfo(gui)) then
							template_hover = i;
						end
						if delete_template_confirmation == i then
							if GuiButton(gui, 0, 0, "Press again to delete", get_next_id()) then
								delete_template_confirmation = 0;
								delete_template(save_id, i);
							end
						else
							if GuiButton(gui, 0, 0, "Delete template", get_next_id()) then
								delete_template_confirmation = i;
							end
						end
						-- if select(3, GuiGetPreviousWidgetInfo(gui)) then
						-- 	template_hover = i;
						-- end
					  template_hover = select(3, GuiGetPreviousWidgetInfo(gui));
						GuiLayoutEnd(gui);
						GuiLayoutEnd(gui);
					end
					GuiLayoutEnd(gui);

					if template_hover == true then
						-- GuiBeginAutoBox(gui);
						-- GuiLayoutBeginLayer(gui);
						GuiLayoutBeginHorizontal(gui, 60, 60, false, gui_margin_x, gui_margin_y);
						GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						GuiText(gui, 0, 0, "$inventory_shuffle");
						GuiText(gui, 0, 0, "$inventory_actionspercast");
						GuiText(gui, 0, 0, "$inventory_castdelay");
						GuiText(gui, 0, 0, "$inventory_rechargetime");
						GuiText(gui, 0, 0, "$inventory_manamax");
						GuiText(gui, 0, 0, "$inventory_manachargespeed");
						GuiText(gui, 0, 0, "$inventory_capacity");
						GuiText(gui, 0, 0, "$inventory_spread");
						GuiText(gui, 0, 0, "$inventory_alwayscasts");
						GuiLayoutEnd(gui);
						GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						GuiText(gui, 0, 0, template_preview["shuffle"] and "$menu_yes" or "$menu_no");
						GuiText(gui, 0, 0, template_preview["spells_per_cast"] );
						GuiText(gui, 0, 0, tostring(math.floor((template_preview["cast_delay"] / 60) * 100 + 0.5) / 100) );
						GuiText(gui, 0, 0, tostring(math.floor((template_preview["recharge_time"] / 60) * 100 + 0.5) / 100) );
						GuiText(gui, 0, 0, tostring(template_preview["mana_max"]) );
						GuiText(gui, 0, 0, tostring(template_preview["mana_charge_speed"]) );
						GuiText(gui, 0, 0, tostring(template_preview["capacity"]) );
						GuiText(gui, 0, 0, tostring(math.floor(template_preview["spread"] * 10 + 0.5) / 10) );
						GuiText(gui, 0, 0, tostring(#template_preview["always_cast_spells"]) .. " spells" );
						GuiLayoutEnd(gui);
						GuiLayoutEnd(gui);
						-- GuiLayoutEndLayer(gui);
						-- GuiEndAutoBoxNinePiece(gui);
					end
				end
			elseif window_nr == WINDOW_ID.id_pick_alwayscast then
				if spell_columns[spells_page_number * 2 - 1] ~= nil then
					GuiLayoutBeginHorizontal(gui, 30, 15);
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					for _, value in ipairs(spell_columns[spells_page_number * 2 - 1]) do
						if GuiButton(gui, 0, 0, "[" .. (value.selected and "x" or " ") .. "]", get_next_id()) then
							toggle_select_spell(value.id);
						end
					end
					GuiLayoutEnd(gui);
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					for _, value in ipairs(spell_columns[spells_page_number * 2 - 1]) do
						GuiText(gui, 0, 0, value.name);
					end
					GuiLayoutEnd(gui);
					GuiLayoutEnd(gui);
				end
				if spell_columns[spells_page_number * 2] ~= nil then
					GuiLayoutBeginHorizontal(gui, 60, 15);
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					for _, value in ipairs(spell_columns[spells_page_number * 2]) do
						if GuiButton(gui, 0, 0, "[" .. (value.selected and "x" or " ") .. "]", get_next_id()) then
							toggle_select_spell(value.id);
						end
					end
					GuiLayoutEnd(gui);
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
					for _, value in ipairs(spell_columns[spells_page_number * 2]) do
						GuiText(gui, 0, 0, value.name);
					end
					GuiLayoutEnd(gui);
					GuiLayoutEnd(gui);
				end
				if spells_page_number > 1 then
					GuiLayoutBeginHorizontal(gui, 48, 95);
					if GuiButton(gui, 0, 0, "<<", get_next_id()) then
						spells_page_number = spells_page_number - 1;
					end
					GuiLayoutEnd(gui);
				end
				GuiLayoutBeginHorizontal(gui, 50, 95);
				GuiText(gui, 0, 0, tostring(spells_page_number));
				GuiLayoutEnd(gui);
				if spells_page_number < math.ceil(#spell_columns / 2) then
					GuiLayoutBeginHorizontal(gui, 52, 95);
					if GuiButton(gui, 0, 0, ">>", get_next_id()) then
						spells_page_number = spells_page_number + 1;
					end
					GuiLayoutEnd(gui);
				end
			elseif window_nr == WINDOW_ID.id_pick_icon then
				if wand_type_columns[wand_types_page_number * 2 - 1] ~= nil then
					for i, value in ipairs(wand_type_columns[wand_types_page_number * 2 - 1]) do
						GuiLayoutBeginVertical(gui, 25, 6 + i * 14);
						GuiImage(gui, get_next_id(), 3, 0, value.sprite_file, 1, 1, 1, math.rad(-45)); -- radians are annoying
						if GuiButton(gui, 0, 0, "Select", get_next_id()) then
							wand_data_selected["wand_type"] = value.wand_type;
							window_nr = WINDOW_ID.id_base;
							wand_types_page_number = 1;
						end
						GuiLayoutEnd(gui);
					end
				end
				if wand_type_columns[wand_types_page_number * 2] ~= nil then
					for i, value in ipairs(wand_type_columns[wand_types_page_number * 2]) do
						GuiLayoutBeginVertical(gui, 60, 6 + i * 14);
						GuiImage(gui, get_next_id(), 3, 0, value.sprite_file, 1, 1, 1, math.rad(-45)); -- radians are annoying
						if GuiButton(gui, 0, 0, "Select", get_next_id()) then
							wand_data_selected["wand_type"] = value.wand_type;
							window_nr = WINDOW_ID.id_base;
							wand_types_page_number = 1;
						end
						GuiLayoutEnd(gui);
					end
				end
				if wand_types_page_number > 1 then
					GuiLayoutBeginHorizontal(gui, 41, 95);
					if GuiButton(gui, 0, 0, "<<", get_next_id()) then
						wand_types_page_number = wand_types_page_number - 1;
					end
					GuiLayoutEnd(gui);
				end
				GuiLayoutBeginHorizontal(gui, 45, 95);
				GuiText(gui, 0, 0, tostring(wand_types_page_number));
				GuiLayoutEnd(gui);
				if wand_types_page_number < math.ceil(#wand_type_columns / 2) then
					GuiLayoutBeginHorizontal(gui, 47, 95);
					if GuiButton(gui, 0, 0, ">>", get_next_id()) then
						wand_types_page_number = wand_types_page_number + 1;
					end
					GuiLayoutEnd(gui);
				end
			end
			if window_nr ~= WINDOW_ID.id_base then
				GuiLayoutBeginHorizontal(gui, 43, 91);
				if GuiButton(gui, 0, 0, "$menu_return", get_next_id()) then
					window_nr = WINDOW_ID.id_base;
					spells_page_number = 1;
					wand_types_page_number = 1;
				end
				GuiLayoutEnd(gui);
			end
		end };
	else
		active_windows["buy_wands"] = { true, function(get_next_id)
			GuiLayoutBeginHorizontal(gui, 40, 30);
			GuiText(gui, 0, 0, "You don't have enough research to create a wand");
			GuiLayoutEnd(gui);
		end };
	end
end

function hide_buy_wands_gui()
	buy_wands_open = false;
	active_windows["buy_wands"] = nil;
end


-- BUY SPELLS

local buy_spells_open = false;
function show_buy_spells_gui()
	local save_id = get_selected_save_id();
	if not data_store_safe(save_id) and not spells_safe(save_id) then
		return;
	end

	buy_spells_open = true;
	local page_number = 1;
	local spells = get_spells(save_id);
	local spell_data = {};

	for spell_id, _ in pairs(spells) do
		table.insert(spell_data, {
			["id"] = spell_id,
			["name"] = GameTextGetTranslatedOrNot(actions_by_id[spell_id].name),
			["price"] = create_spell_price(spell_id)
		});
	end
	-- for i = 1, #actions do
	-- 	if spells ~= nil and spells[actions[i].id] ~= nil then
	-- 		table.insert(spell_data, {
	-- 			["id"] = actions[i].id,
	-- 			["name"] = GameTextGetTranslatedOrNot(actions[i].name),
	-- 			["price"] = create_spell_price(actions[i].id)
	-- 		});
	-- 	end
	-- end

	table.sort(spell_data, function(a, b) return a.name < b.name end);
	local columns = split_array(spell_data, 20);

	active_windows["buy_spells"] = { true, function(get_next_id)
		local player_money = get_player_money();
		if columns[page_number * 2 - 1] ~= nil then
			GuiLayoutBeginHorizontal(gui, 20, 15, false, gui_margin_x, gui_margin_y);
			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(columns[page_number * 2 - 1]) do
				if player_money < value.price then
					GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
					GuiText(gui, 0, 0, " $ " .. tostring(value.price));
				else
					GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
					if GuiButton(gui, 0, 0, " $ " .. tostring(value.price), get_next_id()) then
						create_spell(value.id);
					end
				end
			end
			GuiLayoutEnd(gui);

			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(columns[page_number * 2 - 1]) do
				GuiText(gui, 0, 0, value.name);
			end
			GuiLayoutEnd(gui);
			GuiLayoutEnd(gui);
		end
		if columns[page_number * 2] ~= nil then
			GuiLayoutBeginHorizontal(gui, 50, 15, false, gui_margin_x, gui_margin_y);
			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(columns[page_number * 2]) do
				if player_money < value.price then
					GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
					GuiText(gui, 0, 0, " $ " .. tostring(value.price));
				else
					GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
					if GuiButton(gui, 0, 0, " $ " .. tostring(value.price), get_next_id()) then
						create_spell(value.id);
					end
				end
			end
			GuiLayoutEnd(gui);

			GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
			for _, value in ipairs(columns[page_number * 2]) do
				GuiText(gui, 0, 0, value.name);
			end
			GuiLayoutEnd(gui);
			GuiLayoutEnd(gui);
		end
		if page_number > 1 then
			GuiLayoutBeginHorizontal(gui, 48, 95);
			if GuiButton(gui, 0, 0, "<<", get_next_id()) then
				page_number = page_number - 1;
			end
			GuiLayoutEnd(gui);
		end
		GuiLayoutBeginHorizontal(gui, 50, 95);
		GuiText(gui, 0, 0, tostring(page_number));
		GuiLayoutEnd(gui);
		if page_number < math.ceil(#columns / 2) then
			GuiLayoutBeginHorizontal(gui, 52, 95);
			if GuiButton(gui, 0, 0, ">>", get_next_id()) then
				page_number = page_number + 1;
			end
			GuiLayoutEnd(gui);
		end
	end };
end

function hide_buy_spells_gui()
	buy_spells_open = false;
	active_windows["buy_spells"] = nil;
end


-- LOBBY MENU

local menu_open = false;
function show_lobby_gui()
	menu_open = true;

	local is_enabled = true;
	hide_money_gui();
	hide_research_wands_gui();
	hide_research_spells_gui();
	hide_buy_wands_gui();
	hide_buy_spells_gui();
	active_windows["menu"] = { false, function(get_next_id)
		local any_open = money_open or research_wands_open or research_spells_open or buy_wands_open or buy_spells_open;
		if any_open then
			GuiLayoutBeginHorizontal(gui, 84, 11);
			GuiText(gui, 0, 0, "Player: $ " .. tostring(get_player_money()));
			GuiLayoutEnd(gui);
		end

		GuiLayoutBeginVertical(gui, 2, 77);
		if any_open then
			GuiColorSetForNextWidget(gui, 1, 1, 0.5, 1);
			if GuiButton(gui, 10, 0, "Close All", get_next_id()) then
				hide_money_gui();
				hide_research_wands_gui();
				hide_research_spells_gui();
				hide_buy_wands_gui();
				hide_buy_spells_gui();
			end
		else
			GuiText(gui, 0, 0, " ");
		end
		GuiText(gui, 0, 0, " ");
		if GuiButton(gui, money_open and 10 or 0, 0, "Money", get_next_id()) then
			if money_open then
				hide_money_gui();
			else
				show_money_gui();
			end
		end
		if GuiButton(gui, research_wands_open and 10 or 0, 0, "Research Wands", get_next_id()) then
			hide_research_spells_gui();
			hide_buy_wands_gui();
			hide_buy_spells_gui();
			if research_wands_open then
				hide_research_wands_gui();
			else
				show_research_wands_gui();
			end
		end
		if GuiButton(gui, research_spells_open and 10 or 0, 0, "Research Spells", get_next_id()) then
			hide_research_wands_gui();
			hide_buy_wands_gui();
			hide_buy_spells_gui();
			if research_spells_open then
				hide_research_spells_gui();
			else
				show_research_spells_gui();
			end
		end
		if GuiButton(gui, buy_wands_open and 10 or 0, 0, "Buy Wands", get_next_id()) then
			hide_research_wands_gui();
			hide_research_spells_gui();
			hide_buy_spells_gui();
			if buy_wands_open then
				hide_buy_wands_gui();
			else
				show_buy_wands_gui();
			end
		end
		if GuiButton(gui, buy_spells_open and 10 or 0, 0, "Buy Spells", get_next_id()) then
			hide_research_wands_gui();
			hide_research_spells_gui();
			hide_buy_wands_gui();
			if buy_spells_open then
				hide_buy_spells_gui();
			else
				show_buy_spells_gui();
			end
		end
		GuiLayoutEnd(gui);
	end };
end

function hide_lobby_gui()
	menu_open = false;
	hide_money_gui();
	hide_research_wands_gui();
	hide_research_spells_gui();
	hide_buy_wands_gui();
	hide_buy_spells_gui();
	active_windows["menu"] = nil;
end

function hide_all_gui()
	active_windows = {};
end

function gui_update()
	if money_open or research_wands_open or research_spells_open or buy_wands_open or buy_spells_open then
		  disable_controls();
	else
			enable_controls();
	end

	if gui ~= nil and active_windows ~= nil then
		local is_dark_background = false;
		GuiStartFrame(gui);
		for _, window in pairs(active_windows) do
			if window[1] then
				is_dark_background = true;
			end
		end
		local start_gui_id = 14796823;
		if is_dark_background then
			local cx, cy = GameGetCameraPos();
			GuiImage(gui, start_gui_id - 1, 0, 0, "mods/persistence/files/gui_darken.png", 1, 1, 1, 0);
		end
		for name, window in pairs(active_windows) do
			local gui_id = start_gui_id + simple_string_hash(name);
			window[2](function()
				gui_id = gui_id + 1;
				return gui_id;
			end);
		end
	end
end