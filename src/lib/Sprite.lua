---@alias Animation {duration: number, start: integer, length: integer}

---@class Sprite : Component
---@field size [number, number]
---@field pos_offset [number, number]
---@field cur_animation string
---@field cur_frame integer
---@field flip_x boolean
---@field animations table<string, Animation>
---@field tinted number
---@field private tint_time number
---@field private tint_color integer
---@field vanish boolean
---@field private blink_time number
---@field private blink_time_elapsed number
---@field private timer number
local Sprite = {}
Sprite.__index = Sprite

---@param size [number, number]
---@param initial_animation string
---@param animations table<string, Animation>
---@param pos_offset? [number, number]
function Sprite:new(size, initial_animation, animations, pos_offset)
  local instance = setmetatable({}, self)
  instance.size = size
  instance.animations = animations
  instance.pos_offset = pos_offset or { 0, 0 }
  instance.flip_x = false
  self.tinted = 0
  self.tint_time = 0
  self.tint_color = 0
  self.vanish = false
  self.blink_time = 0
  self.blink_time_elapsed = 0
  instance:change_animation(initial_animation)
  return instance
end

function Sprite:on_message(message, ...)
  if message == 'took_damage' then
    self:tint(0.16, select(2, ...))
    self:blink(select(1, ...))
  end
end

---@param animation_name string
function Sprite:change_animation(animation_name)
  local animation = self.animations[animation_name]
  if animation ~= nil then
    self.cur_frame = animation.start
    self.cur_animation = animation_name
    self.timer = 0
  else
    print('ERROR: Tried to set animation ' .. animation_name .. '. But it does not exist!')
  end
end

---@param time number The amount of seconds to blink for
function Sprite:blink(time)
  self.blink_time = time
  self.blink_time_elapsed = 0
end

---@param time number The amount of seconds to tint for
---@param color integer The color the sprite should tint
function Sprite:tint(time, color)
  self.tint_time = time
  self.tint_color = color
end

---@param _dt number
---@param pos [number, number]
---@param dbg_info? string
function Sprite:draw(_dt, pos, dbg_info)
  local animation = self.animations[self.cur_animation]
  if animation and not self.vanish then
    local spr_start = animation.start + self.cur_frame * self.size[1]
    local start_x = pos[1] + self.pos_offset[1]
    local start_y = pos[2] + self.pos_offset[2]
    if self.flip_x then
      local w = self.size[1] * State.sprite_grid_size
      local right_size = w + self.pos_offset[1]
      start_x = pos[1] - right_size
    end
    local spr_x_start = 0
    local spr_x_end = self.size[1] - 1
    if self.flip_x then
      spr_x_start = self.size[1] - 1
      spr_x_end = 0
    end
    for dy = 0, self.size[2] - 1 do
      for dx = spr_x_start, spr_x_end do
        gfx.spr_ex(
          spr_start + dx + State.sprite_sheet_len * dy,
          start_x + dx * usagi.SPRITE_SIZE - State.camera.pos[1] + usagi.GAME_W / 2,
          start_y + dy * usagi.SPRITE_SIZE - State.camera.pos[2] + usagi.GAME_H / 2,
          self.flip_x,
          false,
          0,
          self.tinted,
          1
        )
      end
    end
    if State.dbg and dbg_info then
      gfx.text_ex(
        dbg_info,
        start_x - State.camera.pos[1] + usagi.GAME_W / 2,
        start_y - State.camera.pos[2] + usagi.GAME_H / 2,
        1,
        0,
        3,
        1
      )
    end
  end
end

---@param dt number
function Sprite:update(dt)
  local animation = self.animations[self.cur_animation]
  if animation ~= nil then
    local time_per_frame = animation.duration / animation.length
    self.timer += dt
    if self.timer > time_per_frame then
      self.cur_frame += 1
      self.timer %= time_per_frame
    end
    self.cur_frame %= animation.length
    if self.tint_time > 0 then
      self.tinted = self.tint_color
      self.tint_time -= dt
    else
      self.tinted = 0
    end
    if self.blink_time_elapsed < self.blink_time then
      self.vanish = math.cos(self.blink_time_elapsed * 20) + 0.35 > 0
      self.blink_time_elapsed += dt
    else
      self.vanish = false
    end
  end
end

return Sprite
