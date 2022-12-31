local Slider = class("Slider", SFUi.component)

function Slider:initialize(parent, pos, size, value, min, max, snap, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.value = value
    self.min = min
    self.max = max
    self.snap = snap
    self.callback = callback

end

function Slider:updateHover(cursor)
    SFUi.component.updateHover(self, cursor)
    if cursor and not self.hover then
        self.hover = cursor:getDistanceSqr(Vector(math.remap(self.value, self.min, self.max, self.mins.x, self.maxs.x), self.center.y)) < self.size.y * self.size.y
    end
end

function Slider:render(cursor, action)
    local valuesize = math.remap(self.value, self.min, self.max, 0, self.size.x)

    render.setColor(self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.palette.highlight)
    render.drawRectFast(self.mins.x, self.mins.y, valuesize, self.size.y)

    render.setColor(self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor((self.hover or self.action.held) and self.palette.contrast or self.palette.component)
    render.drawFilledCircle(self.mins.x + valuesize, self.center.y, self.size.y)

    if cursor and self.drag.delta then
        local value = math.clamp(math.remap(cursor.x, self.mins.x, self.maxs.x, self.min, self.max), self.min, self.max)  
        if self.snap then
            value = value - (value % self.snap)
        end
        if value ~= self.value then
            self.value = value

            if self.callback then
                self.callback(self.value)
            end   
        end

        render.setColor(self.palette.foreground)
        render.drawSimpleText(self.mins.x + valuesize, self.center.y + self.size.y, tostring(math.round(self.value, 1)),TEXT_ALIGN.CENTER, TEXT_ALIGN.TOP)
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.slider = Slider