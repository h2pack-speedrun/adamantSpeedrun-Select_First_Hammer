local module = {}

local LABEL_WIDTH = 180
local DROPDOWN_WIDTH = 400
local COLUMN_GAP = 12
local DROPDOWN_TOOLTIP = "Guaranteed first hammer for this aspect. Leave on None (Random) to keep vanilla behavior."

local function buildDropdownOptions(hammerDataByAspect)
    local optsByAspect = {}
    for aspectName, hammerOptions in pairs(hammerDataByAspect or {}) do
        optsByAspect[aspectName] = {
            label = "",
            values = hammerOptions.values,
            displayValues = hammerOptions.displayValues,
            controlWidth = DROPDOWN_WIDTH,
            tooltip = DROPDOWN_TOOLTIP,
        }
    end
    return optsByAspect
end

local function DrawAspectDropdown(draw, state, catalog, dropdownOptsByAspect, aspectName)
    local imgui = draw.imgui
    local hammerOptions = catalog.hammerData[aspectName]
    if not hammerOptions then
        return
    end
    local label = catalog.aspectLabels[aspectName] or aspectName
    local rowStartX = imgui.GetCursorPosX()

    imgui.AlignTextToFramePadding()
    imgui.Text(label)
    if imgui.IsItemHovered() then
        imgui.SetTooltip(DROPDOWN_TOOLTIP)
    end

    imgui.SameLine()
    imgui.SetCursorPosX(rowStartX + LABEL_WIDTH + COLUMN_GAP)
    local field = state.get(aspectName)
    local currentValue = field:read()
    if currentValue ~= nil and currentValue ~= ""
        and hammerOptions.valueIndex and not hammerOptions.valueIndex[currentValue] then
        field:write("")
    end
    draw.widgets.dropdown(field, dropdownOptsByAspect[aspectName])
end

function module.drawTab(draw, state, catalog, dropdownOptsByAspect)
    local imgui = draw.imgui
    for _, weaponName in ipairs(catalog.weaponDrawOrder or {}) do
        if imgui.CollapsingHeader(catalog.weaponLabels[weaponName] or weaponName) then
            for _, aspectName in ipairs(catalog.weaponAspectMapping[weaponName] or {}) do
                DrawAspectDropdown(draw, state, catalog, dropdownOptsByAspect, aspectName)
            end
        end
    end
end

function module.drawQuickContent(draw, state, catalog, dropdownOptsByAspect, getEquippedAspect)
    local currentAspect = getEquippedAspect()
    DrawAspectDropdown(draw, state, catalog, dropdownOptsByAspect, currentAspect)
end

function module.attach(refModule, catalog, getEquippedAspect)
    local dropdownOptsByAspect = buildDropdownOptions(catalog.hammerData)
    refModule.ui.tab(function(_, ui)
        return module.drawTab(ui.draw, ui.data, catalog, dropdownOptsByAspect)
    end)
    refModule.ui.quickContent(function(_, ui)
        return module.drawQuickContent(ui.draw, ui.data, catalog, dropdownOptsByAspect, getEquippedAspect)
    end)
end

return module
