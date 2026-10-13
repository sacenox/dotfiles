# Dot Compose

A simple CLI to manage dotfiles based on existing template snippets and the user values.

Concept initial setup:

```sh
$ ./dot-compose --skill
# Agent instructions to parse existing dotfiles/values into templates and value files
...
```
The user can use that cli path to prompt an LLM/Agent to create their initial templates/values.

Concept usage:

```sh
$ ./dot-compose --tmpl ./tmpl/nvim/lua.init --values ./values/kanagawa-and-lilex-font.json
$ cat ~/.config/nvim/init.lua
# dot-compose generated init.lua
vim.cmd.colorscheme('kanagawa-dragon')
```

Basically the typical developer dotfiles repo becomes the templates, and the values a json file with them so
we can render the template.

What does this solve? See `../dotfiles` for how i've been doing dotfile management. My mac setup conflicts with my linux setup.
And my vps has a completly different set.  I'd like to make the templates from that dotfiles, then configure values for mac, linux, vps, etc...

So I can quickly apply/edit configs. For example, my mac uses ghostty with iosevka font and tokyo night themes acrross apps. But my linux setup uses
kitty and kanagawa themes and lilax font. My vps uses zellij but neither of the other ones uses it.

Another pattern to notice from my dotfiles, is how I use a ~/.keys.json that is not committed to load bash env vars. The machine specific config removes
the need for this hack, and I can just set these in a special values json (./values/secrets.json gitignored), where I can keep secrets, safe outside of git.

## Tech

- zig 0.16.x
- memory efficient, fast.
