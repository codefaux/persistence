function collision_trigger(colliding_entity_id)
	if GlobalsGetValue("workshop_collider_triggered", "x")~="1" then
		---TODO: if GlobalsGetValue("persistence_allow_workshop_reuse")
		GlobalsSetValue("workshop_collider_triggered", "1");
		GlobalsSetValue("workshop_collider_triggered_edge", "1");
	end
end