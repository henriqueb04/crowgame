---@class Body : Component
---@field radius number Radius of the collider
---@field intangible boolean If the body should phase-through
---@field border integer The color of the border to display (or 0 if shouldn't render)
---@field vel [number, number] Radius of the collider
---@field cells string[] Radius of the collider
---@field min_cx? integer Minimum world cell on axis x
---@field min_cy? integer Minimum world cell on axis x
---@field max_cx? integer Minimum world cell on axis x
---@field max_cy? integer Minimum world cell on axis x
---@field on_collide? fun(self: Object, obj: Object) Function called on collision
---@field collide fun(self: Body, obj: Object, obj2: Object) Function called on collision
local Body = {}
Body.__index = Body

---@return Body
---@param radius number Radius size for body
---@param on_collide? fun(self: Body, obj: Object) Function called on collision
function Body:new(radius, on_collide)
  local instance = setmetatable({}, self)
  instance.radius = radius
  instance.vel = { 0, 0 }
  instance.cells = {}
  instance.border = 3
  instance.on_collide = on_collide
  return instance
end

---@param obj Object Body's object
---@param obj2 Object Collided object
function Body:collide(obj, obj2)
  if self.on_collide then
    self.on_collide(obj, obj2)
  end
end

---@param pos [number, number]
function Body:draw(pos)
  if self.border then
    local camera = State.camera
    -- gfx.circ(obj.pos[1] - camera.pos[1] + usagi.GAME_W / 2, obj.pos[2] - State.camera.pos[2] + usagi.GAME_H / 2, 2, 2)
    gfx.circ(camera:world_x(pos[1]), camera:world_y(pos[2]), self.radius, self.border)
  end
end

return Body
