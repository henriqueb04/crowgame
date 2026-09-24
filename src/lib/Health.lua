---@class Health : Component
---@field hp number The curent health points
---@field max_hp number The maximum amount of health points
---@field itime number The amount of seconds of invincibility after being hit
---@field blink_color integer The color the sprite should blink when getting hit
---@field private invincible_for number The current time the object should be invincible for
local Health = {}
Health.__index = Health

---@param hp number The curent health points
---@param max_hp number The maximum amount of health points
---@param itime number The amount of seconds of invincibility after being hit
---@param blink_color integer The color the sprite should blink when getting hit
---@return Health
function Health:new(hp, max_hp, itime, blink_color)
  local instance = setmetatable({}, self)
  instance.hp = hp
  instance.max_hp = max_hp
  instance.itime = itime
  instance.blink_color = blink_color
  instance.invincible_for = 0
  return instance
end

---@param damage number The amount of damage to the health
function Health:hit(damage)
  if self.invincible_for <= 0 then
    self.hp -= damage
    self.invincible_for = self.itime
    self.parent:broadcast("took_damage", self.itime, self.blink_color)
  end
end

---@param dt number
function Health:update(dt)
  if self.invincible_for > 0 then
    self.invincible_for -= dt
  end
end

return Health
