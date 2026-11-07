---
name: kde-computer-use
description: Apply when you need to interact with a KDE Plasma desktop on Wayland as a user would. Use it to test and verify GUIs there. It finds and focuses windows through KWin, presses keys through uinput, and takes screenshots with Spectacle.
---

# Control a KDE Plasma desktop on Wayland

`xdotool`, `wmctrl` and `maim` cannot reach native Wayland windows. Use KWin's D-Bus, a uinput keyboard and Spectacle instead. The user shares this desktop, so warn them first, and touch only the windows you opened.

## Find a window

Search by title. Each row starts with the window's match id, `0_{uuid}`:

```bash
busctl --user call org.kde.KWin /WindowsRunner org.kde.krunner1 Match s rats
```

Read a window's size, position, `pid` and `desktopFile`, which is its Wayland app id:

```bash
qdbus6 org.kde.KWin /KWin org.kde.KWin.getWindowInfo '{uuid}'
```

Two windows can share a title. Tell yours from the user's by `pid`.

## Press keys

`scripts/key.py` focuses the window, then presses keys and clicks. Pass the uuid with its braces. Coordinates are global, so add the window's `x` and `y`:

```bash
python3 ~/.claude/skills/kde-computer-use/scripts/key.py '{uuid}' click:1180,422 alt+o radio enter
```

It stops if the window loses the focus before a step. It needs write access to `/dev/uinput` and `python-evdev`. It moves the user's real pointer, and each run takes the focus from them.

Count volume or list steps from a known state, and check the result in a screenshot. A miscount looks like a bug.

## Take a screenshot

The user keeps working, so the active window may be theirs by the time you capture. Focus yours in the same command, with no wait between. Read the image, and delete it at once if it shows anything but your window:

```bash
python3 ~/.claude/skills/kde-computer-use/scripts/key.py '{uuid}' && spectacle --background --nonotify --activewindow --output /path/to/shot.png
```

Spectacle takes a moment after it returns: wait for the file, then read it.

## Hear what a window plays

You cannot hear it, so measure it. Record the sink's monitor, which is what actually reaches the sink, before the sink's own volume. It holds every app's sound, so first check that only yours is playing:

```bash
timeout 4 pw-record -P '{ stream.capture.sink=true }' --target <sink-node-name> --rate 48000 --channels 2 --format s16 /path/to/out.wav
```

Prove the monitor reads with a quiet control tone from `pw-play`. Recording a stream's node directly misleads: it read sound from a stream the speakers never got. A stream in `running` state and moving bars do not prove sound.
