dofile_once("mods/persistence/config.lua");
dofile_once("mods/persistence/files/data_store.lua");
dofile_once("mods/persistence/files/helper.lua");
dofile_once("data/scripts/gun/procedural/wands.lua");
dofile_once("mods/persistence/files/wand_spell_helper.lua");
dofile_once("data/scripts/gun/gun_actions.lua");
dofile_once("data/scripts/debug/keycodes.lua");

local gui = GuiCreate();
local active_windows = {};

local gui_margin_x = 8;
local gui_margin_y = 1;
local small_text_scale = 0.9;

---@enum colors
local COLORS = {
	Green = "GREEN",
	Red = "RED",
	Yellow = "YELLOW",
	Dim = "DIM",
	Dark = "DARK",
	Tip = "TIP",
	Bright = "BRIGHT"
}

---@param value colors
local function GuiColorNextWidgetEnum(gui, value)
  if value == "GREEN" then
		GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1);
	elseif value == "RED" then
		GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
	elseif value == "YELLOW" then
		GuiColorSetForNextWidget(gui, 1, 1, 0.5, 1);
	elseif value == "DIM" then
		GuiColorSetForNextWidget(gui, 0.75, 0.75, 0.75, 1);
	elseif value == "DARK" then
		GuiColorSetForNextWidget(gui, 0.333, 0.333, 0.333, 1);
	elseif value == "TIP" then
		GuiColorSetForNextWidget(gui, 0.666, 0.666, 0.80, 1);
	elseif value == "BRIGHT" then
		GuiColorSetForNextWidget(gui, 0.85, 0.9, 1, 1);
	end
end

local function GuiColorNextWidgetBool(gui, value)
	if value then
		GuiColorSetForNextWidget(gui, 0.5, 1, 0.5, 1)
	else
		GuiColorSetForNextWidget(gui, 1, 0.5, 0.5, 1);
	end
end


-- SAVE SELECTOR
local save_open = false;
function show_save_selector_gui()
	save_open = true;
	disable_controls();

	local delete_save_confirmation = 0;
	active_windows["save_selector"] = { true, function (get_next_id)
		GuiBeginScrollContainer(gui, get_next_id(), 30, 30, 250, 250);
		GuiLayoutBeginVertical(gui, 3, 3);
		GuiText(gui, 0, 0, "Select a save slot to proceed:");
		GuiColorNextWidgetEnum(gui, COLORS.Tip);
		GuiText(gui, 0, 0, "(Auto-load can be configured in the Mod Options menu)");
		for i = 1, get_save_count() do
			GuiText(gui, 0, 4, "Save slot " .. pad_number(i, #tostring(get_save_count())) .. ":");
			if get_save_ids()[i] == nil then
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				if GuiButton(gui, 20, 0, "- Create new save", get_next_id()) then
					set_selected_save_id(i);
					create_new_save(i);
					hide_save_selector_gui();
					OnSaveAvailable(i);
					enable_controls();
					save_open = false;
				end
			else
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				if GuiButton(gui, 20, 0, "- Load save", get_next_id()) then
					set_selected_save_id(i);
					load(i);
					hide_save_selector_gui();
					OnSaveAvailable(i);
					enable_controls();
					save_open = false;
				end
				if delete_save_confirmation == i then
					GuiColorNextWidgetEnum(gui, COLORS.Yellow);
					if GuiButton(gui, 20, 0, "- Press again to delete", get_next_id()) then
						delete_save_confirmation = 0;
						delete_save(i);
					end
				else
					GuiColorNextWidgetEnum(gui, COLORS.Yellow);
					if GuiButton(gui, 20, 0, "- Delete save", get_next_id()) then
						delete_save_confirmation = i;
					end
				end
			end
		end
		GuiText(gui, 0, 8, "Alternatively:");
		GuiColorNextWidgetEnum(gui, COLORS.Green);
		if GuiButton(gui, 20, 0, "- Play without this mod", get_next_id()) then
			set_selected_save_id(0);
			hide_save_selector_gui();
			enable_controls();
			save_open = false;
		end
		GuiLayoutEnd(gui);
		GuiEndScrollContainer(gui);
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
				GuiColorNextWidgetEnum(gui, COLORS.Dark)
				GuiText(gui, 0, 0, "Take $ " .. money_amt);
			else
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				if GuiButton(gui, 0, 0, "Take $ " .. money_amt, get_next_id()) then
					transfer_money_to_player(save_id, money_amt);
				end
			end
		end

		GuiColorNextWidgetEnum(gui, COLORS.Green);
		if GuiButton(gui, 0, 0, "Take ALL", get_next_id()) then
			transfer_money_to_player(save_id, safe_money);
		end

		GuiLayoutEnd(gui);

		GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);

		for _, money_amt in ipairs(money_amts) do
			if player_money < money_amt then
				GuiColorNextWidgetEnum(gui, COLORS.Dark);
				GuiText(gui, 0, 0, "Stash $ " .. money_amt);
			else
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				if GuiButton(gui, 0, 0, "Stash $ " .. money_amt, get_next_id()) then
					transfer_money_to_safe(save_id, money_amt);
				end
			end
		end

		GuiColorNextWidgetEnum(gui, COLORS.Green);
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
	active_windows["research_wands"] = { true, function(get_next_id)
		local wand_entity_ids = get_all_wands();
		local player_money = get_player_money();
		local x_offset = 0;
		local block_width = 115;

		GuiBeginScrollContainer(gui, get_next_id(), 30, 20, 450, 200, true, gui_margin_x, gui_margin_y);
		for i = 0, 3 do
			x_offset = i * block_width;
			local is_new, b_spells_per_cast, b_cast_delay_min, b_cast_delay_max, b_recharge_time_min, b_recharge_time_max, b_mana_max, b_mana_charge_speed, b_capacity, b_spread_min, b_spread_max, b_always_cast_spells, b_wand_types, i_always_cast_spells
						 = research_wand_is_new(get_selected_save_id(), wand_entity_ids[i]);

			if is_new then
				GuiColorNextWidgetEnum(gui, COLORS.Tip);
			end
			GuiText(gui, x_offset + 20, 32, "Wand Slot " .. tostring(i+1) .. ":");
			local gui_icon = (is_new) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";
			local frame_y = 77;
			local frame_x = 2;
			local frame_offset_y = -14;
			local frame_offset_x = 6;
			GuiImage(gui, get_next_id(), x_offset + frame_x, frame_y, gui_icon, 1, 1.75, 1.75, math.rad(-90)); -- radians are annoying

			if wand_entity_ids[i] ~= nil then

				local price = research_wand_price(get_selected_save_id(), wand_entity_ids[i]);
				local wand_preview = read_wand(wand_entity_ids[i]);

				local new_spells = false;
				if #wand_preview["spells"] then
					local new_spell_count = 0;
					local already_researched_spells = get_spells(get_selected_save_id());

					for _, spell_action_id in ipairs(wand_preview["spells"]) do
						if spell_action_id ~= nil and (already_researched_spells == nil or already_researched_spells[spell_action_id] == nil) then
							new_spells = true;
							new_spell_count = new_spell_count + 1;
						end
					end

					if new_spells then
						GuiColorNextWidgetEnum(gui, COLORS.Red);
						GuiText(gui, 4 + x_offset, 16, "Wand contains spells which", small_text_scale);
						GuiColorNextWidgetEnum(gui, COLORS.Red);
						GuiText(gui, 6 + x_offset, 22, "have not been researched", small_text_scale);
					end
				end

				if is_new then

					if #wand_preview["spells"] > 0 and not new_spells then
						GuiColorNextWidgetEnum(gui, COLORS.Yellow);
						GuiText(gui, 4 + x_offset, 15, "Wand contains spells which", small_text_scale);
						GuiColorNextWidgetEnum(gui, COLORS.Yellow);
						GuiText(gui, 6 + x_offset, 22, "will be lost on research", small_text_scale);
					end

					GuiColorNextWidgetBool(gui, price <= player_money);
					if GuiButton(gui, 6 + x_offset, 5, " Research for $" .. tostring(price), get_next_id()) then
						research_wand(get_selected_save_id(), wand_entity_ids[i]);
						wand_entity_ids[i] = nil; -- Verify this works
						GamePrintImportant("Wand Researched");
					end
				else
					GuiColorNextWidgetEnum(gui, COLORS.Dim);
					GuiText(gui, 14 + x_offset, 7, " No improved stats ");
				end

				-- local wand_offset_x, wand_offset_y = get_wand_grip_offset(wand_preview["wand_type"]);
				-- wand_offset_x, wand_offset_y = get_wand_rotated_offset(wand_offset_x, wand_offset_y, -45)

				-- GuiImage(gui, get_next_id(), x_offset + frame_x + frame_offset_x - wand_offset_x, frame_y - frame_offset_y + wand_offset_y, wand_type_to_sprite_file(wand_preview["wand_type"]), 1, 1.333, 1, math.rad(-45)); -- radians are annoying
				GuiImage(gui, get_next_id(), x_offset + frame_x + frame_offset_x, frame_y + frame_offset_y, wand_type_to_sprite_file(wand_preview["wand_type"]), 1, 1.333, 1.333, math.rad(-45)); -- radians are annoying
				if b_wand_types then
					local new_icon = "data/ui_gfx/damage_indicators/explosion.png";
					local new_offset_x = 6;
					local new_offset_y = -34;
					GuiImage(gui, get_next_id(), x_offset + frame_x + new_offset_x, frame_y + new_offset_y, new_icon, 1, 2, 2, math.rad(30)); -- radians are annoying
					GuiTooltip(gui, "This wand provides a new design.", "");
				end
				GuiBeginScrollContainer(gui, get_next_id(), x_offset + frame_x + 37, frame_y - 31, 64, 26, true, 0, 0);
				for idx = 0, wand_preview["capacity"] - 1 do
					local grid_x = ((idx%5) * 12); -- + 33;
					local grid_y = (math.floor(idx/5) * 12); -- - 34;
					GuiImage(gui, get_next_id(), grid_x, grid_y, "data/ui_gfx/inventory/inventory_box.png", 1, 0.8, 0.8, 0);
					-- GuiImage(gui, get_next_id(), x_offset + frame_x + grid_x, frame_y + grid_y, "data/ui_gfx/inventory/inventory_box.png", 1, 0.75, 0.75, 0);
					if wand_preview["spells"][idx+1] ~= nil then
						-- GuiImage(gui, get_next_id(), x_offset + frame_x + grid_x, frame_y + grid_y, actions_by_id[wand_preview["spells"][idx+1]].sprite, 1, 0.75, 0.75, 0);
						GuiImage(gui, get_next_id(), grid_x, grid_y, actions_by_id[wand_preview["spells"][idx+1]].sprite, 1, 0.8, 0.8, 0);
						GuiTooltip(gui, actions_by_id[wand_preview["spells"][idx+1]].name, actions_by_id[wand_preview["spells"][idx+1]].description );
					end
				end
				GuiEndScrollContainer(gui);
				GuiLayoutBeginHorizontal(gui, x_offset + 8, 77, true, gui_margin_x, gui_margin_y);
				GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
				GuiText(gui, 0, 0, "$inventory_shuffle", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_actionspercast", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_castdelay", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_rechargetime", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_manamax", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_manachargespeed", small_text_scale);
				if #wand_preview["spells"] then
					GuiColorNextWidgetEnum(gui, COLORS.Yellow);
				end
				GuiText(gui, 0, 0, "$inventory_capacity", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_spread", small_text_scale);
				GuiText(gui, 0, 0, "$inventory_alwayscasts", small_text_scale);
				GuiLayoutEnd(gui);
				GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
				GuiText(gui, 0, 0, wand_preview["shuffle"] and "$menu_yes" or "$menu_no", small_text_scale);
				GuiColorNextWidgetBool(gui, b_spells_per_cast);
				GuiText(gui, 0, 0, wand_preview["spells_per_cast"], small_text_scale);
				GuiColorNextWidgetBool(gui, b_cast_delay_min or b_cast_delay_max);
				GuiText(gui, 0, 0, tostring(math.floor((wand_preview["cast_delay"] / 60) * 100 + 0.5) / 100), small_text_scale);
				GuiColorNextWidgetBool(gui, b_recharge_time_min or b_recharge_time_max);
				GuiText(gui, 0, 0, tostring(math.floor((wand_preview["recharge_time"] / 60) * 100 + 0.5) / 100), small_text_scale);
				GuiColorNextWidgetBool(gui, b_mana_max);
				GuiText(gui, 0, 0, tostring(wand_preview["mana_max"]), small_text_scale);
				GuiColorNextWidgetBool(gui, b_mana_charge_speed);
				GuiText(gui, 0, 0, tostring(wand_preview["mana_charge_speed"]), small_text_scale);
				GuiColorNextWidgetBool(gui, b_capacity);
				GuiText(gui, 0, 0, tostring(wand_preview["capacity"]), small_text_scale);
				GuiColorNextWidgetBool(gui, b_spread_min or b_spread_max);
				GuiText(gui, 0, 0, tostring(math.floor(wand_preview["spread"] * 10 + 0.5) / 10), small_text_scale);
				GuiColorNextWidgetBool(gui, b_always_cast_spells);
				GuiText(gui, 0, 0, tostring(#wand_preview["always_cast_spells"]) .. " spells", small_text_scale);
				GuiLayoutEnd(gui);
				GuiLayoutEnd(gui);
				if #wand_preview["always_cast_spells"] > 0 then
					local idx = 0;
					for i = 0, #wand_preview["always_cast_spells"] - 1 do
						local grid_x = ((idx%5) * 12); -- + 33;
						local grid_y = (math.floor(idx/5) * 12); -- - 34;
						GuiImage(gui, get_next_id(), x_offset + 8 + grid_x, 177 + grid_y, "data/ui_gfx/inventory/inventory_box.png", 1, 0.8, 0.8, 0);
						if wand_preview["always_cast_spells"][idx+1] ~= nil then
							GuiImage(gui, get_next_id(), x_offset + 8 + grid_x, 177 + grid_y, actions_by_id[wand_preview["always_cast_spells"][idx+1]].sprite, 1, 0.8, 0.8, 0);
							GuiTooltip(gui, actions_by_id[wand_preview["always_cast_spells"][idx+1]].name, actions_by_id[wand_preview["always_cast_spells"][idx+1]].description );
						end
					end
				end

			else
				GuiColorNextWidgetEnum(gui, COLORS.Dim);
				GuiText(gui, 6 + x_offset, 5, "(Not New)");
			end
		end
		GuiEndScrollContainer(gui);

		GuiColorNextWidgetEnum(gui, COLORS.Green);
		GuiText(gui, 30, 225, "Green stats improve your research", small_text_scale);
		GuiColorNextWidgetEnum(gui, COLORS.Red);
		GuiText(gui, 380, 225, "Red stats do not improve research", small_text_scale);
			GuiColorNextWidgetEnum(gui, COLORS.Tip);
			GuiText(gui, 165, 225, "WANDS ARE DESTROYED WHEN RESEARCHED");
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
	local already_researched_spells = get_spells(get_selected_save_id());

	local idx = 1;
	local researchable_spell_entities = {};
	local hash = {};

	for _, inv_spell_entity_id in ipairs(inv_spell_entity_ids) do
		-- TODO: Don't accept partially used spells
		local spell_action_id = get_spell_entity_action_id(inv_spell_entity_id);
		if spell_action_id ~= nil and (already_researched_spells == nil or already_researched_spells[spell_action_id] == nil) then
			if not hash[spell_action_id] then
				researchable_spell_entities[idx] = inv_spell_entity_id;
				hash[spell_action_id] = true;
				idx = idx + 1;
			end
		end
	end
	table.sort(researchable_spell_entities, function(a, b) return GameTextGetTranslatedOrNot(actions_by_id[get_spell_entity_action_id(a)].name) < GameTextGetTranslatedOrNot(actions_by_id[get_spell_entity_action_id(b)].name) end );

	active_windows["research_spells"] = { true, function(get_next_id)
		GuiBeginScrollContainer(gui, get_next_id(), 30, 20, 450, 200, true, gui_margin_x, gui_margin_y);
		if #researchable_spell_entities > 0 then
			local player_money = get_player_money();

			local line_height = 28;
			for r_s_e_idx = 1, #researchable_spell_entities do
				curr_spell = actions_by_id[get_spell_entity_action_id(researchable_spell_entities[r_s_e_idx])];
				local line_pos = (r_s_e_idx - 1) * line_height;
				if player_money < curr_spell.price then
					GuiColorNextWidgetEnum(gui, COLORS.Red);
					GuiText(gui, 0, 3 + line_pos, " $ " .. curr_spell.price)
				else
					GuiColorNextWidgetEnum(gui, COLORS.Green);
					if GuiButton(gui, 0, 3 + line_pos, " $ " .. curr_spell.price, get_next_id()) then
						research_spell_entity(get_selected_save_id(), researchable_spell_entities[r_s_e_idx]);
						GamePrintImportant("Spell Researched", curr_spell.name);
						hide_research_spells_gui();
						show_research_spells_gui();
					end
				end -- Colorize Button
				GuiImage(gui, get_next_id(), 36, 0 + line_pos, curr_spell.sprite, 1, 1, 0, math.rad(0)); -- Icon
				GuiText(gui, 60, 0 + line_pos, GameTextGetTranslatedOrNot(curr_spell.name)); -- Name
				GuiText(gui, 60, 10 + line_pos, GameTextGetTranslatedOrNot(curr_spell.description)); -- Description
			end
		else
			GuiText(gui, 40, 40, "No new spells to research");
		end
		GuiEndScrollContainer(gui);
		GuiColorNextWidgetEnum(gui, COLORS.Tip);
		GuiText(gui, 162, 225, "SPELLS ARE DESTROYED WHEN RESEARCHED");
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
		local gui_margin_y = 3; -- Override
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
		local always_cast_spells = {};

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

		local wand_stat_names = {"spells_per_cast", "cast_delay",  "recharge_time",        "mana_max",  "mana_charge_speed",  "capacity",     "spread" };
		local wand_stat_scales = {      {1, 5, 10},   {1, 6, 60},      {1, 6, 60},       {1, 10, 100},         {1, 10, 100},  {1, 5, 10},  {.1, 1, 10},  };
		local wand_stat_limits = {};
		wand_stat_limits.min = {spells_per_cast_min, cast_delay_min, recharge_time_min, mana_min, mana_charge_speed_min, capacity_min, spread_min };
		wand_stat_limits.max = {spells_per_cast_max, cast_delay_max, recharge_time_max, mana_max, mana_charge_speed_max, capacity_max, spread_max };

		local idx = 0;
		for spell_id, _ in pairs(get_always_cast_spells(save_id)) do
			always_cast_spells[idx] = actions_by_id[spell_id];
			always_cast_spells[idx].id = spell_id;
			idx = idx + 1;
		end
		table.sort(always_cast_spells, function(a, b) return GameTextGetTranslatedOrNot(a.name) < GameTextGetTranslatedOrNot(b.name) end );



		local function toggle_select_spell(action_id)
			local selected = false;
			local found = false;

			for i = 0, #always_cast_spells do
				if always_cast_spells[i].id == action_id then
					selected = not always_cast_spells[i].selected;
					always_cast_spells[i].selected = selected;
					break;
				end
			end

			for i = 0, #wand_data_selected["always_cast_spells"] do
				if wand_data_selected["always_cast_spells"][i] == action_id then
					found = true;
					if not selected then
						table.remove(wand_data_selected["always_cast_spells"], i);
					end
					break;
				end
			end

			if selected and not found then
				table.insert(wand_data_selected["always_cast_spells"], action_id);
			end
		end

		active_windows["buy_wands"] = { true, function(get_next_id)
			local player_money = get_player_money();
			local price = create_wand_price(wand_data_selected);
			if window_nr == WINDOW_ID.id_base then
				local wand_offset_x, wand_offset_y = get_wand_grip_offset(wand_data_selected["wand_type"]);
				wand_offset_x, wand_offset_y = get_wand_rotated_offset(wand_offset_x, wand_offset_y, 45);
				local frame_icon = "data/ui_gfx/inventory/full_inventory_box_highlight.png";
				local frame_y = 70;
				local frame_x = 267;
				local frame_offset_y = -12;
				local frame_offset_x = 11;

				GuiLayoutBeginLayer(gui);
				GuiImage(gui, get_next_id(), frame_x, frame_y, frame_icon, 1, 1.5, 1.5, math.rad(-90)); -- radians are annoying
				GuiImage(gui, get_next_id(), frame_x+frame_offset_x-wand_offset_x, frame_y+frame_offset_y-wand_offset_y, wand_type_to_sprite_file(wand_data_selected["wand_type"]), 1, 1, 1,  math.rad(-45)); -- radians are annoying
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
						GuiColorNextWidgetEnum(gui, COLORS.Green);
						if GuiButton(gui, 0, 0, "<", get_next_id()) then
							wand_data_selected["shuffle"] = false;
						end
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
								GuiColorNextWidgetEnum(gui, COLORS.Green);
								if GuiButton(gui, 0, 0, "|" .. string.rep("<", scale-1), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_min;
								end
							else
								GuiColorNextWidgetEnum(gui, COLORS.Green);
								if GuiButton(gui, 0, 0, string.rep("<", scale), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_data - stat_step;
								end
							end
						else
							GuiButton(gui, 0, 0, " ", get_next_id());
						end
					end -- ipairs(wand_stat_names)
					GuiLayoutEnd(gui);
				end -- scale

				GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
				GuiColorNextWidgetEnum(gui, COLORS.Tip);
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
				GuiColorNextWidgetEnum(gui, COLORS.Tip);
				if GuiButton(gui, 0, 0, "Select", get_next_id()) then
					window_nr = WINDOW_ID.id_pick_alwayscast;
				end
				GuiLayoutEnd(gui);


				for scale=1, 3, 1 do
					GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_short_x, gui_margin_y);
					GuiText(gui, 0, 0, " "); -- filler for img select

					if (scale == 1 and wand_data_selected["shuffle"] == false) then
						GuiColorNextWidgetEnum(gui, COLORS.Green);
						if GuiButton(gui, 0, 0, ">", get_next_id()) then
							wand_data_selected["shuffle"] = true;
						end
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
								GuiColorNextWidgetEnum(gui, COLORS.Green);
								if GuiButton(gui, 0, 0, string.rep(">", scale-1) .. "|", get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_max;
								end
							else
								GuiColorNextWidgetEnum(gui, COLORS.Green);
								if GuiButton(gui, 0, 0, string.rep(">", scale), get_next_id()) then
									wand_data_selected[wand_stat_name] = stat_data + stat_step;
								end
							end
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
					GuiColorNextWidgetEnum(gui, COLORS.Red);
					GuiText(gui, 0, 0, " $ " .. tostring(price));
				else
					GuiColorNextWidgetEnum(gui, COLORS.Green);
					if GuiButton(gui, 0, 0, " $ " .. tostring(price), get_next_id()) then
						create_wand(wand_data_selected);
						GamePrintImportant("Wand Purchased");
					end
				end
				GuiLayoutEnd(gui);

				for i = 1, get_template_count() do
					local template_preview = get_template(save_id, i);
					local template_hover = 0;
					GuiLayoutBeginVertical(gui, 80, 44 + ((i-1) * 11));
					GuiText(gui, 0, 0, "Template Slot " .. pad_number(i, #tostring(get_template_count())) .. ":");
					if template_preview == nil then	-- Template empty
						GuiColorNextWidgetEnum(gui, COLORS.Green);
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
						GuiColorNextWidgetEnum(gui, COLORS.Green);
						if GuiButton(gui, 0, 0, "Load template", get_next_id()) then
							wand_data_selected = template_preview;
							for _, curr_spell in pairs(always_cast_spells) do
								for i = 0, #wand_data_selected["always_cast_spells"] do
									curr_spell.selected = wand_data_selected["always_cast_spells"][i] == curr_spell.id;
									-- if wand_data_selected["always_cast_spells"][i] == curr_spell.id then
									-- 	curr_spell.selected = true;
									-- end
								end
							end
						end
						if select(3, GuiGetPreviousWidgetInfo(gui)) then
							template_hover = i;
						end
						if delete_template_confirmation == i then
							GuiColorNextWidgetEnum(gui, COLORS.Yellow);
							if GuiButton(gui, 0, 0, "Press again to delete", get_next_id()) then
								delete_template_confirmation = 0;
								delete_template(save_id, i);
								template_hover = 0;
							elseif select(3, GuiGetPreviousWidgetInfo(gui)) then
								template_hover = i;
							end
							else
							GuiColorNextWidgetEnum(gui, COLORS.Yellow);
							if GuiButton(gui, 0, 0, "Delete template", get_next_id()) then
								delete_template_confirmation = i;
							end
							if select(3, GuiGetPreviousWidgetInfo(gui)) then
								template_hover = i;
							end
							end
						GuiLayoutEnd(gui);
						GuiLayoutEnd(gui);
					end
					GuiLayoutEnd(gui);

					if template_hover ~= 0 then
						local template_preview = get_template(save_id, i);
						GuiBeginScrollContainer(gui, get_next_id(), 400, 180, 90, 140);
						GuiLayoutBeginHorizontal(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						GuiLayoutBeginVertical(gui, 0, 0, false, gui_margin_x, gui_margin_y);
						GuiText(gui, 0, 0, " - Template");
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
						GuiText(gui, 0, 0, i .. " - ");
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
						GuiEndScrollContainer(gui);
					end
				end
			elseif window_nr == WINDOW_ID.id_pick_alwayscast then

				GuiBeginScrollContainer(gui, get_next_id(), 30, 20, 450, 200, true, gui_margin_x, gui_margin_y);
				idx = 0;
				local line_height = 28;
				for _, curr_spell in pairs(always_cast_spells) do
					local line_pos = idx * line_height;
					GuiColorNextWidgetBool(gui, curr_spell.selected==true);
					local newprice = math.ceil((curr_spell.price * 5) * ModSettingGet("persistence.buy_wand_price_multiplier"));
					if GuiButton(gui, 0, 3 + line_pos, " $ " .. newprice, get_next_id()) then
						toggle_select_spell(curr_spell.id);
					end	-- Button (Cost)
					GuiImage(gui, get_next_id(), 36, 0 + line_pos, curr_spell.sprite, 1, 1, 0, math.rad(0)); -- Icon
					GuiText(gui, 60, 0 + line_pos, GameTextGetTranslatedOrNot(curr_spell.name)); -- Name
					GuiText(gui, 60, 10 + line_pos, GameTextGetTranslatedOrNot(curr_spell.description)); -- Description
					idx = idx + 1;
				end
				GuiEndScrollContainer(gui);
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				GuiText(gui, 30, 225, "You know " .. #always_cast_spells+1 .. " always-cast spells.", small_text_scale);

			elseif window_nr == WINDOW_ID.id_pick_icon then
				idx = 0;
				local line_gap = 60;
				local icon_gap_x = 128;

				GuiBeginScrollContainer(gui, get_next_id(), 30, 20, 450, 200, true, gui_margin_x, gui_margin_y);
				for wand_type, _ in pairs(wand_types) do
					x_offset = 20 + ((idx % 4) * icon_gap_x);
					y_offset = math.floor(idx / 4) * (line_gap);
					local frame_x = 0;
					local frame_y = 34;
					local frame_offset_x = 10;
					local frame_offset_y = -11;

					local wand_offset_x, wand_offset_y = get_wand_grip_offset(wand_type);
					wand_offset_x, wand_offset_y = get_wand_rotated_offset(wand_offset_x, wand_offset_y, 45);

					if GuiButton(gui, x_offset + 3, 1 + frame_y + y_offset, "Select", get_next_id()) then
						wand_data_selected["wand_type"] = wand_type;
						window_nr = WINDOW_ID.id_base;
					end

					local gui_icon = (select(3, GuiGetPreviousWidgetInfo(gui))) and "data/ui_gfx/inventory/full_inventory_box_highlight.png" or "data/ui_gfx/inventory/full_inventory_box.png";
					GuiImage(gui, get_next_id(), x_offset + frame_x, y_offset + frame_y, gui_icon, 1, 1.5, 1.5, math.rad(-90)); -- radians are annoying
					GuiImage(gui, get_next_id(), x_offset + frame_x + frame_offset_x - wand_offset_x, y_offset + frame_y + frame_offset_y - wand_offset_y, wand_type_to_sprite_file(wand_type), 1, 1, 1, math.rad(-45)); -- radians are annoying
					GuiColorNextWidgetEnum(gui, COLORS.Tip);
					GuiText(gui, x_offset, 25 + frame_y + y_offset, " ");
					idx = idx + 1;
				end
				GuiEndScrollContainer(gui);
			end
			if window_nr ~= WINDOW_ID.id_base then
				GuiLayoutBeginHorizontal(gui, 43, 91);
				GuiColorNextWidgetEnum(gui, COLORS.Yellow);
				if GuiButton(gui, 0, 0, "$menu_return", get_next_id()) then
					window_nr = WINDOW_ID.id_base;
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

	local idx = 1;
	local spells = {};
	for spell_id, _ in pairs(get_spells(save_id)) do
		spells[idx] = actions_by_id[spell_id];
		spells[idx].id = spell_id;
		idx = idx + 1;
	end
	table.sort(spells, function(a, b) return GameTextGetTranslatedOrNot(a.name) < GameTextGetTranslatedOrNot(b.name) end );

	active_windows["buy_spells"] = { true, function(get_next_id)
		local player_money = get_player_money();
		GuiBeginScrollContainer(gui, get_next_id(), 30, 20, 450, 200, true, gui_margin_x, gui_margin_y);
		idx = 0;
		local line_height = 28;
		for _, curr_spell in pairs(spells) do
			local line_pos = idx * line_height;
			if player_money < curr_spell.price then
				GuiColorNextWidgetEnum(gui, COLORS.Red);
				GuiText(gui, 0, 3 + line_pos, " $ " .. curr_spell.price)
			else
				GuiColorNextWidgetEnum(gui, COLORS.Green);
				if GuiButton(gui, 0, 3 + line_pos, " $ " .. curr_spell.price, get_next_id()) then
					create_spell(curr_spell.id);
					GamePrintImportant("Spell Purchased", curr_spell.name);
				end	-- Button (Cost)
			end -- Colorize Button
			GuiImage(gui, get_next_id(), 36, 0 + line_pos, curr_spell.sprite, 1, 1, 0, math.rad(0)); -- Icon
			GuiLayoutBeginHorizontal(gui, 60, 0 + line_pos, true, 4, 0);
			GuiColorNextWidgetEnum(gui, COLORS.Tip);
			GuiText(gui, 0, 0, GameTextGetTranslatedOrNot(curr_spell.name)); -- Name
			if curr_spell.max_uses ~= nil then
				GuiColorNextWidgetEnum(gui, COLORS.Bright);
				GuiText(gui, 0, 0, "(" .. curr_spell.max_uses .. ")");
			end
			GuiLayoutEnd(gui);
			GuiText(gui, 60, 10 + line_pos, GameTextGetTranslatedOrNot(curr_spell.description)); -- Description
			idx = idx + 1;
		end
		GuiEndScrollContainer(gui);
		GuiColorNextWidgetEnum(gui, COLORS.Tip);
		GuiText(gui, 165, 225, "PURCHASED SPELLS DROP AT YOUR FEET");
		GuiColorNextWidgetEnum(gui, COLORS.Green);
		GuiText(gui, 30, 225, "You know " .. #spells .. " spells.", small_text_scale);
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
			GuiColorNextWidgetEnum(gui, COLORS.Yellow);
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

local menu_switched = false;
function gui_update()
	if InputIsKeyJustDown(Key_TAB) or InputIsKeyJustDown(Key_SPACE) or InputIsKeyJustDown(Key_i) or InputIsKeyJustDown(Key_ESCAPE) then
		hide_money_gui();
		hide_research_wands_gui();
		hide_research_spells_gui();
		hide_buy_wands_gui();
		hide_buy_spells_gui();
	end

	local submenu_open = money_open or research_wands_open or research_spells_open or buy_wands_open or buy_spells_open or save_open;
	if submenu_open then
		if not menu_switched then
			menu_switched = true;
			disable_controls();
		end
	else
		if menu_switched then
			menu_switched = false;
			enable_controls();
		end
	end

	if gui ~= nil and active_windows ~= nil then
		GuiStartFrame(gui);
		local start_gui_id = 14796823;
		if submenu_open then 
			GuiZSetForNextWidget(gui, 1000);
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