if persistence_gui_loaded==nil then persistence_gui_loaded=false; end
if persistence_gui_loaded==false then
	-- once, on load

	persistence_gui_loaded=true;
end


-- every frame;
if persistence_active==false then return; end
local _lobby = GlobalsGetValue("lobby_collider_triggered", "x")=="1";
local _workshop = GlobalsGetValue("workshop_collider_triggered", "x")=="1";
local _persistence_area = _lobby or _workshop;

if _lobby then GamePrint("lobby triggered"); end
if _workshop then GamePrint("workshop triggered"); end
