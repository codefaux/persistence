function collision_trigger(colliding_entity_id)
	if GlobalsGetValue("lobby_collider_triggered", "x")~="5" then
		GlobalsSetValue("lobby_collider_triggered", "5");
	end
end
