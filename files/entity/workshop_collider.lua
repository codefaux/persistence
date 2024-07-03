function collision_trigger(colliding_entity_id)

  GlobalsSetValue("workshop_collider_triggered", "13");

  local _e_id = GetUpdatedEntityID();
  GlobalsSetValue("workshop_e_id", tostring(_e_id));
  if not EntityHasTag(_e_id, "persistence_visited") then
    EntityAddTag(_e_id, "persistence_visited");
    EntityAddTag(_e_id, "persistence_unpaid");
  end
end
