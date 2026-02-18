local thisAddonName, ns = ...
local LibEditMode = LibStub("LibEditMode")

local frame = CreateFrame("Frame", "MoveSpeedFrame", UIParent)
frame:SetSize(40, 20)

local fontstring = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")

-- Edit Mode settings

local defaultPosition = {point = "CENTER", x = 0, y = 0}
local defaultSettings = {
    font = [[Fonts\FRIZQT__.TTF]],
    size = 12,
    flags = "OUTLINE",
    justifyH = "RIGHT"
}

local function updateFont(layoutName)
    local db = MoveSpeedDB and MoveSpeedDB[layoutName] or defaultSettings
    local font = db.font or defaultSettings.font
    local size = db.size or defaultSettings.size
    local flags = db.flags or defaultSettings.flags
    local justifyH = db.justifyH or defaultSettings.justifyH

    fontstring:SetFont(font, size, flags)
    fontstring:SetJustifyH(justifyH)
    fontstring:ClearAllPoints()
    fontstring:SetPoint(justifyH)
end

local function onPositionChanged(f, layoutName, point, x, y)
    MoveSpeedDB = MoveSpeedDB or {}
    MoveSpeedDB[layoutName] = MoveSpeedDB[layoutName] or {}
    MoveSpeedDB[layoutName].point = point
    MoveSpeedDB[layoutName].x = x
    MoveSpeedDB[layoutName].y = y
end

local function getVal(layoutName, key)
    if MoveSpeedDB and MoveSpeedDB[layoutName] and MoveSpeedDB[layoutName][key] ~= nil then
        return MoveSpeedDB[layoutName][key]
    end
    return defaultSettings[key]
end

local function setVal(layoutName, key, value)
    MoveSpeedDB = MoveSpeedDB or {}
    MoveSpeedDB[layoutName] = MoveSpeedDB[layoutName] or {}
    MoveSpeedDB[layoutName][key] = value
    updateFont(layoutName)
end

LibEditMode:RegisterCallback(
    "layout",
    function(layoutName)
        local pos = MoveSpeedDB and MoveSpeedDB[layoutName] or defaultPosition
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
        updateFont(layoutName)
    end
)

local settings = {
    {
        name = "Font",
        kind = LibEditMode.SettingType.Dropdown,
        default = defaultSettings.font,
        get = function(layoutName) return getVal(layoutName, "font") end,
        set = function(layoutName, value) setVal(layoutName, "font", value) end,
        values = {
            {text = "Friz Quadrata", value = [[Fonts\FRIZQT__.TTF]]},
            {text = "Arial Narrow", value = [[Fonts\ARIALN.TTF]]},
            {text = "Skurri", value = [[Fonts\skurri.ttf]]},
            {text = "Morpheus", value = [[Fonts\MORPHEUS.ttf]]},
        }
    },
    {
        name = "Font Size",
        kind = LibEditMode.SettingType.Slider,
        default = defaultSettings.size,
        get = function(layoutName) return getVal(layoutName, "size") end,
        set = function(layoutName, value) setVal(layoutName, "size", value) end,
        minValue = 8,
        maxValue = 72,
        valueStep = 1,
    },
    {
        name = "Font Flags",
        kind = LibEditMode.SettingType.Dropdown,
        default = defaultSettings.flags,
        get = function(layoutName) return getVal(layoutName, "flags") end,
        set = function(layoutName, value) setVal(layoutName, "flags", value) end,
        values = {
            {text = "None", value = ""},
            {text = "Outline", value = "OUTLINE"},
            {text = "Thick Outline", value = "THICKOUTLINE"},
            {text = "Monochrome", value = "MONOCHROME"},
        }
    },
    {
        name = "Alignment",
        kind = LibEditMode.SettingType.Dropdown,
        default = defaultSettings.justifyH,
        get = function(layoutName) return getVal(layoutName, "justifyH") end,
        set = function(layoutName, value) setVal(layoutName, "justifyH", value) end,
        values = {
            {text = "Left", value = "LEFT"},
            {text = "Center", value = "CENTER"},
            {text = "Right", value = "RIGHT"},
        }
    }
}

-- Speed logic

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

-- Event handling

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript(
    "OnEvent",
    function(_frame, _event, addonName)
        if addonName == thisAddonName then
            frame:UnregisterEvent("ADDON_LOADED")

            LibEditMode:AddFrame(frame, onPositionChanged, defaultPosition)
            LibEditMode:AddFrameSettings(frame, settings)

            C_Timer.NewTicker(0.1, updateSpeed)
        end
    end
)
