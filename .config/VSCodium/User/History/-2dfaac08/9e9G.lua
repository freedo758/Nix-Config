-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
 hl.on("hyprland.start", function () 
   hl.exec_cmd("awww-daemon")
   hl.exec_cmd("waybar")
 --  hl.exec_cmd("mpvpaper")
   hl.exec_cmd("systemctl --user start hyprpolkitagent")
   hl.exec_cmd("swaync")
   hl.exec_cmd("/usr/lib/xdg-desktop-portalhypr.sh")
   hl.exec_cmd("wl-paste --watch cliphist store")
   hl.exec_cmd("hypridle")
   hl.exec_cmd("udiskie")
   --hl.exec_cmd("matuwall --daemon")
   --hl.exec_cmd("xwaylandvideobridge &")
   --hl.exec_cmd("hyprctl setcursor Layan-white-cursors 24")
   --hl.exec_cmd("hypridle")
 
 end)

