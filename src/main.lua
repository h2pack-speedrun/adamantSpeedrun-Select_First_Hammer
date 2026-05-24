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
local MODULE_ID = "FirstHammer"
local PLUGIN_GUID = _PLUGIN.guid

local loader = reload.auto_single()

local function init()
    import_as_fallback(rom.game)
    local data = import("data.lua")
    local logic = import("logic.lua").bind(data)
    local ui = import("ui.lua").bind(data, logic)

    local host, store = lib.createModule({
        pluginGuid = PLUGIN_GUID,
        config = config,
        id = MODULE_ID,
        name = "Hammer Selection",
        shortName = "Hammer Selection",
        tooltip = "Select the guaranteed first hammer for each weapon aspect.",
        modpack = PACK_ID,
        storage = data.buildStorage(),
        drawTab = ui.drawTab,
        drawQuickContent = ui.drawQuickContent,
    })
    if not host then
        return
    end

    logic.localizeHammerLabels()

    host.fallbackUi.attachGuiOnce(function(fallbackUi)
        rom.gui.add_imgui(fallbackUi.renderWindow)
        rom.gui.add_to_menu_bar(fallbackUi.addMenuBar)
    end)
    logic.registerHooks(host, store)
    local ok = host.activate()
    if not ok then
        return
    end
end

modutil.once_loaded.game(function()
    loader.load(nil, init)
end)
