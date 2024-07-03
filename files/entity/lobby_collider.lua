function collision_trigger(colliding_entity_id)

  GlobalsSetValue("lobby_collider_triggered", "13"); --- triggers every 10 frames, plus leeway

  local _e_id = GetUpdatedEntityID();
  GlobalsSetValue("lobby_e_id", tostring(_e_id));
  if not EntityHasTag(_e_id, "persistence_visited") then
    EntityAddTag(_e_id, "persistence_visited");
  end
end
