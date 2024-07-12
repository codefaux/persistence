if entity_mgr_loaded==nil then entity_mgr_loaded=false; end
if entity_mgr_loaded==false then
-- one time init
  known_workshops = {};
  lobby_e_id = 0;
  local _lobby_entity_frame_skip=30;

  local function _do_lobby_effect_check()
    if mod_setting.enable_edit_wands_in_lobby==true then
      local _lobby_effect_pool = EntityGetWithName("persistence_lobby_effect_entity");
      if _lobby_effect_pool==nil or _lobby_effect_pool==0 then
        if type(_lobby_effect_pool)=="table" then
          for _, _e_id in ipairs(_lobby_effect_pool) do
            EntityKill(_e_id);
          end
        end
        create_lobby_effect_entity();
      end
    end
  end

  ---close out frame by disabling triggers
  function OnModEndFrame()
    local _lobby_frames = tonumber(GlobalsGetValue("lobby_collider_triggered", "0"));
    local _workshop_frames = tonumber(GlobalsGetValue("workshop_collider_triggered", "0"));
    local _game_frame = GameGetFrameNum();

    if _lobby_frames>0 then
      GlobalsSetValue("lobby_collider_triggered", tostring(_lobby_frames-1));
    end  ---decrement trigger per frame, re-enabled by collider entity

    if _workshop_frames>0 then
      GlobalsSetValue("workshop_collider_triggered", tostring(_workshop_frames-1));
    end  ---decrement trigger per frame, re-enabled by collider entity

    if _game_frame%_lobby_entity_frame_skip==0 and _lobby_frames>1 then
      _do_lobby_effect_check();
    end
  end

  function LockPlayer()
    if player_e_id==0 or not EntityGetIsAlive(player_e_id) then return; end
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "PlatformShooterPlayerComponent") or 0, false); --- Recenters camera
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "CharacterDataComponent") or 0, false);  --- Stops movement
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "DamageModelComponent") or 0, false); --- Prevents damage
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent") or 0, false); --- Removes inventory GUI
    -- EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component") or 0, false); --- Disables player inventory
    -- EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent") or 0, false); --- Disables player controls
  end

  function UnlockPlayer()
    if player_e_id==0 or not EntityGetIsAlive(player_e_id) then return; end
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "PlatformShooterPlayerComponent") or 0, true);
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "CharacterDataComponent") or 0, true);
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "DamageModelComponent") or 0, true);
    EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent") or 0, true);
    -- EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component") or 0, true);
    -- EntitySetComponentIsEnabled(player_e_id, EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent") or 0, true);
  end

  function isLocked()
    if player_e_id==0 or not EntityGetIsAlive(player_e_id) then return false; end
    return not (ComponentGetIsEnabled(EntityGetFirstComponentIncludingDisabled(player_e_id, "ControlsComponent") or 0) and ComponentGetIsEnabled(EntityGetFirstComponentIncludingDisabled(player_e_id, "Inventory2Component") or 0) and ComponentGetIsEnabled(EntityGetFirstComponentIncludingDisabled(player_e_id, "InventoryGuiComponent") or 0));
  end

  ---end function declarations, run code here;



end


-- TODO : Remove Move lobby to spawn mod setting?


-- every frame
local _frame_skip=10;
if GameGetFrameNum()%_frame_skip==0 then -- every five frames, for performance
  if lobby_e_id==0 and player_e_id~=0 then
    lobby_e_id=EntityGetWithName("persistence_lobby");
    if lobby_e_id==0 then
      local x_loc = GlobalsGetValue("first_spawn_x", "x");
      local y_loc = GlobalsGetValue("first_spawn_y", "x");
      lobby_e_id = EntityLoad(mod_dir .. "files/entity/lobby.xml", x_loc, y_loc);
    end
  end

  local workshop_pool = EntityGetWithTag("workshop");
  for _, workshop_e_id in ipairs(workshop_pool) do
    if not EntityHasTag(workshop_e_id, "persistence_cloned") then
      local workshop_hitbox_comp = EntityGetComponent(workshop_e_id, "HitboxComponent")[1];
      if workshop_hitbox_comp~=nil then
        local workshop_hitbox = ComponentGetMembers(workshop_hitbox_comp);
        if workshop_hitbox~=nil then
          print("persistence: entity_mgr.lua: cloend workshop " .. workshop_e_id);
          local _width = workshop_hitbox["aabb_max_x"] - workshop_hitbox["aabb_min_x"];
          local _height = workshop_hitbox["aabb_max_y"] - workshop_hitbox["aabb_min_y"];
          local _xloc, _yloc = EntityGetFirstHitboxCenter(workshop_e_id);
          local new_workshop_id = EntityLoad(mod_dir .. "files/entity/persistence_workshop.xml", _xloc, _yloc);
          EntityAddComponent2(new_workshop_id, "CollisionTriggerComponent", {width=_width, height=_height, radius=1000, destroy_this_entity_when_triggered=false, required_tag="player_unit", _enabled=true});
          EntityAddTag(workshop_e_id, "persistence_cloned");
          if mod_setting.reusable_holy_mountain~=true then
            EntityAddChild(workshop_e_id, new_workshop_id);
          end
        end
      end
    end
  end
end