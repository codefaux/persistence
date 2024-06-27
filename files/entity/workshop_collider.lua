function collision_trigger(colliding_entity_id)
	if GlobalsGetValue("workshop_collider_triggered", "x")~="5" then
		GlobalsSetValue("workshop_collider_triggered", "5");
	end
end
