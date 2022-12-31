local Progress = class("Progress", SFUi.component)

function Progress:initialize(parent, pos, size, value)
    SFUi.component.initialize(self, parent, pos, size)
    self.value = value
end

function Progress:render(cursor, action)
    render.setColor(self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.palette.highlight)
    if self.value then
        render.drawRectFast(self.mins.x, self.mins.y, self.size.x * math.clamp(self.value, 0, 1), self.size.y)
    else
        local duration = 1
        local size = self.size.x / 3
        local t_phase = (timer.realtime() % 1) / duration
        local t_start = self.mins.x + (self.size.x * t_phase)
        local t_size = math.min(self.maxs.x - t_start, size)

        render.drawRectFast(t_start, self.mins.y, t_size, self.size.y)
        if t_size < size then
            render.drawRectFast(self.mins.x, self.mins.y, size - t_size, self.size.y)
        end
    end

    render.setColor(self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    SFUi.component.render(self, cursor, action)
end

SFUi.static.progress = Progress