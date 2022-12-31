local Textbox = class("Textbox", SFUi.component)

function Textbox:initialize(parent, pos, size, hint, text, callback)
    SFUi.component.initialize(self, parent, pos, size)
    self.hint = hint or "Hover and chat"
    self.text = text or ""
    self.callback = callback
    self.active = false
    self.typing = false
    self.trimmed = {
        old = {
            hint = nil,
            text = nil
        },
        hint = nil,
        text = nil
    }
    self.hooks = {
        FinishChat = function() self.typing = false end,
        ChatTextChanged = function(txt) self.text = self.typing and txt or self.text end
    }
end

function Textbox:updateTrimmed()
    if not self.trimmed.hint or self.trimmed.old.hint ~= self.hint then
        self.trimmed.hint = self.hint:len() > 0 and self:trimText(self.hint) or ""
        self.trimmed.old.hint = self.hint
    end
    if not self.trimmed.text or self.trimmed.old.text ~= self.text then
        self.trimmed.text = self.text:len() > 0 and self:trimText(self.text) or ""
        self.trimmed.old.text = self.text
    end
end

function Textbox:render(cursor, action)
    self:updateTrimmed()
    local usehint = self.text:len() == 0

    render.setColor(self.hover and self.palette.contrast or self.palette.component)
    render.drawRectFast(self.mins.x, self.mins.y, self.size.x, self.size.y)

    render.setColor(self.active and self.typing and self.palette.highlight or self.palette.contrast)
    render.drawRectOutline(self.mins.x, self.mins.y, self.size.x, self.size.y)

    if not self.active and self.hover and player():isTyping() then
        hook.add("FinishChat", "sfui_textbox", self.hooks.FinishChat)
        hook.add("ChatTextChanged", "sfui_textbox", self.hooks.ChatTextChanged)
        self.typing = true
        self.active = true
        self.text = ""
    elseif self.active and (not self.hover or not player():isTyping()) then
        hook.remove("FinishChat", "sfui_textbox")
        hook.remove("ChatTextChanged", "sfui_textbox")
        self.active = false
        if self.callback then
            self.callback(self.text)
        end
    end

    render.setColor(usehint and self.palette.contrast or self.palette.foreground)
    render.drawSimpleText(self.mins.x + self.size.x * 0.05, self.center.y, (usehint and not self.hover) and self.trimmed.hint or self.trimmed.text, nil, TEXT_ALIGN.CENTER)

    SFUi.component.render(self, cursor, action) 
end

SFUi.static.textbox = Textbox