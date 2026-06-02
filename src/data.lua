-- luacheck: globals ScreenData LootSetData

local data = {}

data.weapons = {
    { id = "WeaponStaffSwing", prefix = "Staff", label = "Staff" },
    { id = "WeaponDagger", prefix = "Dagger", label = "Blades" },
    { id = "WeaponAxe", prefix = "Axe", label = "Axe" },
    { id = "WeaponTorch", prefix = "Torch", label = "Torch" },
    { id = "WeaponLob", prefix = "Lob", label = "Skull" },
    { id = "WeaponSuit", prefix = "Suit", label = "Coat" },
}

data.hammerData = {}
data.weaponLabels = {}
data.weaponDrawOrder = {}
data.aspectLabels = {}
data.weaponAspectMapping = {}

local function copyList(list)
    local copy = {}
    for _, value in ipairs(list or {}) do
        copy[#copy + 1] = value
    end
    return copy
end

local function getGameAspectOrder()
    local screenData = ScreenData and ScreenData.WeaponUpgradeScreen
    return screenData and screenData.DisplayOrder or {}
end

local function getGameHammerTraits()
    local lootSetData = LootSetData and LootSetData.Loot
    local weaponUpgrade = lootSetData and lootSetData.WeaponUpgrade
    return weaponUpgrade and weaponUpgrade.Traits or {}
end

local function getAspectLabel(aspectName)
    local localized = game and game.GetDisplayName and game.GetDisplayName({ Text = aspectName }) or nil
    return localized or aspectName
end

local function buildHammerData(values)
    local hammerData = {
        values = values,
        valueIndex = {},
        displayValues = {},
    }
    for index, value in ipairs(values) do
        hammerData.valueIndex[value] = index
        if value == "" then
            hammerData.displayValues[value] = "None (Random)"
        else
            hammerData.displayValues[value] = value
        end
    end
    return hammerData
end

local function collectHammersForPrefix(allHammers, prefix)
    local hammers = { "" }
    for _, hammerName in ipairs(allHammers or {}) do
        if string.find(hammerName, prefix, 1, true) == 1 then
            hammers[#hammers + 1] = hammerName
        end
    end
    return hammers
end

local function buildDerivedCatalog()
    local aspectOrder = getGameAspectOrder()
    local allHammers = getGameHammerTraits()

    for _, weapon in ipairs(data.weapons) do
        local hammerData = buildHammerData(collectHammersForPrefix(allHammers, weapon.prefix))
        data.hammerData[weapon.id] = hammerData
        data.weaponLabels[weapon.id] = weapon.label
        data.weaponDrawOrder[#data.weaponDrawOrder + 1] = weapon.id

        local aspects = copyList(aspectOrder[weapon.id])
        data.weaponAspectMapping[weapon.id] = aspects
        for _, aspectName in ipairs(aspects) do
            data.aspectLabels[aspectName] = getAspectLabel(aspectName)
            data.hammerData[aspectName] = hammerData
        end
    end
end

function data.buildStorage()
    local storage = {}

    for _, weaponName in ipairs(data.weaponDrawOrder) do
        for _, aspectName in ipairs(data.weaponAspectMapping[weaponName] or {}) do
            table.insert(storage, {
                type = "string",
                alias = aspectName,
                default = "",
            })
        end
    end

    return storage
end

buildDerivedCatalog()

return data
