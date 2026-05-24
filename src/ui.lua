local module = {}
local data = nil
local logic = nil

local LABEL_WIDTH = 180
local DROPDOWN_WIDTH = 400
local COLUMN_GAP = 12
local DROPDOWN_TOOLTIP = "Guaranteed first hammer for this aspect. Leave on None (Random) to keep vanilla behavior."
local dropdownOptsByAspect = {}

local function DrawAspectDropdown(draw, state, aspectName)
    local imgui = draw.imgui
    local hammerOptions = data.hammerData[aspectName]
    if not hammerOptions then
        return
    end
    local label = data.aspectLabels[aspectName] or aspectName
    local rowStartX = imgui.GetCursorPosX()

    imgui.AlignTextToFramePadding()
    imgui.Text(label)
    if imgui.IsItemHovered() then
        imgui.SetTooltip(DROPDOWN_TOOLTIP)
    end

    imgui.SameLine()
    imgui.SetCursorPosX(rowStartX + LABEL_WIDTH + COLUMN_GAP)
    draw.widgets.dropdown(state.get(aspectName), dropdownOptsByAspect[aspectName])
end

function module.drawTab(draw, state)
    local imgui = draw.imgui
    for _, weaponName in ipairs(data.weaponDrawOrder or {}) do
        if imgui.CollapsingHeader(data.weaponLabels[weaponName] or weaponName) then
            for _, aspectName in ipairs(data.weaponAspectMapping[weaponName] or {}) do
                DrawAspectDropdown(draw, state, aspectName)
            end
        end
    end
end

function module.drawQuickContent(draw, state)
    local currentAspect = logic.getEquippedAspect()
    DrawAspectDropdown(draw, state, currentAspect)
end

function module.bind(moduleData, moduleLogic)
    data = moduleData
    logic = moduleLogic
    dropdownOptsByAspect = {}
    for aspectName, hammerOptions in pairs(data.hammerData or {}) do
        dropdownOptsByAspect[aspectName] = {
            label = "",
            values = hammerOptions.values,
            displayValues = hammerOptions.displayValues,
            controlWidth = DROPDOWN_WIDTH,
            tooltip = DROPDOWN_TOOLTIP,
        }
    end
    return module
end

return module
