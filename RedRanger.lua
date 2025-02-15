local RedRangerDB = RedRangerDB or { r = 0.85, g = 0, b = 0 } -- Default Red

local function UpdateActionButtonRange(self)
    if self:IsForbidden() then return end
    
    local action = self.action
    if not action or action == 0 then return end
    
    local isUsable, notEnoughMana = IsUsableAction(action)
    local inRange = IsActionInRange(action)
    
    if inRange == false then
        self.icon:SetVertexColor(RedRangerDB.r, RedRangerDB.g, RedRangerDB.b) -- Use user-selected color
    else
        self.icon:SetVertexColor(1, 1, 1) -- Normal color when usable and in range
    end
end

local function HookActionButtons()
    for i = 1, 120 do -- Covers all action bar slots
        local button = _G["ActionButton" .. i] or _G["MultiBarBottomLeftButton" .. i] or _G["MultiBarBottomRightButton" .. i] or _G["MultiBarRightButton" .. i] or _G["MultiBarLeftButton" .. i]
        if button and button.icon then
            hooksecurefunc("ActionButton_OnUpdate", function(self) UpdateActionButtonRange(self) end)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        HookActionButtons()
    end
end)

-- Slash command to change color
SLASH_REDRANGER1 = "/rr"
SlashCmdList["REDRANGER"] = function(msg)
    local r, g, b = msg:match("(%d+)%s+(%d+)%s+(%d+)")
    if r and g and b then
        r, g, b = tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255
        RedRangerDB.r, RedRangerDB.g, RedRangerDB.b = r, g, b
        print("RedRanger color updated: ", r, g, b)
    else
        print("Adjust color using: /rr <R> <G> <B> (values from 0-255)")
    end
end
