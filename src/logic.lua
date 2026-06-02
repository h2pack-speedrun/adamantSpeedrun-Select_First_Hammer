local module = {}

function module.localizeHammerLabels(weaponDrawOrder, hammerDataByWeapon)
    for _, weaponName in ipairs(weaponDrawOrder) do
        local hammerData = hammerDataByWeapon[weaponName]
        for _, internalString in ipairs(hammerData.values) do
            if internalString ~= "" then
                local traitData = TraitData and TraitData[internalString] or nil
                local textKey = traitData and traitData.Name or internalString
                local localizedName = game.GetDisplayName({ Text = textKey })
                hammerData.displayValues[internalString] = localizedName or internalString
            end
        end
    end
end

function module.getEquippedAspect()
    return CurrentRun and CurrentRun.Hero
        and CurrentRun.Hero.SlottedTraits and CurrentRun.Hero.SlottedTraits.Aspect
        or "BaseStaffAspect"
end

local hasForcedHammerThisRun = false

local function normalizeDesiredHammer(hammerDataByAspect, aspectName, value)
    if value == nil or value == "" then
        return ""
    end
    local hammerData = hammerDataByAspect and hammerDataByAspect[aspectName] or nil
    if hammerData and hammerData.valueIndex and hammerData.valueIndex[value] then
        return value
    end
    return ""
end

function module.registerHooks(moduleRef, hammerDataByAspect)
    moduleRef.hooks.wrap("StartNewRun", function(host, _, baseFunc, prevRun, args)
        if host.isEnabled() then
            hasForcedHammerThisRun = false
        end
        return baseFunc(prevRun, args)
    end)

    moduleRef.hooks.wrap("SetTraitsOnLoot", function(host, runtime, baseFunc, lootData, args)
        baseFunc(lootData, args)

        if not host.isEnabled() then return end
        if lootData.Name ~= "WeaponUpgrade" or hasForcedHammerThisRun then return end

        local currentWeapon = module.getEquippedAspect()
        local desiredHammer = normalizeDesiredHammer(
            hammerDataByAspect,
            currentWeapon,
            runtime.data.read(currentWeapon)
        )

        if desiredHammer and desiredHammer ~= "" then
            local traitData = TraitData[desiredHammer]
            if traitData and IsTraitEligible(traitData, args) then
                lootData.UpgradeOptions = {
                    { ItemName = desiredHammer, Type = "Trait" }
                }
            end
        end
    end)

    moduleRef.hooks.wrap("AddTraitToHero", function(host, runtime, baseFunc, args)
        args = args or {}
        if not host.isEnabled() then return baseFunc(args) end

        local traitName = args.TraitData and args.TraitData.Name
        if traitName then
            local currentWeapon = module.getEquippedAspect()
            local desiredHammer = normalizeDesiredHammer(
                hammerDataByAspect,
                currentWeapon,
                runtime.data.read(currentWeapon)
            )
            if desiredHammer == traitName then
                hasForcedHammerThisRun = true
            end
        end

        return baseFunc(args)
    end)
end

function module.attach(moduleRef, hammerDataByAspect)
    module.registerHooks(moduleRef, hammerDataByAspect)
end

return module
