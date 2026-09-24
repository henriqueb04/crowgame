local Object = require('src.lib.Object')
local Sprite = require('src.lib.Sprite')
local Body = require('src.lib.Body')
local Health = require('src.lib.Health')

---@class Player: Object
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Object })

Player.animations = {
  idle = { duration = 1, start = 1, length = 1 },
}

---@return Player
function Player:new(x, y)
  local instance = Object.new(
    self,
    x,
    y,
    Sprite:new({ 1, 1 }, 'idle', self.animations, { -8, -16 }),
    Body:new(7),
    Health:new(5, 5, 0.8, 3)
  )
  instance.tag = "Player"
  instance.body.border = 4
  instance.body.on_collide = self.on_collide
  return instance --[[@as Player]]
end

local speed = 80
local camera_offset = 15
local camera_speed = 15

---@param dt number Delta time
function Player:update(dt)
  Object.update(self, dt)
  local x_axis = 0
  local y_axis = 0
  if input.held(input.LEFT) then
    x_axis -= 1
  end
  if input.held(input.RIGHT) then
    x_axis += 1
  end
  if input.held(input.UP) then
    y_axis -= 1
  end
  if input.held(input.DOWN) then
    y_axis += 1
  end
  local dir = { x = x_axis, y = y_axis }
  dir = util.vec_normalize(dir)
  self.body.vel[1] = dir.x * speed
  self.body.vel[2] = dir.y * speed
  if x_axis > 0 then
    self.sprite.flip_x = false
  elseif x_axis < 0 then
    self.sprite.flip_x = true
  end
  State.camera.pos[1] = util.lerp(State.camera.pos[1], self.pos[1] + x_axis * camera_offset, camera_speed * dt)
  State.camera.pos[2] = util.lerp(State.camera.pos[2], self.pos[2] + y_axis * camera_offset, camera_speed * dt)
end

function Player:draw(dt)
  Object.draw(self, dt)
  for i = 0, self.health.hp - 1 do
    gfx.rect(5 + i * 25, 5, 20, 20, 4)
  end
end

function Player:on_collide(obj)
  if obj.tag == "Zombie" then
    self.health:hit(1)
  end
end

return Player
