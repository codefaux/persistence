function collision_trigger(colliding_entity_id)
	if GlobalsGetValue("lobby_collider_triggered", "x")~="1" then
		GlobalsSetValue("lobby_collider_triggered", "1");
	end
end
