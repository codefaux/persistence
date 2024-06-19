function collision_trigger(colliding_entity_id)
	if GlobalsGetValue("workshop_collider_triggered", "x")~="1" then
		GlobalsSetValue("workshop_collider_triggered", "1");
	end
end
