local Button = class("Button", SFUi.component)

function Button:initialize(parent, pos, size, text, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.text = text
    self.callback = callback
end

function Button:render(cursor, action)
    render.setColor(self.hover and self.palette.contrast or self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.action.held and self.palette.highlight or self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.action.held and self.palette.highlight or self.palette.foreground)
    render.drawSimpleText(self.center.x, self.center.y, self.text, TEXT_ALIGN.CENTER, TEXT_ALIGN.CENTER)

    if self.action.click and self.callback then
        self.callback()
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.button = Button