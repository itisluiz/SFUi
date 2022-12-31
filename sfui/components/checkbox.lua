local Checkbox = class("Checkbox", SFUi.component)

function Checkbox:initialize(parent, pos, size, text, checked, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.text = text
    self.checked = checked ~= nil and checked or false
    self.callback = callback
end

function Checkbox:render(cursor, action)
    render.setColor(self.hover and self.palette.contrast or self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.action.held and self.palette.highlight or self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    if self.checked then
        render.setColor(self.palette.highlight)
        render.drawRectFast(self.mins.x + self.size.x * 0.2, self.mins.y + self.size.y * 0.2, self.size.x * 0.6, self.size.y * 0.6)
    end

    render.setColor(self.action.held and self.palette.highlight or self.palette.foreground)
    render.drawSimpleText(self.maxs.x + 5, self.center.y, self.text, nil, TEXT_ALIGN.CENTER)

    if self.action.click then
        self.checked = not self.checked
        if self.callback then
            self.callback(self.checked)
        end
    end

    SFUi.component.render(self, cursor, action)
end

SFUi.static.checkbox = Checkbox