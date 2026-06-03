local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
local chalk = mods['SGG_Modding-Chalk']
local reload = mods['SGG_Modding-ReLoad']
---@module "adamant-ModpackLib"
---@type AdamantModpackLib
local lib = mods['adamant-ModpackLib']

local config = chalk.auto('config.lua')

local PACK_ID = "speedrun"
local MODULE_ID = "SelectFirstHammer"
local PLUGIN_GUID = _PLUGIN.guid

local loader = reload.auto_single()

local function init()
    import_as_fallback(rom.game)
    local data = import("data.lua")
    local logic = import("logic.lua")
    local ui = import("ui.lua")

    local module = lib.createModule({
        pluginGuid = PLUGIN_GUID,
        config = config,
        id = MODULE_ID,
        name = "Select First Hammer",
        shortName = "First Hammer",
        tooltip = "Select the guaranteed first hammer for each weapon aspect.",
        modpack = PACK_ID,
    })
    if not module then
        return
    end

    logic.localizeHammerLabels(data.weaponDrawOrder, data.hammerData)

    module.data.define(data.buildStorage())
    ui.attach(module, {
        hammerData = data.hammerData,
        weaponLabels = data.weaponLabels,
        weaponDrawOrder = data.weaponDrawOrder,
        aspectLabels = data.aspectLabels,
        weaponAspectMapping = data.weaponAspectMapping,
    }, logic.getEquippedAspect)
    module.fallbackUi.attachGuiOnce(function(fallbackUi)
        rom.gui.add_imgui(fallbackUi.renderWindow)
        rom.gui.add_to_menu_bar(fallbackUi.addMenuBar)
    end)
    logic.attach(module, data.hammerData)
    if not module.activate() then
        return
    end
end

modutil.once_loaded.game(function()
    loader.load(nil, init)
end)
