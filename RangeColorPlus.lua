-- Use global saved variable from TOC file
if not RANGECOLORPLUS then
    RANGECOLORPLUS = { r = 0.85, g = 0, b = 0, a = 1.0 }
end

local function UpdateActionButtonRange(self)
    if self:IsForbidden() then return end

    local action = self.action
    if not action or action == 0 then return end

    local isUsable, notEnoughMana = IsUsableAction(action)
    local inRange = IsActionInRange(action)

    if inRange == false then
        self.icon:SetVertexColor(RANGECOLORPLUS.r, RANGECOLORPLUS.g, RANGECOLORPLUS.b, RANGECOLORPLUS.a)
    else
        self.icon:SetVertexColor(1, 1, 1, 1)
    end
end

-- Hook once into the main updater (no per-button hooks)
local hookedOnce = false
local function HookActionButtons()
    if hookedOnce then return end
    hooksecurefunc("ActionButton_OnUpdate", UpdateActionButtonRange)
    hookedOnce = true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RangeColorPlus" then
        RANGECOLORPLUS = _G.RANGECOLORPLUS or { r = 0.85, g = 0, b = 0, a = 1.0 }
    elseif event == "PLAYER_LOGOUT" then
        _G.RANGECOLORPLUS = RANGECOLORPLUS -- Ensure the global variable is stored
    elseif event == "PLAYER_LOGIN" then
        HookActionButtons()
    end
end)

-- Slash command to change color
SLASH_RANGECOLORPLUS1 = "/rcp"
SlashCmdList["RANGECOLORPLUS"] = function(msg)
    local r, g, b, a = msg:match("(%d+)%s+(%d+)%s+(%d+)%s*(%d*%.?%d*)")
    if r and g and b then
        local rDec, gDec, bDec = tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255
        local aDec = tonumber(a) ~= nil and tonumber(a) or 1.0 -- Keep alpha as is, default to 1 if not provided
        RANGECOLORPLUS.r, RANGECOLORPLUS.g, RANGECOLORPLUS.b, RANGECOLORPLUS.a = rDec, gDec, bDec, aDec
        print("RangeColorPlus color updated: ", tonumber(r), tonumber(g), tonumber(b), aDec)
    end

    local rInt = math.floor(RANGECOLORPLUS.r * 255)
    local gInt = math.floor(RANGECOLORPLUS.g * 255)
    local bInt = math.floor(RANGECOLORPLUS.b * 255)
    print("RangeColorPlus current color:", rInt, ",", gInt, ",", bInt, ",", RANGECOLORPLUS.a)
    print("Update color with: /rcp <R> <G> <B> [A] (RGB values from 0-255, A from 0.0-1.0, A is optional)")
end
