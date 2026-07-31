-- Use global saved variable from TOC file
RANGECOLORPLUS = RANGECOLORPLUS or { r = 0.85, g = 0, b = 0, a = 1.0 }

local function RestoreDefaultColor(button)
    if not button or not button.icon then return end
    button.icon:SetVertexColor(60, 60, 60, 1)
end

local function ApplyColor(button, outOfRange)
    if not button or button:IsForbidden() then return end
    if not button.icon then return end

    if outOfRange then
        button.icon:SetVertexColor(RANGECOLORPLUS.r, RANGECOLORPLUS.g, RANGECOLORPLUS.b, RANGECOLORPLUS.a)
        button.__RangeColorPlus_OutOfRange = true
    else
        RestoreDefaultColor(button)
        button.__RangeColorPlus_OutOfRange = false
    end
end

local function ReapplyIfNeeded(button)
    if button and button.__RangeColorPlus_OutOfRange and button.icon then
        button.icon:SetVertexColor(RANGECOLORPLUS.r, RANGECOLORPLUS.g, RANGECOLORPLUS.b, RANGECOLORPLUS.a)
    end
end

local function UpdateActionButtonRange(button)
    if not button or button:IsForbidden() then return end
    if not button.action or button.action == 0 then return end
    if not button.icon then return end

    local inRange = IsActionInRange(button.action)
    ApplyColor(button, inRange == false)
end

local hookedOnce = false
local function HookRangeUpdates()
    if hookedOnce then return end

    -- Dragonflight / 2.5.5 path
    if type(_G.ActionButton_UpdateRangeIndicator) == "function" then
        hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
            if checksRange == false then
                ApplyColor(self, false)
                return
            end
            ApplyColor(self, inRange == false)
        end)
    else
        -- Classic fallback
        hooksecurefunc("ActionButton_OnUpdate", UpdateActionButtonRange)
    end

    -- Hook mouse leave per-button (NOT a global function)
    for i = 1, 12 do
        local buttons = {
            _G["ActionButton" .. i],
            _G["MultiBarBottomLeftButton" .. i],
            _G["MultiBarBottomRightButton" .. i],
            _G["MultiBarRightButton" .. i],
            _G["MultiBarLeftButton" .. i]
        }
        for _, b in ipairs(buttons) do
            if b and b.HookScript then
                b:HookScript("OnLeave", ReapplyIfNeeded)
            end
        end
    end

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
        _G.RANGECOLORPLUS = RANGECOLORPLUS
    elseif event == "PLAYER_LOGIN" then
        HookRangeUpdates()
    end
end)

-- Slash command to change color
SLASH_RANGECOLORPLUS1 = "/rcp"
SlashCmdList["RANGECOLORPLUS"] = function(msg)
    local r, g, b, a = msg:match("(%d+)%s+(%d+)%s+(%d+)%s*(%d*%.?%d*)")
    if r and g and b then
        local rDec, gDec, bDec = tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255
        local aDec = tonumber(a) ~= nil and tonumber(a) or 1.0
        RANGECOLORPLUS.r, RANGECOLORPLUS.g, RANGECOLORPLUS.b, RANGECOLORPLUS.a = rDec, gDec, bDec, aDec
        print("RangeColorPlus color updated:", tonumber(r), tonumber(g), tonumber(b), aDec)
    end

    local rInt = math.floor(RANGECOLORPLUS.r * 255)
    local gInt = math.floor(RANGECOLORPLUS.g * 255)
    local bInt = math.floor(RANGECOLORPLUS.b * 255)
    print("RangeColorPlus current color:", rInt, ",", gInt, ",", bInt, ",", RANGECOLORPLUS.a)
    print("Update color with: /rcp <R> <G> <B> [A] (RGB 0-255, A 0.0-1.0)")
end
