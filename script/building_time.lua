local shared = require("shared")

local script_data =
{
  building_finished = {},
  building_turrets = {},
  repair_blockers = {},
  ignore_reactivation = {}
}

local insert = table.insert

local add_building_finished = function(tick, entity, unit_number)

  local buildings = script_data.building_finished[tick]
  if not buildings then
    buildings = {}
    script_data.building_finished[tick] = buildings
  end

  buildings[unit_number] = entity

end

local ceil = math.ceil
local max = math.max
local min = math.min

local make_turret = function(entity, unit_number)
  local size = min(ceil((max(entity.get_radius() - 0.1, 0.25)) * 2), 10)
  local turret = entity.surface.create_entity{name = "building-time-unit-"..size, position = entity.position, force = "enemy"}
  turret.destructible = false
  script_data.building_turrets[unit_number] = turret
  turret.set_command
  {
    type = defines.command.attack,
    target = entity,
    distraction = defines.distraction.none
  }
end

local make_repair_blocker = function(entity, unit_number)
  local blocker = entity.surface.create_entity{name = "repair-block-robot", position = entity.position, force = entity.force}
  if not (blocker and blocker.valid) then return end
  local repair_inventory = blocker.get_inventory(defines.inventory.robot_repair)
  if repair_inventory then
    repair_inventory.insert("repair-pack")
  end
  blocker.destructible = false
  blocker.active = false
  script_data.repair_blockers[unit_number] = blocker
end

local on_built_entity = function(event)

  local entity = event.created_entity or event.entity
  if not (entity and entity.valid) then return end

  local unit_number = entity.unit_number
  if not unit_number then return end

  script.register_on_entity_destroyed(entity)
  local health = entity.prototype.max_health
  if not (health and health > 0) then return end

  make_turret(entity, unit_number)
  make_repair_blocker(entity, unit_number)

  entity.health = 0.1
  local duration = (ceil((health / shared.repair_rate)) * 60) + 15
  add_building_finished(event.tick + duration, entity, unit_number)

  if not entity.active then
    script_data.ignore_reactivation[unit_number] = true
  end
  entity.active = false

end

local destroy_turret = function(unit_number)

  local smoke = script_data.building_turrets[unit_number]
  if not smoke then return end

  script_data.building_turrets[unit_number] = nil

  if smoke.valid then
    smoke.destroy()
  end

end

local destroy_repair_blocker = function(unit_number)
  local blocker = script_data.repair_blockers[unit_number]
  if not blocker then return end

  script_data.repair_blockers[unit_number] = nil

  if blocker.valid then
    blocker.destroy()
  end
end

local reactivate_entity = function(unit_number, entity)

  local ignore = script_data.ignore_reactivation[unit_number]
  script_data.ignore_reactivation[unit_number] = nil

  if ignore then return end

  if (entity and entity.valid) then
    entity.active = true
  end

end

local on_tick = function(event)
  local tick = event.tick
  local buildings = script_data.building_finished[tick]
  if not buildings then return end

  for unit_number, entity in pairs (buildings) do
    reactivate_entity(unit_number, entity)
    destroy_turret(unit_number)
    destroy_repair_blocker(unit_number)
  end

  script_data.building_finished[tick] = nil

end

local entity_removed = function(unit_number)
  destroy_turret(unit_number)
  destroy_repair_blocker(unit_number)
  script_data.ignore_reactivation[unit_number] = nil
end

local fix_buffer = function(event)
  local buffer = event.buffer
  if not buffer then return end

  for k = 1, #buffer do
    local stack = buffer[k]
    if stack and stack.valid and stack.valid_for_read then
      stack.health = 1
    end
  end

end

local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  local unit_number = entity.unit_number
  if not unit_number then return end

  entity_removed(unit_number)
  fix_buffer(event)

end


local on_entity_destroyed = function(event)
  if event.unit_number then
    entity_removed(event.unit_number)
  end
end

local lib = {}

lib.events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.script_raised_revive] = on_built_entity,
  [defines.events.script_raised_built] = on_built_entity,

  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,

  [defines.events.on_entity_destroyed] = on_entity_destroyed,

  [defines.events.on_tick] = on_tick,
}

lib.on_load = function()
  script_data = global.building_time or script_data
end

lib.on_init = function()
  global.building_time = global.building_time or script_data
end

lib.on_configuration_changed = function()

end

return lib
