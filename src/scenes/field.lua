local Scene = require('src.lib.Scene')
local Player = require('src.objects.Player')
local Zombie = require('src.objects.Zombie')

---@class FieldScene: Scene
local FieldScene = {}
FieldScene.__index = FieldScene
setmetatable(FieldScene, { __index = Scene })

function FieldScene:new()
  ---@type FieldScene
  local instance = Scene.new(self)
  local player = Player:new(1, 1)
  State.player = player
  local zombie1 = Zombie:new(48, 48)
  instance.world:add(zombie1)
  instance.world:add(Zombie:new(128, 48))
  instance.world:add(player)
  return instance
end

function FieldScene:draw(dt)
  gfx.clear(1)
  self.world:draw(dt)
end

return FieldScene
