---@class Object
---@field tag string
---@field pos [number, number]
---@field vel [number, number]
---@field components (Component | nil)[]
---@field sprite? Sprite
---@field body? Body
---@field health? Health
---@field scene_id? integer
---@field init fun(self: Object)
---@field update fun(self: Object, dt: number)
---@field draw fun(self: Object, dt: number)
local Object = {}
Object.__index = Object

local COMPONENT_COUNT = 3

---@param x number
---@param y number
---@param sprite? Sprite
---@param body? Body
---@param health? Health
---@return Object
function Object:new(x, y, sprite, body, health)
  local instance = setmetatable({}, self)
  instance.pos = { x, y }
  instance.vel = { 0, 0 }
  instance.sprite = sprite
  instance.body = body
  instance.health = health
  instance.components = { sprite, body, health }
  for i = 1, COMPONENT_COUNT do
    if instance.components[i] then
      instance.components[i].parent = instance
    end
  end
  return instance
end

---@return { top: number, bottom: number, left: number, right: number } The coordinate on the left side of the object's sprite/body
function Object:visual_bounds()
  local spr_left = 0
  local spr_right = 0
  local spr_up = 0
  local spr_down = 0
  if self.sprite then
    local full_x = self.sprite.size[1] * State.sprite_grid_size
    local full_y = self.sprite.size[2] * State.sprite_grid_size
    spr_up = self.sprite.pos_offset[2]
    spr_down = full_y + self.sprite.pos_offset[2]
    if self.sprite.flip_x then
      spr_left = -full_x - self.sprite.pos_offset[1]
      spr_right = -self.sprite.pos_offset[1]
    else
      spr_left = self.sprite.pos_offset[1]
      spr_right = full_x + self.sprite.pos_offset[1]
    end
  end
  local body_left = 0
  local body_up = 0
  local body_right = 0
  local body_down = 0
  if self.body and self.body.border then
    body_left = -self.body.radius
    body_up = -self.body.radius
    body_right = self.body.radius
    body_down = self.body.radius
  end
  return {
    top = self.pos[2] + math.min(spr_up, body_up),
    bottom = self.pos[2] + math.max(spr_down, body_down),
    left = self.pos[1] + math.min(spr_left, body_left),
    right = self.pos[1] + math.max(spr_right, body_right)
  }
end

function Object:broadcast(message, ...)
  for i = 1, COMPONENT_COUNT do
    if self.components[i] and self.components[i].on_message then
      self.components[i]:on_message(message, ...)
    end
  end
end

function Object:init() end
function Object:update(dt)
  for i = 1, COMPONENT_COUNT do
    if self.components[i] and self.components[i].update then
      self.components[i]:update(dt)
    end
  end
end
function Object:draw(dt)
  if self.body and (not self.sprite or not self.sprite.vanish) then
    self.body:draw(self.pos)
  end
  if self.sprite then
    self.sprite:draw(
      dt,
      self.pos
      -- self.body and 'cx: ' .. self.body.min_cx .. '\ncy: ' .. self.body.min_cy
    )
  end
end

return Object
