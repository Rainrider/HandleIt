local addonName, addon = ...

local SAMPLE_HANDLER = [[
local self, db, event = ...
self:PrintArgs(event, select(4, ...))
]]

function addon.GetOptions()
	local db = addon.db
	local event = {
		selected = next(db.events)
	}

	function event:Select(key)
		self.selected = key
	end

	function event:GetSelected()
		return self.selected
	end

	function event:HasNoSelection()
		return self.selected == nil
	end

	function event:Create()
		local key = #db.events + 1
		db.events[key] = {}
		db.events[key].event = 'New event #' .. key
		db.events[key].enabled = false
		db.events[key].handler = SAMPLE_HANDLER
		self:Select(key)
	end

	function event:Delete()
		addon.frame:RemoveEvent(db.events[self.selected])
		table.remove(db.events, self.selected)
		self.selected = next(db.events)
	end

	function event:Get(property)
		local data = db.events[self.selected]
		if not data then return end
		return data[property]
	end

	function event:Set(property, value)
		local data = db.events[self.selected]
		if not data or data[property] == value then return end

		if property ~= 'enabled' then
			data.enabled = false
		else
			if value then
				addon.frame:AddEvent(data)
			else
				addon.frame:RemoveEvent(data)
			end
		end
		data[property] = value
	end

	function event:HasNoEvents()
		return not next(db.events)
	end

	local eventNames = {}
	function event:GetEventsList()
		wipe(eventNames)
		for i = 1, #db.events do
			local name = db.events[i].event
			eventNames[i] = name
		end

		return eventNames
	end

	return {
		name = 'Events',
		type = 'group',
		handler = event,
		args = {
			selectedEvent = {
				name = 'Selected Event',
				type = 'select',
				order = 10,
				get = 'GetSelected',
				set = function(_, key) event:Select(key) end,
				values = 'GetEventsList',
				hidden = 'HasNoEvents',
			},
			newEvent = {
				name = 'New event',
				type = 'execute',
				order = 20,
				func = 'Create',
			},
			edit = {
				name = 'Edit event',
				type = 'group',
				order = 30,
				inline = true,
				get = function(info) return event:Get(info[#info]) end,
				set = function(info, value) event:Set(info[#info], value) end,
				hidden = 'HasNoSelection',
				args = {
					enabled = {
						name = 'Enabled',
						type = 'toggle',
						order = 10,
					},
					delete = {
						name = 'Delete',
						type = 'execute',
						order = 15,
						func = 'Delete',
						confirm = true,
						confirmText = 'Permanently delete this event?',
					},
					event = {
						name = 'Event name',
						type = 'input',
						order = 20,
						width = 'full',
						validate = function(_, value)
							if not value or value == "" then
								return 'You must enter an event name.'
							end
							for i = 1, #eventNames do
								if eventNames[i] == value then
									return 'An event with that name already exists.'
								end
							end

							return true
						end,
					},
					unit1 = {
						name = 'First unit',
						type = 'input',
						order = 30,
					},
					unit2 = {
						name = 'Second unit',
						type = 'input',
						order = 35,
					},
					handler = {
						name = 'Event handler',
						type = 'input',
						order = 40,
						multiline = 15,
						width = 'full',
						validate = function(_, value)
							if value == '' then
								return 'You should enter a handler.'
							end

							local _, err = loadstring(value, 'Event Handler code')
							if err then
								return string.format('Your event handler must evaluate to a function body.\n\n%s', err)
							end

							return true
						end,
					},
				},
			},
		},
	}
end


