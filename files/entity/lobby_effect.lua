
if GlobalsGetValue("persistence_active", "false")=="false" then return; end

local _e_id = GetUpdatedEntityID();
if _e_id==0 then return; end

local _c_id = EntityGetFirstComponentIncludingDisabled(_e_id, "GameEffectComponent");
if _c_id==nil or _c_id==0 then return; end

EntitySetComponentIsEnabled(_e_id, _c_id, GlobalsGetValue("lobby_collider_triggered", "0")~="0" or GlobalsGetValue("workshop_collider_triggered", "0")~="0");
