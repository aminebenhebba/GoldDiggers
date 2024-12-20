GoldDiggers = LibStub("AceAddon-3.0"):NewAddon("GoldDiggers", "AceEvent-3.0" )

GoldDiggers.Config = {}
GoldDiggers.Helpers = {}

local Config = GoldDiggers.Config
local Helpers = GoldDiggers.Helpers

-- AddOn frames:
local mainUI, sessionUI


--------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------
-- player types
local PlayerType = {
    LEADER = 0,
    CLIENT = 1,
    BLASTER = 2,
}

-- Classes colors:
local classColor = {
    DEATHKNIGHT = "ffc41f3b",
    DRUID       = "ffff7d0a",
    HUNTER      = "ffabd473",
    MAGE        = "ff40c7eb",
    PALADIN     = "fff58cba",
    PRIEST      = "ffffffff",
    ROGUE       = "fffff569",
    SHAMAN      = "ff0070de",
    WARLOCK     = "ff8787ed",
    WARRIOR     = "ffc79c6e",
    UNKNOWN     = "ffffffff",
}

--------------------------------------------------------------------------
-- Database
--------------------------------------------------------------------------

-- SavedVariables:
GD_Sessions       = GD_Sessions or {}
GD_CurrentSession = GD_CurrentSession or nil

local db = {
    {
        date = "2024.06.07-19:00",
        name = "ICC25HC",
        roster = {
            ["Thoric"] = {
                class = "WARRIOR",
                type = "Blaster",
                gold = 0,
                fails = {}
            }
        },
        sells = {
            items = {
                [0] = {
                    id = 50730,  -- [Glorenzelg, High-Blade of the Silver Hand]
                    gold = 15000,
                    winner = "Thoric"
                }
            },
            shards = 0
        },
    }
}

local default = {
theme = {
    r = 0, --0
    g = 0.8, --204
    b = 1, --255
    hex = "00ccff"
}
}

--------------------------------------------------------------------------
-- Logging functions
--------------------------------------------------------------------------

function Config:GetThemeColor()
    local color = default.theme
    return color.r, color.g, color.b, color.hex
end

function GoldDiggers:Print(...)
    local hex = select(4, self.Config.GetThemeColor())
    local prefix = string.format("|cff%s%s|r", hex:upper(), "GoldDiggers")
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, tostringall(...)))
end

--------------------------------------------------------------------------
-- Ace3.0 Initialization
--------------------------------------------------------------------------

function GoldDiggers:OnInitialize()
    GoldDiggers:init()
    GoldDiggers:Print("Welcome back", UnitName("player") .. "! type |cff00cc66/gd|r for help.")
end

function GoldDiggers:OnEnable()
end

function GoldDiggers:OnDisable()
end

--------------------------------------------------------------------------
-- Config functions
--------------------------------------------------------------------------

function Config:Toggle()
    local menu = Config:OpenMainMenu()
    if menu:IsShown() then
        menu:Hide()
    else
        menu:Show()
    end
end

function Config:OpenMainMenu()
    mainUI = mainUI or CreateFrame("Frame", "GoldDiggersMenu", UIParent, "GDRaidToolsFrame")
    mainUI:SetPoint("CENTER", UIParent, "CENTER")

    -- TODO: we still need to check if the current session is open or not
    -- this is just a basic implementation
    local menuName = mainUI:GetName()
    _G[menuName.."SessionsOpenSessionBtn"]:Enable()
    _G[menuName.."SessionsCloseSessionBtn"]:Disable()

    mainUI:Hide()
    return mainUI
end

--------------------------------------------------------------------------
-- Core
--------------------------------------------------------------------------

--- Open a session form to create a new session
function GoldDiggers:OpenSessionMenu()
    sessionUI = sessionUI or CreateFrame("Frame", "GoldDiggersSessionMenu", mainUI, "GDCreateSessionFrame")
    sessionUI:SetPoint("CENTER", UIParent, "CENTER")

    local sessionName = sessionUI:GetName()
    _G[sessionName.."Raid"]:SetText("")
    _G[sessionName.."Client"]:SetText("1")
    _G[sessionName.."Gold"]:SetText("0")

    sessionUI:Show()
end


--- Create a new session for the current raid
function GoldDiggers:CreateSession()
    local sessionName = sessionUI:GetName()
    local raid = _G[sessionName.."Raid"]:GetText()
    local client = _G[sessionName.."Client"]:GetText()
    local gold = _G[sessionName.."Gold"]:GetText()
    local sessionTime = Helpers.GetCurrentTime()

    local menuName = mainUI:GetName()
    _G[menuName.."SessionsOpenSessionBtn"]:Disable()
    _G[menuName.."SessionsCloseSessionBtn"]:Enable()

    GoldDiggers:Print(sessionTime .. ": Creating Session for " .. raid .. " with " .. client .. " Clients for " .. gold .." g.")
end

--------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------
GoldDiggers.commands = {
    ["ui"] = GoldDiggers.Config.Toggle,
    ["help"] = function()
        print(" ")
        GoldDiggers:Print("List of commands:")
        GoldDiggers:Print("|cff00cc66/gd ui|r - shows options menu")
        GoldDiggers:Print("|cff00cc66/gd help|r - shows help info")
    end
}

local function HandleSlashCommands(str)
    if (#str == 0) then
        GoldDiggers.commands.help()
        return
    end

    local args = {}
    for _, arg in pairs({string.split(" ", str)}) do
        if (#arg > 0) then
            table.insert(args, arg)
        end
    end

    local path = GoldDiggers.commands
    for id, arg in ipairs(args) do
        arg = string.lower(arg)
        if (path[arg]) then
            if (type(path[arg]) == "function") then
                path[arg](select(id + 1, unpack(args)))
                return
            elseif (type(path[arg]) == "table") then
                path = path[arg]
            else
                GoldDiggers.commands.help()
                return
            end
        else
            GoldDiggers.commands.help()
            return
        end
    end
end

function GoldDiggers:init()

    for i = 1, NUM_CHAT_WINDOWS do
        _G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
    end

    -- For quick access to frame stack
    SLASH_FRAMESTK1 = "/fs"
    SlashCmdList.FRAMESTK = function()
        FrameStackTooltip_Toggle()
    end

    -- For Toggling the addon Options Frame
    SLASH_GoldDiggers1 = "/gd"
    SlashCmdList.GoldDiggers = HandleSlashCommands
end