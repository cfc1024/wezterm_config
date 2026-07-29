local wezterm = require('wezterm')
local scroll = require('events.scroll')
local platform = require('utils.platform')
local act = wezterm.action

local ctrl_key = platform.is_mac and 'CMD' or 'CTRL'
local ctrl_shift_key = platform.is_mac and 'CMD|SHIFT' or 'CTRL|SHIFT'
local alt_key = platform.is_mac and 'OPT' or 'ALT'

local mouse_bindings = {
    -- Ctrl + WheelUp = IncreaseFontSize
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = ctrl_key,
        action = act.IncreaseFontSize,
    },
    -- Ctrl + WheelDown = DecreaseFontSize
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = ctrl_key,
        action = act.DecreaseFontSize,
    },
    -- fast scroll
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = alt_key,
        action = scroll.fast_scroll(-1, 0.5),
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = alt_key,
        action = scroll.fast_scroll(1, 0.5),
    },
    -- middle click paste, keep working in zellij
    {
        event = { Down = { streak = 1, button = 'Middle' } },
        mods = 'NONE',
        action = act.PasteFrom 'PrimarySelection',
        mouse_reporting = true,
    },
}

local keys = {
    {
        key = 'a',
        mods = ctrl_key,
        action = act.ActivateKeyTable
            {
                name = 'custom',
                one_shot = false,
                timeout_milliseconds = 10000,
            }
    },
    { key = 'p',      mods = ctrl_shift_key, action = act.ActivateCommandPalette, },

    -- copy and paste
    { key = 'c',      mods = ctrl_shift_key, action = act.CopyTo('Clipboard') },
    { key = 'v',      mods = ctrl_shift_key, action = act.PasteFrom('Clipboard') },

    -- linux copy and paste
    { key = 'Insert', mods = ctrl_key,       action = act.CopyTo('Clipboard') },
    { key = 'Insert', mods = 'SHIFT',        action = act.PasteFrom('Clipboard') },


    -- clear
    { key = 'l',      mods = ctrl_key,       action = act.ClearScrollback('ScrollbackAndViewport') },

    -- tab
    { key = 'Tab',    mods = ctrl_key,       action = act.ActivateTabRelative(1) },
    { key = 'Tab',    mods = ctrl_shift_key, action = act.ActivateTabRelative(-1) },

    -- font
    { key = '=',      mods = ctrl_key,       action = act.IncreaseFontSize },
    { key = '-',      mods = ctrl_key,       action = act.DecreaseFontSize },
    { key = '0',      mods = ctrl_key,       action = act.ResetFontSize },

    -- -- Tab 左右移动
    { key = '[',      mods = ctrl_key,       action = act.ActivateTabRelative(-1) }, -- tab左移
    { key = ']',      mods = ctrl_key,       action = act.ActivateTabRelative(1) },  -- tab右移

    -- reset
    {
        key = 'F11',
        action = act.Multiple {
            act.SendString '\x03',
            act.SendString 'reset\n',
        }
    },
    -- debug mode
    { key = 'F12', action = act.ShowDebugOverlay },
}

local key_tables = {
    -- timeout_milliseconds = 2000,
    custom = {

        { key = 'c',      action = act.ActivateCopyMode, },                                                                     -- copy mode
        { key = 'f',      action = act.Search('CurrentSelectionOrEmptyString') },                                               -- find mode

        { key = 'p',      action = act.ActivateKeyTable { name = 'pane', one_shot = false, timeout_milliseconds = 10000, } },   -- pane
        { key = 's',      action = act.ActivateKeyTable { name = 'scroll', one_shot = false, timeout_milliseconds = 10000, } }, -- 翻页 scroll
        { key = 't',      action = act.ActivateKeyTable { name = 'tab', one_shot = false, timeout_milliseconds = 10000, } },    -- 进入 tab 子菜单
        { key = 'w',      action = act.ActivateKeyTable { name = 'window', one_shot = false, timeout_milliseconds = 10000, } }, -- window 控制

        { key = 'q',      action = wezterm.action.PopKeyTable },
        { key = 'Escape', action = act.ClearKeyTableStack },
    },
    scroll = {
        { key = '[',      action = act.ScrollByPage(-0.5) }, -- 上翻半页
        { key = ']',      action = act.ScrollByPage(0.5) },  -- 下翻半页

        { key = '-',      action = act.ScrollByPage(-0.5) }, -- 上翻半页
        { key = '=',      action = act.ScrollByPage(0.5) },  -- 下翻半页

        { key = 't',      action = act.ScrollToTop },
        { key = 'b',      action = act.ScrollToBottom },

        { key = 'q',      action = wezterm.action.PopKeyTable },
        { key = 'Escape', action = act.ClearKeyTableStack },
    },
    pane = {
        { key = '-',      action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = '\\',     action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

        { key = 'h',      action = act.ActivatePaneDirection('Left') },
        { key = 'l',      action = act.ActivatePaneDirection('Right') },
        { key = 'j',      action = act.ActivatePaneDirection('Down') },
        { key = 'k',      action = act.ActivatePaneDirection('Up') },

        { key = 's',      action = act.PaneSelect { mode = 'SwapWithActive' } },
        { key = 'x',      action = act.CloseCurrentPane { confirm = true } },
        { key = 'f',      action = act.TogglePaneZoomState }, -- 最大化当前pane

        { key = 'q',      action = wezterm.action.PopKeyTable },
        { key = 'Escape', action = act.ClearKeyTableStack },
    },
    tab = {
        { key = 'n',      action = act.EmitEvent('tabs.manual-update-tab-title') }, -- 重命名tab
        -- { key = 'r',      action = act.EmitEvent('tabs.reset-tab-title') },                     -- 恢复tab title
        -- { key = 't',      action = act.EmitEvent('tabs.toggle-tab-bar') },                      -- 隐藏tab栏
        { key = 'c',      action = act.SpawnTab('CurrentPaneDomain') },                         -- 创建新tab
        { key = 'a',      action = act.ShowLauncherArgs { flags = 'TABS|LAUNCH_MENU_ITEMS' } }, --带有args创建新tab
        { key = 'x',      action = act.CloseCurrentTab { confirm = false } },                   -- 关闭当前tab, 不需要确认，直接关闭

        -- -- Tab 左右移动
        { key = '[',      action = act.ActivateTabRelative(-1) }, -- tab左移
        { key = ']',      action = act.ActivateTabRelative(1) },  -- tab右移

        -- -- 移动到指定位置（索引从 0 开始）
        -- { key = '0',      action = act.MoveTab(0) }, -- 移到最左，0位置
        -- { key = '1',      action = act.MoveTab(1) },
        -- { key = '2',      action = act.MoveTab(2) },
        -- { key = '3',      action = act.MoveTab(3) },
        -- { key = '4',      action = act.MoveTab(4) },

        { key = '1',      action = act.ActivateTab(0) },
        { key = '2',      action = act.ActivateTab(1) },
        { key = '3',      action = act.ActivateTab(2) },
        { key = '4',      action = act.ActivateTab(3) },
        { key = '5',      action = act.ActivateTab(4) },
        { key = '6',      action = act.ActivateTab(5) },
        { key = '7',      action = act.ActivateTab(6) },
        { key = '8',      action = act.ActivateTab(7) },
        { key = '9',      action = act.ActivateTab(8) },
        { key = '0',      action = act.ActivateTab(-1) },

        { key = 'q',      action = wezterm.action.PopKeyTable },
        { key = 'Escape', action = act.ClearKeyTableStack },
    },
    window = {
        { key = 'x',      action = act.QuitApplication },  -- 关闭window
        { key = 'f',      action = act.ToggleFullScreen }, -- 最大化window
        { key = 'm',      action = act.Hide },             -- 最小化window
        { key = 'a',      action = act.SpawnWindow },      -- 新建window

        { key = 'q',      action = wezterm.action.PopKeyTable },
        { key = 'Escape', action = act.ClearKeyTableStack },
    },
}

return {
    disable_default_key_bindings = true,
    keys = keys,
    key_tables = key_tables,
    mouse_bindings = mouse_bindings,
}
