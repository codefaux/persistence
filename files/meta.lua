---@meta

---@class (exact) wand_bounds_data Bounds of wand creation stats
---@field wand_types {[string]: boolean} array of wand types, true if known
---@field always_casts {[string]: boolean} array of always cast spells, true if known
---@field always_cast_count integer max number of always cast spells
---@field spells_per_cast integer[] min, max count of spells per cast to add to a wand
---@field cast_delay integer[] min, max cast delay, needs conversion for display
---@field recharge_time integer[] min, max recharge time, needs conversion for display
---@field mana_max integer[] min, max mana capacity
---@field mana_charge_speed integer[] min, max mana recharge speed
---@field capacity integer[] min, max count of inventory slots for wand
---@field spread integer[] min, max innate spread
wand_bounds_data = {
  wand_types = {"default_1", "default_2"},
  always_casts = {},
  always_cast_count = 0,
  spells_per_cast = {1, 1},
  cast_delay = {0,1},
  recharge_time = {0, 1},
  mana_max = {0, 1},
  mana_charge_speed = {0, 1},
  capacity = {0, 1},
  spread = {0, 1},
}