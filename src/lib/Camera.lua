---@class Camera
---@field pos [number, number]
local Camera = {}
Camera.__index = Camera

---@param x number Starting x coordinate
---@param y number Starting y coordinate
---@return Camera
function Camera:new(x, y)
  local instance = setmetatable({}, self)
  instance.pos = { x or 0, y or 0 }
  return instance
end

---@param pos [number, number] World to screen pos
---@return [number, number]
function Camera:world_pos(pos)
  return { self:world_x(pos[1]), self:world_y(pos[2]) }
end

---@param x number
---@return number
function Camera:world_x(x)
  return x - self.pos[1] + usagi.GAME_W / 2
end
---@param y number
---@return number
function Camera:world_y(y)
  return y - self.pos[2] + usagi.GAME_H / 2
end

---@param bounds { top: number, bottom: number, left: number, right: number }
---@return boolean
function Camera:is_inside_bounds(bounds)
  local left = self.pos[1] - usagi.GAME_W / 2
  local right = self.pos[1] + usagi.GAME_W / 2
  local top = self.pos[2] - usagi.GAME_H / 2
  local bottom = self.pos[2] + usagi.GAME_H / 2
  return bounds.top <= bottom and bounds.bottom >= top and bounds.left <= right and bounds.right >= left
end

return Camera
