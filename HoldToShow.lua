--[[---------------------------------------------------------------------------
    HoldToShow

    Hold Ctrl to bring back the chat and quest tracker of an EllesmereUI layout
    set to "never". Chat also stays up while its edit box is open, or what you
    type would be invisible.

    EllesmereUI asks one function whether a thing is visible and re-asks on
    request, so Ctrl just changes that answer and lets each module do its own
    showing.
-----------------------------------------------------------------------------]]

local eui = EllesmereUI
if not (eui and eui.EvalVisibility and eui.RequestVisibilityUpdate) then return end

local ctrlDown, typing = false, false

local function Addon(name)
    local db = EllesmereUIDB
    local profile = db and db.profiles and db.profiles[db.activeProfile or "Default"]
    return profile and profile.addons and profile.addons[name]
end

local function Revealed(cfg)
    local chat = Addon("EllesmereUIChat")
    if chat and cfg == chat.chat then return ctrlDown or typing end
    local quests = Addon("EllesmereUIQuestTracker")
    return ctrlDown and quests and cfg == quests.questTracker
end

local eval = eui.EvalVisibility
eui.EvalVisibility = function(cfg)
    if cfg and Revealed(cfg) then return true end
    return eval(cfg)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("MODIFIER_STATE_CHANGED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        local box = _G.ChatFrame1EditBox
        if box then
            box:HookScript("OnShow", function() typing = true; eui.RequestVisibilityUpdate() end)
            box:HookScript("OnHide", function() typing = false; eui.RequestVisibilityUpdate() end)
        end
        return
    end
    local down = IsControlKeyDown() and true or false
    if down ~= ctrlDown then
        ctrlDown = down
        eui.RequestVisibilityUpdate()
    end
end)
