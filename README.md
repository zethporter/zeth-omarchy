# zeth-omarchy

My personal [Omarchy](https://omarchy.org) customizations, kept in one place.

## Layout

```
hooks/<name>/     Omarchy hooks (scripts run on theme-set, font-set, ...)
                  each folder has its own README, scripts, and an `events` file
install.sh        symlinks a hook into ~/.config/omarchy/hooks
```

Future things get their own top-level folder (e.g. `themes/`, `plugins/`, `configs/`),
each with a README, and `install.sh` grows to cover them.

## Hooks

| Name | What it does |
|---|---|
| [herdr-theme](hooks/herdr-theme) | Herdr app follows the Omarchy theme and font |

## Install

```sh
git clone https://github.com/zethporter/zeth-omarchy ~/zeth-omarchy
~/zeth-omarchy/install.sh herdr-theme
```

Scripts are symlinked, so `git pull` updates them.
