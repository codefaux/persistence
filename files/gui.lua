if persistence_gui_loaded~=true then
	-- once, on load


	---end function declarations, run code here;



  print("=========================");
  print("persistence: GUI loaded.");
	persistence_gui_loaded=true;
end


-- every frame;
if persistence_active==false then return; end
local _lobby = GlobalsGetValue("lobby_collider_triggered", "x")=="1";
local _workshop = GlobalsGetValue("workshop_collider_triggered", "x")=="1";
local _persistence_area = _lobby or _workshop;

dofile_once(mod_dir .. "files/data_store.lua");

if _lobby then GamePrint("lobby triggered"); end
if _workshop then GamePrint("workshop triggered"); end




-- flow:
-- profile loaded?
--- Mod settings: auto or manual?
---- Manual:
----- Disable controls
----- Pause sim?
----- UI for select profile
---- Auto:
----- select profile
--- load or create profile
-- else
--- _persistence_area?
----buy/research ui
----teleport ui
-- end