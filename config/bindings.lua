local wezterm = require('wezterm')

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.OpenLinkAtMouseCursor,
   },
   -- Ctrl + WheelUp = IncreaseFontSize
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = 'CTRL',
        action = wezterm.action.IncreaseFontSize,
    },
    -- Ctrl + WheelDown = DecreaseFontSize
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = 'CTRL',
        action = wezterm.action.DecreaseFontSize,
    },
}

return {
   mouse_bindings = mouse_bindings,
}