#!/usr/bin/env python3
"""Focus one KWin window, then press keys and click in it through a short-lived uinput device.

Usage: key.py <window-uuid> <step> [...]
A step is a combo or key name (alt+o, ctrl+v, enter, space, down), click:X,Y or move:X,Y in
global coordinates, or text to type, in lowercase letters, digits and spaces.
It stops if the window loses the focus, so nothing lands in another window.
"""
import subprocess
import sys
import tempfile
import time

from evdev import UInput, ecodes as e

NAMES = {"alt": "LEFTALT", "ctrl": "LEFTCTRL", "shift": "LEFTSHIFT", "super": "LEFTMETA", "esc": "ESC"}
KEYS = {"enter", "space", "tab", "esc", "up", "down", "left", "right", "backspace"}
SCRIPT = 'print("%s " + workspace.cursorPos.x + " " + workspace.cursorPos.y + " " + (workspace.activeWindow ? workspace.activeWindow.internalId : ""));'


def qdbus(path, method, *args):
    return subprocess.run(["qdbus6", "org.kde.KWin", path, method, *args], check=True, capture_output=True, text=True).stdout.strip()


def state():
    """The pointer's position and the active window, from a KWin script that prints them."""
    token = f"KDECU{time.time_ns()}"
    since = int(time.time()) - 1
    with tempfile.NamedTemporaryFile("w", suffix=".js") as script:
        script.write(SCRIPT % token)
        script.flush()
        number = qdbus("/Scripting", "org.kde.kwin.Scripting.loadScript", script.name, "kdecu")
        qdbus(f"/Scripting/Script{number}", "org.kde.kwin.Script.run")
        qdbus("/Scripting", "org.kde.kwin.Scripting.unloadScript", "kdecu")
    for _ in range(40):
        log = subprocess.run(["journalctl", "--user", "--since", f"@{since}", "-o", "cat", "--grep", token], capture_output=True, text=True).stdout
        if token in log:
            _, x, y, *window = log.strip().splitlines()[-1].split()
            return int(x), int(y), window[0] if window else ""
        time.sleep(0.05)
    raise SystemExit("key.py: KWin did not answer")


def code(name):
    return getattr(e, "KEY_" + NAMES.get(name, name).upper())


def press(device, codes):
    for key in codes:
        device.write(e.EV_KEY, key, 1)
        device.syn()
    time.sleep(0.03)
    for key in reversed(codes):
        device.write(e.EV_KEY, key, 0)
        device.syn()
    time.sleep(0.03)


def travel(device, axis, distance):
    for _ in range(abs(distance) // 2):
        device.write(e.EV_REL, axis, 2 if distance > 0 else -2)
        device.syn()
        time.sleep(0.008)  # At this pace one unit is one pixel. Faster, the acceleration overshoots.


def move(device, x, y):
    """The pointer is relative, so it moves, looks where it landed and corrects."""
    for _ in range(6):
        here_x, here_y, _window = state()
        if abs(here_x - x) <= 3 and abs(here_y - y) <= 3:
            return
        travel(device, e.REL_X, x - here_x)
        travel(device, e.REL_Y, y - here_y)
        time.sleep(0.05)
    raise SystemExit(f"key.py: the pointer stopped at {state()[:2]}, not {x},{y}")


def main():
    window, steps = sys.argv[1], sys.argv[2:]
    capabilities = [v for k, v in vars(e).items() if k.startswith("KEY_") and isinstance(v, int) and v < 249]
    events = {e.EV_KEY: capabilities + [e.BTN_LEFT], e.EV_REL: [e.REL_X, e.REL_Y]}
    with UInput(events, name="kde-computer-use") as device:
        time.sleep(0.6)  # The compositor has to see the new device first.
        subprocess.run(
            ["busctl", "--user", "call", "org.kde.KWin", "/WindowsRunner", "org.kde.krunner1", "Run", "ss", f"0_{window}", ""],
            check=True,
        )
        time.sleep(0.2)
        for step in steps:
            if state()[2] != window:
                raise SystemExit(f"key.py: {window} lost the focus, stopped before {step}")
            if step.startswith(("move:", "click:")):
                action, place = step.split(":")
                move(device, *map(int, place.split(",")))
                if action == "click":
                    press(device, [e.BTN_LEFT])
            elif "+" in step or step in KEYS:
                press(device, [code(part) for part in step.split("+")])
            else:
                for char in step:
                    press(device, [e.KEY_SPACE if char == " " else code(char)])
            time.sleep(0.05)


main()
