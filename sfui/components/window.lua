local Window = class("Window", SFUi.component)

function Window:initialize(pos, size, title, draggable, closehides, callback)
    SFUi.component.initialize(self, nil, pos, size)
    self.title = title or "Window"
    self.draggable = draggable ~= nil and draggable or true
    self.closehides = closehides
    self.callback = callback
    self.barheight = 0
    self.barheight = 0
    self.dragging = false
    self.extrahover = {
        bar = false,
        close = false
    }

end

function Window:updateHover(cursor)
    SFUi.component.updateHover(self, cursor)
    self.extrahover.bar = self.hover and cursor.y < self.mins.y + self.barheight or false
    self.extrahover.close = (self.closehides ~= nil and self.extrahover.bar) and cursor.x > self.maxs.x - self.barheight or false
end

function Window:render(cursor, action)
    self.barheight = select(2, render.getTextSize(self.title))

    if self.action.click then
        if self.extrahover.close then
            if self.callback then
                self.callback()
            end
            if self.closehides then
                self.visible = false
            end
        elseif self.extrahover.bar and self.draggable then
            self.dragging = true
        end
    elseif not self.action.held then
        self.dragging = false
    end

    render.setColor(self.palette.background)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.dragging and self.palette.hover or self.palette.component)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.dragging and self.palette.hover or self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.barheight)

    render.setColor(self.palette.foreground)
    render.drawSimpleText(self.mins.x + 5, self.mins.y, self.title, TEXT_ALIGN.LEFT, TEXT_ALIGN.TOP)

    if self.closehides ~= nil then
        render.setColor((self.dragging or self.extrahover.close) and self.palette.hover or self.palette.component)
        render.drawRectFast(self.maxs.x - self.barheight, self.mins.y, self.barheight, self.barheight)

        render.setColor((self.extrahover.close and self.action.held) and self.palette.highlight or self.palette.foreground)
        render.drawLine(self.maxs.x - self.barheight * 0.75, self.mins.y + self.barheight * 0.25, self.maxs.x - self.barheight * 0.25, self.mins.y + self.barheight * 0.75)
        render.drawLine(self.maxs.x - self.barheight * 0.75, self.mins.y + self.barheight * 0.75, self.maxs.x - self.barheight * 0.25, self.mins.y + self.barheight * 0.25)
    end

    if self.dragging and self.drag.delta then
        self.pos = self.pos + self.drag.delta
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.window = Window