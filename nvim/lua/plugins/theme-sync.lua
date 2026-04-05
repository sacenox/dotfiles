-- Sync vim background with KDE dark/light mode.
-- Reads ~/.local/state/kde-color-mode on startup, and <leader>T toggles.

local mode_file = vim.fn.expand('~/.local/state/kde-color-mode')

local function read_mode()
    local f = io.open(mode_file, 'r')
    if not f then return nil end
    local mode = f:read('*l')
    f:close()
    if mode == 'dark' or mode == 'light' then
        return mode
    end
    return nil
end

-- Apply system mode on startup
local mode = read_mode()
if mode then
    vim.o.background = mode
end

-- Toggle keybind
vim.keymap.set('n', '<leader>T', function()
    vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'
end, { noremap = true, silent = true, desc = 'Toggle dark/light theme' })

return {}
