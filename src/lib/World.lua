---@class World
---@field private objs Object[] | { size: integer } Objects managed by the world
---@field private physics_grid table<string, { [Object]: boolean, size: number }> Objects with bodies that collide
local World = {}
World.__index = World

---@return World
function World:new()
  local instance = setmetatable({}, self)
  instance.objs = { size = 0 }
  setmetatable(instance.objs, { __len = function (t) return t.size end })
  instance.physics_grid = {}
  return instance
end

---@param cx number
---@param cy number
---@return string
local function to_cell(cx, cy)
  return math.floor(cx) .. ',' .. math.floor(cy)
end

---@param obj Object Object to add to world
function World:add(obj)
  if obj.scene_id then
    print("WARN: Tried to add element to another scene")
  end
  local id = self.objs.size + 1
  self.objs[id] = obj
  self.objs.size += 1
  obj.scene_id = id
  if obj.body ~= nil then
    self:physics_insert(obj)
  end
end

---@param obj Object Scene id of object to remove
function World:remove(obj)
  local id = obj.scene_id
  if not id then
    print("ERROR: Tried to remove object without id")
    return
  end
  if obj.body then
    self:physics_remove(obj)
  end
  local last_id = self.objs.size
  if id ~= last_id then
    local last_obj = self.objs[last_id]
    self.objs[id] = last_obj
    last_obj.scene_id = id
  end
  self.objs[last_id] = nil
  obj.scene_id = nil
  self.objs.size -= 1
end

---@param obj Object Object to add to physics grid
function World:physics_insert(obj)
  if not obj.body then
    return
  end
  local min_cx = math.floor((obj.pos[1] - obj.body.radius) / State.physics_grid_size)
  local min_cy = math.floor((obj.pos[2] - obj.body.radius) / State.physics_grid_size)
  local max_cx = math.floor((obj.pos[1] + obj.body.radius) / State.physics_grid_size)
  local max_cy = math.floor((obj.pos[2] + obj.body.radius) / State.physics_grid_size)
  ---@type [number,number][]
  local obj_cells = {}
  for cx = min_cx, max_cx do
    for cy = min_cy, max_cy do
      local cell = to_cell(cx, cy)
      if not self.physics_grid[cell] then
        self.physics_grid[cell] = { size = 0 }
      end
      self.physics_grid[cell][obj] = true
      table.insert(obj_cells, cell)
      self.physics_grid[cell].size += 1
    end
  end
  obj.body.cells = obj_cells
  obj.body.min_cx = min_cx
  obj.body.min_cy = min_cy
  obj.body.max_cx = max_cx
  obj.body.max_cy = max_cy
end

---@param obj Object Object to add to physics grid
function World:physics_remove(obj)
  if not obj.body or not obj.body.cells then
    return
  end
  for _, cell in ipairs(obj.body.cells) do
    ---@type Object?
    self.physics_grid[cell][obj] = nil
    self.physics_grid[cell].size -= 1
    if self.physics_grid[cell].size < 1 then
      self.physics_grid[cell] = nil
    end
  end
  obj.body.cells = {}
  obj.body.min_cx = nil
  obj.body.min_cy = nil
  obj.body.max_cx = nil
  obj.body.max_cy = nil
end

---@param dt number Delta time
function World:physics_update(dt)
  -- Movimentação
  for _, obj in ipairs(self.objs) do
    if obj.body then
      obj.pos[1] += obj.body.vel[1] * dt
      obj.pos[2] += obj.body.vel[2] * dt
    end
  end

  -- Detecção de colisão
  ---@type table<string, boolean>
  local visited = {}
  for _, cell_content in pairs(self.physics_grid) do
    for obj1, _ in pairs(cell_content) do
      if type(obj1) == 'table' then
        for obj2, _ in pairs(cell_content) do
          if type(obj2) == 'table' and obj1 ~= obj2 then
            local id1 = tostring(obj1)
            local id2 = tostring(obj2)
            local pair_id = id1 < id2 and (id1 .. id2) or (id2 .. id1)
            if not visited[pair_id] then
              local dist_x = obj2.pos[1] - obj1.pos[1]
              local dist_y = obj2.pos[2] - obj1.pos[2]
              local dist_sq = dist_x * dist_x + dist_y * dist_y
              local min_dist = obj1.body.radius + obj2.body.radius
              if dist_sq < (min_dist * min_dist) and dist_sq > 0 then
                local dist_h = math.sqrt(dist_sq)
                local depth = math.abs(obj2.body.radius - (dist_h - obj1.body.radius)) / 2
                local push = depth / 2
                local normal_x = dist_x / dist_h
                local normal_y = dist_y / dist_h

                -- Physics
                if not obj1.body.intangible and not obj2.body.intangible then
                  obj1.pos[1] -= normal_x * push
                  obj1.pos[2] -= normal_y * push
                  obj2.pos[1] += normal_x * push
                  obj2.pos[2] += normal_y * push
                end

                -- Collision detection
                obj1.body:collide(obj1, obj2)
                obj2.body:collide(obj2, obj1)
              end
            end
            visited[pair_id] = true
          end
        end
      end
    end
  end
end

function World:update(dt)
  for _, obj in ipairs(self.objs) do
    obj:update(dt)
    if obj.body then
      local min_cx = math.floor((obj.pos[1] - obj.body.radius) / State.physics_grid_size)
      local min_cy = math.floor((obj.pos[2] - obj.body.radius) / State.physics_grid_size)
      local max_cx = math.floor((obj.pos[1] + obj.body.radius) / State.physics_grid_size)
      local max_cy = math.floor((obj.pos[2] + obj.body.radius) / State.physics_grid_size)
      if
        obj.body.min_cx ~= min_cx
        or obj.body.min_cy ~= min_cy
        or obj.body.max_cx ~= max_cx
        or obj.body.max_cy ~= max_cy
      then
        self:physics_remove(obj)
        self:physics_insert(obj)
      end
    end
  end
  self:physics_update(dt)
end

---@param dt number Delta time
function World:draw(dt)
  local objs = self.objs
  local camera = State.camera
  ---@type integer[]
  local to_render = {}
  local rendered_entities = 0
  for i, obj in ipairs(self.objs) do
    local bounds = obj:visual_bounds()
    if camera:is_inside_bounds(bounds) then
      rendered_entities += 1
      to_render[rendered_entities] = i
      -- if State.dbg then
      --   gfx.rect(
      --     camera:world_x(bounds.left),
      --     camera:world_y(bounds.top),
      --     bounds.right - bounds.left,
      --     bounds.bottom - bounds.top,
      --     2
      --   )
      -- end
    end
  end
  table.sort(to_render, function(a, b)
    return objs[a].pos[2] < objs[b].pos[2]
  end)
  for i = 1, rendered_entities do
    objs[to_render[i]]:draw(dt)
  end
  if State.dbg then
    gfx.text('RE: ' .. rendered_entities, 0, 0, 3)
  end
end

return World
