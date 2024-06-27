if GlobalsGetValue("persistence_active", "false")=="false" then return; end

local _e_id = GlobalsGetValue("persistence_lobby_effect_entity", "0");

if _e_id~=0 then
	EntitySetComponentIsEnabled(_e_id, GlobalsGetValue("persistence_lobby_effect_component", "0") or 0, GlobalsGetValue("lobby_collider_triggered", "0")~="0" or GlobalsGetValue("workshop_collider_triggered", "0")~="0");
end
