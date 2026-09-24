local Object = require('src.lib.Object')
local Sprite = require('src.lib.Sprite')
local Body = require('src.lib.Body')

---@class Zombie: Object
local Zombie = {}
Zombie.__index = Zombie
setmetatable(Zombie, { __index = Object })

Zombie.animations = {
  walk = { duration = 1.5, start = 21, length = 2 },
}

---@return Zombie
function Zombie:new(x, y)
  local sprite = Sprite:new({ 1, 2 }, 'walk', self.animations, { -12, -32 })
  local instance = Object.new(self, x, y, sprite)
  instance.tag = "Zombie"
  instance.body = Body:new(9)
  return instance --[[@as Zombie]]
end

local speed = 30

function Zombie:update(dt)
  Object.update(self, dt)
  if State.player then
    local normal = util.vec_normalize({
      x = State.player.pos[1] - self.pos[1],
      y = State.player.pos[2] - self.pos[2],
    })
    self.body.vel[1] = normal.x * speed
    self.body.vel[2] = normal.y * speed
    if self.body.vel[1] < 0 then
      self.sprite.flip_x = false
    elseif self.body.vel[1] > 0 then
      self.sprite.flip_x = true
    end
  end
end

return Zombie
