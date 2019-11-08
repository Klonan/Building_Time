local script_data =
{
  building_finished = {},
  entity_smoke = {}
}



local add_building_finished = function(tick, entity, smoke)

  local buildings = script_data.building_finished[tick]
  if not buildings then
    buildings = {}
    script_data.building_finished[tick] = buildings
  end

  table.insert(buildings, {entity = entity, smoke = smoke})

end

local on_built_entity = function(event)

  local entity = event.created_entity or event.entity
  if not (entity and entity.valid) then return end

  local unit_number = entity.unit_number
  if not unit_number then return end

  local health = entity.prototype.max_health
  if not health then return end
  entity.health = 0
  local duration = math.ceil(health / 25) * 60

  local smoke = entity.surface.create_entity{name = "protoss-building-smoke", position = entity.position, force = entity.force}

  add_building_finished(event.tick + duration, entity, smoke)
  entity.active = false
  --entity.minable = false
  --entity.operable = false
  --entity.rotatable = false

  script_data.entity_smoke[unit_number] = smoke



end

local on_tick = function(event)
  local buildings = script_data.building_finished[event.tick]
  if not buildings then return end

  for k, building in pairs (buildings) do
    local entity = building.entity
    if entity and entity.valid then
      entity.active = true
      --entity.minable = true
      --entity.operable = true
      --entity.rotatable = true
    end

    local smoke = building.smoke
    if smoke and smoke.valid then
      smoke.destroy()
    end

  end

  script_data.building_finished[event.tick] = nil


end

local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  local unit_number = entity.unit_number
  if not unit_number then return end

  local smoke = script_data.entity_smoke[unit_number]
  if not smoke then return end

  script_data.entity_smoke[unit_number] = nil

  if smoke.valid then
    smoke.destroy()
  end


end

local lib = {}

lib.events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.script_raised_revive] = on_built_entity,
  [defines.events.script_raised_built] = on_built_entity,

  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,


  [defines.events.on_tick] = on_tick,



}

lib.on_load = function()
  script_data = global.protoss_building or script_data
end

lib.on_init = function()
  global.protoss_building = global.protoss_building or script_data
end

return lib
