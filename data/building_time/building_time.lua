local make_smoke = function(size)

local smoke =
  {
    type = "smoke-with-trigger",
    name = "building-smoke-"..size,
    flags = {"not-on-map", "placeable-off-grid"},
    show_when_smoke_off = true,
    affected_by_wind = false,
    cyclic = true,
    duration = 2 ^ 31,
    fade_away_duration = 1,
    fade_in_duration = 2 ^ 30,
    spread_duration = 10,
    movement_slow_down_factor = 0,
    animation = util.empty_sprite(),
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
              force = "same",
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  type = "damage",
                  damage = { amount = - shared.repair_rate /4, type = util.damage_type("heal")}
                }
              }
            },
            {
              type = "area",
              repeat_count = size,
              target_entities = false,
              --probability = 0.5,
              radius = size / 2,
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
  data:extend{smoke}
end

local sparks_animations =
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
}

local random_sparks = function()
  return util.copy(sparks_animations[math.random(#sparks_animations)])
end

local make_spark_random_spark = function()
  local speed_modifier = 1 + ((math.random() - 0.5) / 4)
  local scale_modifier = 1 + ((math.random() - 0.5) / 4)
  local random_spark = random_sparks()
  random_spark.animation_speed = random_spark.animation_speed * speed_modifier
  random_spark.scale = 1 * speed_modifier
  random_spark.tint.a = math.random()
  return random_spark
end

local random_spark_animation = {}

for k = 1, 100 do
  random_spark_animation[k] = make_spark_random_spark()
end

local explosion =
  {
  type = "explosion",
  name = "sparks-explosion",
  flags = {"not-on-map"},
  height = 0.1,
  light = {intensity = 0.5, size = 5, color = {r=1.0, g=1.0, b=0.3}},
  animations = random_spark_animation
}

data:extend
{
  explosion
}

for k = 1, 10 do
  make_smoke(k)
end