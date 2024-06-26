local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Events: AceModule
local events = addon:GetModule('Events')

---@class Debug: AceModule
local debug = addon:GetModule('Debug')

---@class Constants: AceModule
local const = addon:GetModule('Constants')

---@class MasqueTheme: AceModule
---@field groups table<string, MasqueGroup>
local masque = addon:NewModule('Masque')

---@class Masque: AceAddon
local Masque = LibStub('Masque', true)

---@private
function masque:AddButtonToGroup(group, button)
  if not Masque then
    return
  end
  self.groups[group]:AddButton(button)
end

---@private
function masque:RemoveButtonFromGroup(group, button)
  if not Masque then
    return
  end
  if group == nil then
    return
  end
  self.groups[group]:RemoveButton(button)
end

function masque:OnEnable()
  if not Masque then return end
  self.groups = {}
  self.groups["Backpack"] = Masque:Group('BetterBags', 'Backpack')
  self.groups["Backpack"]:RegisterCallback(self.OnSkinChange, self)
  self.groups["Bank"] = Masque:Group('BetterBags', 'Bank')
  self.groups["Bank"]:RegisterCallback(self.OnSkinChange, self)

  events:RegisterMessage('item/NewButton', function(_, item)
    ---@cast item Item
    local group = item.kind == const.BAG_KIND.BANK and self.groups["Bank"] or self.groups["Backpack"]
    group:AddButton(item.button)
    self:ReapplyBlend(item.button)
  end)

  events:RegisterMessage('item/Clearing', function(_, item)
    ---@cast item Item
    local group = item.kind == const.BAG_KIND.BANK and self.groups["Bank"] or self.groups["Backpack"]
    group:RemoveButton(item.button)
  end)

  events:RegisterMessage('bagbutton/Updated', function(_, bag)
    ---@cast bag BagButton
    local group = bag.kind == const.BAG_KIND.BANK and self.groups["Bank"] or self.groups["Backpack"]
    group:AddButton(bag.frame)
    bag.frame.IconBorder:SetBlendMode("BLEND")
  end)

  events:RegisterMessage('bagbutton/Clearing', function(_, bag)
    ---@cast bag BagButton
    local group = bag.kind == const.BAG_KIND.BANK and self.groups["Bank"] or self.groups["Backpack"]
    group:RemoveButton(bag.frame)
  end)

  print("BetterBags: Masque integration enabled.")
end

---@param button Button|ItemButton
function masque:ReapplyBlend(button)
  local blend = button.IconBorder:GetBlendMode()
  if blend == nil or blend == "DISABLE" then
    button.IconBorder:SetBlendMode("BLEND")
  else
    button.IconBorder:SetBlendMode(button.IconBorder:GetBlendMode())
  end
end

---@param group MasqueGroup
function masque:OnSkinChange(group)
  for _, button in pairs(group.Buttons) do
    self:ReapplyBlend(button)
  end
end
