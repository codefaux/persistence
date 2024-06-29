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
	scan_nearby_entities_open=false;
	window_open=false;

	function _nil(...) return; end
	function _layer(n) return 1000 - ((n+1) * 50); end

	dofile(mod_dir .. "files/gui/fourslot.lua");
	dofile(mod_dir .. "files/gui/modify_wand.lua");
	dofile(mod_dir .. "files/gui/money.lua");
	dofile(mod_dir .. "files/gui/persistence.lua");
	dofile(mod_dir .. "files/gui/scan_nearby_entities.lua");
	dofile(mod_dir .. "files/gui/spell_list.lua");
	dofile(mod_dir .. "files/gui/spell_tooltip.lua");
	dofile(mod_dir .. "files/gui/teleport.lua");
  dofile(mod_dir .. "files/gui/wand_template.lua");

	---Close all open windows, optionally even windows not normally requiring close
	---@param force_all any
	function close_open_windows(force_all)
		close_money();
		close_wands();
		close_purchase_spells();
		close_inventory_spells();
		close_modify_wand();
		if force_all then
			close_wand_template();
			close_persistence_menu();
			close_spell_tooltip();
		end
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
if spell_tooltip_id=="" then close_spell_tooltip(); end
spell_tooltip_id="";

if loaded_profile_id>0 then
	---profile loaded, proceed as normal
	if profile_open then close_profile_ui(); end

	if isLocked() then UnlockPlayer(); end

	present_scan_nearby_entities();

	if InputIsKeyJustDown(Key_TAB) then
		close_money();
		close_wands();
		close_modify_wand();
		close_purchase_spells();
		close_inventory_spells();
		close_spell_tooltip();
		-- close_persistence_menu();
		close_wand_template();
	end

	if _workshop then
		present_teleport();
	else
		close_teleport();
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

window_open = profile_open or money_open or wands_open or inventory_spells_open or modify_wand_open;
-- if window_open and spell_tooltip_id~="" then show_spell_tooltip_gui(); end

if gui~=nil and active_windows~=nil and (window_open or persistence_visible) and EntityGetIsAlive(player_e_id) then
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