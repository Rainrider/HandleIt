local addonName, addon = ...
local coloredAddonName = string.format("|cff0099CC%s|r", addonName)

local db

local date = date
local print = print
local select = select

local mt = {
	__call = function(t, self, ...)
		for i = 1, #t do
			t[i](self, ...)
		end
	end
}

local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local frame = CreateFrame('Frame', 'etest')
addon.frame = frame

function frame:AddEvent(data)
	local event = data.event
	if not event then return end

	local handler = data.handler
	if handler and type(handler) ~= 'table' then
		handler = { handler }
	end

	if handler then
		local callbacks = {}
		for _, callback in ipairs(handler) do
			if type(callback) == 'string' and callback ~= '' then
				local func, err = loadstring(callback) -- TODO: second param to loadstring
				if func then
					callbacks[#callbacks + 1] = func
				else
					print(err) -- TODO: error here?
				end
			elseif type(callback) == 'function' then
				callbacks[#callbacks + 1] = callback
			end
		end

		local current = self[event]
		if current then
			for i = 1, #callbacks do
				current[#current + 1] = callbacks[i]
			end
		else
			self[event] = setmetatable(callbacks, mt)
		end
	end

	if data.unit1 or data.unit2 then
		print('Registering unit event:', event, data.unit1, data.unit2)
		self:RegisterUnitEvent(event, data.unit1, data.unit2)
		print(self:IsEventRegistered(event))
	else
		print('Registering unitless event:', event, data.unit1, data.unit2)
		self:RegisterEvent(event)
	end
end

function frame:RemoveEvent(data)
	local event = data.event
	if not event then return end

	print('Unregistering event:', event)

	self:UnregisterEvent(event)
	self[event] = nil
end

function frame.PrintArgs(_, event, ...)
	print(date('%X'), coloredAddonName, event)
	for i = 1, select('#', ...) do
		local arg = select(i, ...)
		print(i, ':', arg)
	end
end

frame:SetScript('OnEvent', function(self, event, ...)
	if not self[event] then
		self:PrintArgs(event, ...)
	else
		self[event](self, db, event, ...)
	end
end)
frame:RegisterEvent('ADDON_LOADED')

function frame:ADDON_LOADED(_, _, name)
	if name ~= addonName then return end

	HandleItDB = HandleItDB or {}
	db = HandleItDB
	db.events = db.events or {}
	addon.db = db

	for _, data in next, db.events do
		if data.enabled then
			self:AddEvent(data)
		end
	end

	AceConfig:RegisterOptionsTable(addonName, addon.GetOptions())
	AceConfigDialog:AddToBlizOptions(addonName)

	_G.SLASH_HandleIt1 = '/handleit'
	_G.SLASH_HandleIt2 = '/hit'
	_G.SlashCmdList[addonName] = function()
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end

	self:UnregisterEvent('ADDON_LOADED')
end
