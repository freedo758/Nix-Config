-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "macOS")
hl.env("HYPRCURSOR_THEME", "macOS")


--Toolkit Bank-end variables

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

--Qt VARIABLES

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--hyprland variables

hl.env("HYPRLAND_TRACE", "1")
hl.env("HYPRLAND_NO_RT", "1")
hl.env("HYPRLAND_NO_SD_NOTIFY", "1")
hl.env("HYPRLAND_NO_SD_VARS", "1")
hl.env("HYPRLAND_CONFIG", "/home/leo/.config/hypr/hyprland.lua")
hl.env ("HYPRSHOT_DIR", "/home/leo/Pictures/Screenshots")
--XDG VARIABLES
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
