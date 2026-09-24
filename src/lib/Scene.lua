local World = require('src.lib.World')

---@class Scene
---@field new function Scene constructor
---@field init function What to run at the start of the Scene
---@field update fun(self: Scene, dt: number) What to run each tick
---@field draw fun(self: Scene, dt: number) What to draw each tick
---@field world World Scene's world
local Scene = {}
Scene.__index = Scene

---@return Scene
function Scene:new()
  local instance = setmetatable({}, self)
  instance.world = World:new()
  return instance
end

function Scene:init() end
---@param dt number Time since last execution
function Scene:update(dt)
  self.world:update(dt)
end
---@param dt number Time since last execution
function Scene:draw(dt) end

return Scene
