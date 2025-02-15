local RedRangerDB = nil

local function UpdateActionButtonRange(self)
    if self:IsForbidden() then return end
    
    local action = self.action
    if not action or action == 0 then return end
    
    local isUsable, notEnoughMana = IsUsableAction(action)
    local inRange = IsActionInRange(action)
    
    if inRange == false then
        self.icon:SetVertexColor(RedRangerDB.r, RedRangerDB.g, RedRangerDB.b, RedRangerDB.a) -- Use user-selected color
    else
        self.icon:SetVertexColor(1, 1, 1, 1) -- Normal color when usable and in range
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
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RedRanger" then
        if not REDRANGER_COLOR then
            REDRANGER_COLOR = { r = 0.85, g = 0, b = 0, a = 1.0 }
        end
        RedRangerDB = REDRANGER_COLOR
    elseif event == "PLAYER_LOGOUT" then
        REDRANGER_COLOR = RedRangerDB
    elseif event == "PLAYER_LOGIN" then
        HookActionButtons()
    end
end)
 
-- Slash command to change color
SLASH_REDRANGER1 = "/rr"
SlashCmdList["REDRANGER"] = function(msg)
    local r, g, b, a = msg:match("(%d+)%s+(%d+)%s+(%d+)%s*(%d*%.?%d*)")
    if r and g and b then
        local rDec, gDec, bDec = tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255
        local aDec = tonumber(a) and tonumber(a) or 1.0 -- Keep alpha as is, default to 1 if not provided
        RedRangerDB.r, RedRangerDB.g, RedRangerDB.b, RedRangerDB.a = rDec, gDec, bDec, aDec
        print("RedRanger color updated: ", tonumber(r), tonumber(g), tonumber(b), aDec)
    end
    
    local rInt = math.floor(RedRangerDB.r * 255)
    local gInt = math.floor(RedRangerDB.g * 255)
    local bInt = math.floor(RedRangerDB.b * 255)
    print("Current color: R=",rInt, " G=",gInt, " B=",bInt, " A=",RedRangerDB.a)
    print("Change color with /rr <R> <G> <B> [A] (RGB values from 0-255, A from 0.0-1.0, A is optional)")
end
