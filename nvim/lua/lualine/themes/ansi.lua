-- Standard ANSI color hex values
-- These represent typical ANSI colors but will adapt to your terminal's palette
local colors = {
  black = '#000000',
  red = '#800000',
  green = '#008000',
  yellow = '#808000',
  blue = '#000080',
  magenta = '#800080',
  cyan = '#008080',
  white = '#c0c0c0',
  bright_black = '#808080',
  bright_red = '#ff0000',
  bright_green = '#00ff00',
  bright_yellow = '#ffff00',
  bright_blue = '#0000ff',
  bright_magenta = '#ff00ff',
  bright_cyan = '#00ffff',
  bright_white = '#ffffff',
}

local section_b = { fg = colors.black, bg = colors.bright_black }
local section_c = { fg = colors.bright_white, bg = colors.black }

local theme = {
  normal = {
    a = { fg = colors.black, bg = colors.yellow, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  insert = {
    a = { fg = colors.black, bg = colors.green, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  visual = {
    a = { fg = colors.black, bg = colors.magenta, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  replace = {
    a = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  command = {
    a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
    b = section_b,
    c = section_c,
    x = section_c,
    y = section_b,
    z = section_b,
  },
  inactive = {
    a = { fg = colors.bright_white, bg = colors.black },
    b = { fg = colors.bright_white, bg = colors.black },
    c = { fg = colors.bright_white, bg = colors.black },
    x = { fg = colors.bright_white, bg = colors.black },
    y = { fg = colors.bright_white, bg = colors.black },
    z = { fg = colors.bright_white, bg = colors.black },
  },
}

return theme
