#!/usr/bin/env bash
# Sync the Herdr app with the active Omarchy theme and terminal font.
# Writes ~/.config/herdr-app/themes/omarchy.json and points settings.json at it.
HERDR="$HOME/.config/herdr-app"
COLORS="$HOME/.local/state/omarchy/current/theme/colors.toml"
[[ -d $HERDR && -f $COLORS ]] || exit 0

FONT=$(omarchy font current 2>/dev/null)

python3 -I - "$COLORS" "$HERDR" "$FONT" <<'PY'
import json, re, sys, tomllib, os
colors_path, herdr, font = sys.argv[1:4]
c = tomllib.load(open(colors_path, "rb"))

def rgb(h): h = h.lstrip("#")[:6]; return [int(h[i:i+2], 16) for i in (0, 2, 4)]
def hexs(v): return "#%02x%02x%02x" % tuple(round(max(0, min(255, x))) for x in v)
def mix(a, b, t): return hexs([x + (y - x) * t for x, y in zip(rgb(a), rgb(b))])
def g(k, d): return c.get(k, d).lower() if isinstance(c.get(k, d), str) else d

light = c.get("mode") == "light"
bg, fg = g("background", "#000000"), g("foreground", "#ffffff")
accent = g("accent", g("blue", fg))
muted = g("muted", mix(bg, fg, .4))
# Depth: sidebars/canvas slightly offset from the terminal background.
toward = "#000000" if not light else "#ffffff"
chrome = g("dark_background", mix(bg, toward, .25)) if not light else mix(bg, "#000000", .04)
if chrome == bg: chrome = mix(bg, toward, .25)
canvas = mix(bg, toward, .45) if not light else mix(bg, "#000000", .08)
if g("darker_background", "") and not light: canvas = g("darker_background", canvas)
if canvas == bg: canvas = mix(bg, toward, .45)

red, green, yellow = g("red", "#ff5555"), g("green", "#55ff55"), g("yellow", "#ffff55")
blue, magenta, cyan = g("blue", "#5555ff"), g("magenta", "#ff55ff"), g("cyan", "#55ffff")
ansi = [bg, red, green, yellow, blue, magenta, cyan, fg,
        muted, g("bright_red", red), g("bright_green", green), g("bright_yellow", yellow),
        g("bright_blue", blue), g("bright_magenta", magenta), g("bright_cyan", cyan),
        g("bright_foreground", fg)]

theme = {
  "background": bg, "foreground": fg,
  "selection": g("selection", mix(bg, fg, .2)), "cursor": g("bright_foreground", fg),
  "ansi": ansi,
  "colors": {
    "background": bg, "canvas": canvas, "chrome": chrome,
    "surface": mix(bg, fg, .03), "popover": mix(bg, fg, .06),
    "raised": mix(bg, fg, .08), "hover": mix(bg, fg, .10), "selected": mix(bg, fg, .14),
    "border": mix(bg, fg, .16), "input": mix(bg, fg, .24),
    "foreground": fg, "muted": mix(bg, fg, .65), "dim": mix(bg, fg, .42),
    "accent": accent, "accent_foreground": bg if not light else "#ffffff",
    "solid": accent, "solid_foreground": bg if not light else "#ffffff",
    "working": yellow, "blocked": red, "done": green, "idle": mix(bg, fg, .42), "unknown": mix(bg, fg, .42),
  },
}
os.makedirs(f"{herdr}/themes", exist_ok=True)
with open(f"{herdr}/themes/omarchy.json", "w") as f: json.dump(theme, f, indent=2)

sp = f"{herdr}/settings.json"
s = json.load(open(sp))
s["theme"] = "omarchy"
s.pop("colors", None)
if font: s["font"] = font
s["appearance"] = "light" if light else "dark"
with open(sp, "w") as f: json.dump(s, f, indent=2)
PY
