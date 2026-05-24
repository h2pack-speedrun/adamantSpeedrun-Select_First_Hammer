local module = {}
local data = nil

function module.localizeHammerLabels()
    for _, weaponName in ipairs(data.weaponDrawOrder) do
        local hammerData = data.hammerData[weaponName]
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

function module.registerHooks(host, store)
    host.hooks.wrap("StartNewRun", function(baseFunc, prevRun, args)
        if host.isEnabled() then
            hasForcedHammerThisRun = false
        end
        return baseFunc(prevRun, args)
    end)

    host.hooks.wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
        baseFunc(lootData, args)

        if not host.isEnabled() then return end
        if lootData.Name ~= "WeaponUpgrade" or hasForcedHammerThisRun then return end

        local currentWeapon = module.getEquippedAspect()
        local desiredHammer = store.read(currentWeapon)

        if desiredHammer and desiredHammer ~= "" then
            local traitData = TraitData[desiredHammer]
            if traitData and IsTraitEligible(traitData, args) then
                lootData.UpgradeOptions = {
                    { ItemName = desiredHammer, Type = "Trait" }
                }
            end
        end
    end)

    host.hooks.wrap("AddTraitToHero", function(baseFunc, args)
        args = args or {}
        if not host.isEnabled() then return baseFunc(args) end

        local traitName = args.TraitData and args.TraitData.Name
        if traitName then
            local currentWeapon = module.getEquippedAspect()
            local desiredHammer = store.read(currentWeapon)
            if desiredHammer == traitName then
                hasForcedHammerThisRun = true
            end
        end

        return baseFunc(args)
    end)
end

function module.bind(moduleData)
    data = moduleData
    return module
end

return module
