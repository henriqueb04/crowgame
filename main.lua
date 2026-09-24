local Camera = require('src.lib.Camera')
local FieldScene = require('src.scenes.field')

State = {}
State.sprite_sheet_len = 20
State.sprite_grid_size = 16
State.physics_grid_size = 32
---@type boolean
State.dbg = true
---@type Scene?
State.current_scene = nil
---@type Scene[]
State.scenes = { FieldScene }
State.camera = Camera:new(0, 0)

function _config()
  return { name = 'Crow Game', game_id = 'henriqueb04.crowgame' }
end

function _init()
  local field_scene = FieldScene:new()
  State.current_scene = field_scene
  State.current_scene:init()
end

function _update(dt)
  if State.current_scene then
    State.current_scene:update(dt)
  end
end

function _draw(dt)
  if State.current_scene then
    State.current_scene:draw(dt)
  end
end
