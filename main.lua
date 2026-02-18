local thisAddonName, ns = ...

local frame = CreateFrame("Frame", nil, UIParent)
local fontstring = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
fontstring:SetPoint("CENTER", UIParent, "CENTER")

local function getSpeed()
    local isGliding, _, speed = C_PlayerInfo.GetGlidingInfo()
    if not isGliding then
        speed = GetUnitSpeed("player")
    end

    return speed / 7 * 100
end

local function updateSpeed()
    fontstring:SetFormattedText("%.0f%%", getSpeed())
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript(
    "OnEvent",
    function(_frame, _event, addonName)
        if addonName == thisAddonName then
            frame:UnregisterEvent("ADDON_LOADED")

            C_Timer.NewTicker(0.1, updateSpeed)
        end
    end
)
