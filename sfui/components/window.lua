local Window = class("Window", SFUi.component)

function Window:initialize(pos, size, title, draggable)
    SFUi.component.initialize(self, nil, pos, size)
    self.title = title or "Window"
    self.draggable = draggable ~= nil and draggable or true
    self.barheight = 0

end

function Window:updateHover(cursor)
    SFUi.component.updateHover(self, cursor)
    self.hover = self.hover and cursor.y < self.mins.y + self.barheight  or false
end

function Window:render(cursor, action)
    self.barheight = select(2, render.getTextSize(self.title))
    local dragging = self.draggable and self.drag.delta

    render.setColor(self.palette.background)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(dragging and self.palette.hover or self.palette.component)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(dragging and self.palette.hover or self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.barheight)

    render.setColor(self.palette.foreground)
    render.drawSimpleText(self.mins.x + 5, self.mins.y, self.title, TEXT_ALIGN.LEFT, TEXT_ALIGN.TOP)
    
    if dragging then
        self.pos = self.pos + self.drag.delta
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.window = Window