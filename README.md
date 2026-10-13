# Dotfiles

Personal configuration files for my development environment, rendered with [`dot-compose`](./dot-compose).

## Layout

- `tmpl/` mirrors `$HOME`. `tmpl/.bashrc` renders to `~/.bashrc`.
- `values/` holds one JSON file per machine/profile, e.g. `values/kanagawa-arch-dev.json`.
- Templates fill machine-specific slots with `{{ key }}` / `{{ nested.key }}`;
  everything else is copied verbatim.

## Usage

Render one file with:

```sh
dot-compose --tmpl tmpl/.bashrc --values values/kanagawa-arch-dev.json
```

Review each file before applying, as these are tailored to my personal workflow.
