local smoke =
{
  type = "smoke-with-trigger",
  name = "protoss-building-smoke",
  flags = {"not-on-map", "placeable-off-grid"},
  show_when_smoke_off = true,
  animation =
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 16,
    scale = 1.5,
    animation_speed = 0.5,
    shift = {0, 1}
  },
  glow_animation =
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 16,
    scale = 1.5,
    animation_speed = 0.5,
    shift = {0, 1}
  },
  affected_by_wind = false,
  cyclic = true,
  duration = 2 ^ 31,
  fade_away_duration = 1,
  fade_in_duration = 2 ^ 30,
  spread_duration = 10,
  color = { r = 1, g = 1, b = 1, a = 1},
  movement_slow_down_factor = 0,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        type = "nested-result",
        action =
        {
          {
            type = "area",
            collision_mode = "distance-from-center",
            radius = 0.1,
            force = "friend",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = -25/4, type = util.damage_type("heal")}
              }
            }
          },
          {
            type = "area",
            target_entities = false,
            --probability = 0.5,
            radius = 1,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "create-entity",
                entity_name = "sparks-explosion"
              }
            }

          }
        }
      }
    }
  },
  action_cooldown = 15
}

local explosion =
  {
  type = "explosion",
  name = "sparks-explosion",
  flags = {"not-on-map"},
  height = 0.5,
  animations =
  {
    {
      filename = "__base__/graphics/entity/sparks/sparks-01.png",
      width = 39,
      height = 34,
      frame_count = 19,
      line_length = 19,
      shift = {-0.109375, 0.3125},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    },
    {
      filename = "__base__/graphics/entity/sparks/sparks-02.png",
      width = 36,
      height = 32,
      frame_count = 19,
      line_length = 19,
      shift = {0.03125, 0.125},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    },
    {
      filename = "__base__/graphics/entity/sparks/sparks-03.png",
      width = 42,
      height = 29,
      frame_count = 19,
      line_length = 19,
      shift = {-0.0625, 0.203125},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    },
    {
      filename = "__base__/graphics/entity/sparks/sparks-04.png",
      width = 40,
      height = 35,
      frame_count = 19,
      line_length = 19,
      shift = {-0.0625, 0.234375},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    },
    {
      filename = "__base__/graphics/entity/sparks/sparks-05.png",
      width = 39,
      height = 29,
      frame_count = 19,
      line_length = 19,
      shift = {-0.109375, 0.171875},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    },
    {
      filename = "__base__/graphics/entity/sparks/sparks-06.png",
      width = 44,
      height = 36,
      frame_count = 19,
      line_length = 19,
      shift = {0.03125, 0.3125},
      tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
      animation_speed = 0.3
    }
  },
  light = {intensity = 0.5, size = 5, color = {r=1.0, g=1.0, b=0.3}},
}

data:extend
{
  smoke,
  explosion
}