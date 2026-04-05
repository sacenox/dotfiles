-- Lualine theme using ANSI cterm colors.
-- Adapts to dark/light background automatically.

local is_light = vim.o.background == 'light'

local section_b = { fg = is_light and 0 or 15, bg = 8 }
local section_c = { fg = is_light and 0 or 15, bg = is_light and 7 or 0 }

local theme = {
  normal = {
    a = { fg = 0, bg = 3, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  insert = {
    a = { fg = 0, bg = 2, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  visual = {
    a = { fg = 0, bg = 5, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  replace = {
    a = { fg = 0, bg = 6, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  command = {
    a = { fg = 0, bg = 4, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  inactive = {
    a = { fg = 8, bg = is_light and 7 or 0 },
    b = { fg = 8, bg = is_light and 7 or 0 },
    c = { fg = 8, bg = is_light and 7 or 0 },
    x = { fg = 8, bg = is_light and 7 or 0 },
    y = { fg = 8, bg = is_light and 7 or 0 },
    z = { fg = 8, bg = is_light and 7 or 0 },
  },
}

return theme
