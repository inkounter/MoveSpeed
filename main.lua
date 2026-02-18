local thisAddonName, ns = ...
local LibEditMode = LibStub("LibEditMode")

local frame = CreateFrame("Frame", "MoveSpeedFrame", UIParent)
frame:SetSize(40, 20)

local fontstring = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
fontstring:SetPoint("RIGHT")
fontstring:SetJustifyH("RIGHT")

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

local defaultPosition = {point = "RIGHT", x = 0, y = 0}

local function onPositionChanged(f, layoutName, point, x, y)
    MoveSpeedDB = MoveSpeedDB or {}
    MoveSpeedDB[layoutName] = MoveSpeedDB[layoutName] or {}
    MoveSpeedDB[layoutName].point = point
    MoveSpeedDB[layoutName].x = x
    MoveSpeedDB[layoutName].y = y
end

LibEditMode:RegisterCallback(
    "layout",
    function(layoutName)
        local pos = MoveSpeedDB and MoveSpeedDB[layoutName] or defaultPosition
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    end
)

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript(
    "OnEvent",
    function(_frame, _event, addonName)
        if addonName == thisAddonName then
            frame:UnregisterEvent("ADDON_LOADED")

            LibEditMode:AddFrame(frame, onPositionChanged, defaultPosition)

            C_Timer.NewTicker(0.1, updateSpeed)
        end
    end
)
