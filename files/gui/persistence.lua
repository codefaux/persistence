dofile_once("data/scripts/debug/keycodes.lua");

local function draw_persistence_menu()
  persistence_expanded = false;
  active_windows["persistence"] = function (_nid)
    local x_base = 2;
    local x_offset = 25;
    local y_base = 348;
    local y_expand = 40;
    if persistence_expanded==false then

      GuiZSet(gui, _layer(0)); ---gui frame
      GuiImageNinePiece(gui, _nid(), x_base, y_base, 50, 10);
      GuiZSet(gui, _layer(1));

      GuiColorNextWidgetEnum(gui, COLORS.Tip);
      GuiOptionsAddForNextWidget(gui, GUI_OPTION.Align_HorizontalCenter);
      if GuiButton(gui, _nid(), x_base + x_offset, y_base, "persistence", 1) or InputIsKeyJustDown(Key_GRAVE) then
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
      if GuiButton(gui, _nid(), x_base + x_offset, y_base, "-close-", 1) or InputIsKeyJustDown(Key_GRAVE) then
        close_open_windows();
        persistence_expanded=false;
      end
    end
  end
end

function present_persistence_menu()
  if persistence_visible==true then return; end

  draw_persistence_menu();
  persistence_visible = false;
end

persistence_visible = true;
function close_persistence_menu()
  if persistence_visible==false then return; end

  active_windows["persistence"] = nil;
  persistence_visible = false;
end
