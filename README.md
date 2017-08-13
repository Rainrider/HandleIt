# HandleIt

This is a small addon that allows you to write event handlers in a GUI in-game. Useful if you want to look up the event
arguments, check some state or even save stuff to saved variables.

## Features

  - you can enable/disable events without loosing your handler code
  - a default handler displaying all event arguments is provided
  - you can write stuff to the addon's SavedVariables from within your handler
  - you can register further events and add additional event handlers from within your handlers (use at your own risk)

## How to use

Type `/handleit` or `/hit` in the chat to open the options. Click "New event" or a select an existing one. Edit to your
liking.

Anytime you change something, the event will be automatically disabled. Re-enable when you are done.

In your handler you get the following arguments through `...`, the same way you get your addon's name and namespace in
your addons, meaning you can name those whatever you like:

  - self  - the frame the addon uses for event registration (_Frame_)
  - db    - a reference to the addon's global SavedVariables. Use this to save your state if needed (_table_)
  - event - the name of the triggered event (_string_)
  - ...   - any further event arguments

Calling other event handlers is done by `self[event](...)` where `self` is the addon's frame, `event` is the event name
and `...` preserves the argument order as above.

## API

The API, in its current state, is not meant to replace or alter the GUI. This is what the GUI uses to (un)register
events and is exposed to you in case you find it useful. The state of the GUI is saved to the addon's SavedVariables.

  - `:AddEvent(data)` - used to add a new event, or add further callbacks to its handler. Adding an event means
    registering it and attaching the supplied callbacks to make up a handler.  
    `data` is a simple associative array as follows:  
	- event   - the name of the event you'd like to register (_string_)  
	- unit1   - the first event unit (_string_ or _nil_)  
	- unit2   - the second event unit (_string_ or _nil_)  
	- handler - the callback(s) you want to use as the event handler (_string_ or _function_ or a table thereof)

	NOTE: If you call `:AddEvent` for an already added event, it will add the new callbacks instead of rewriting the old
	ones.  
	If either `unit1` or `unit2` are non-nils, `RegisterUnitEvent` will be used for event registration potentially
	overwriting event units from previous calls.

  - `:RemoveEvent(data)` - used to remove an event, where `data` is structured as described above. Actually only
  `data.event` plays a role here. Removing an event means unregistering it und deleting the associated handler.

## Limitations

The GUI is limited to one handler per event. So if you added another handler from code and then edit the event in
the GUI, the handler you added will be detached automatically without notice.

The GUI does not list events and handlers you added from code.

## Bug reports

You can file bug reports and issues on the [project's page at GitHub](https://github.com/Rainrider/HandleIt/issues).