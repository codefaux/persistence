---@meta

---@class (exact) wand_bounds_data Bounds of wand creation stats
---@field wand_types {[string]: boolean} array of wand types, true if known
---@field spells_per_cast integer max count of spells per cast to add to a wand
---@field cast_delay_min integer minimum cast delay, needs conversion for display
---@field cast_delay_max integer maximum cast delay, needs conversion for display
---@field recharge_time_min integer minimum recharge time, needs conversion for display
---@field recharge_time_max integer maximum recharge time, needs conversion for display
---@field mana_max integer max mana capacity
---@field mana_charge_speed integer mana recharge speed
---@field capacity integer max count of inventory slots for wand
---@field spread_min integer minimum innate spread
---@field spread_max integer maximum innate spread
wand_data = {
  wand_types = {},
  spells_per_cast = 0,
  cast_delay_min = 0,
  cast_delay_max = 0,
  recharge_time_min = 0,
  recharge_time_max = 0,
  mana_max = 0,
  mana_charge_speed = 0,
  capacity = 0,
  spread_min = 0,
  spread_max = 0,
}