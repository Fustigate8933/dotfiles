-- Personal Hyprland Lua config.
-- Migrated from hyprland.conf for Hyprland 0.55+.

------------------
---- MONITORS ----
------------------

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-3",
    mode = "preferred",
    position = "auto-left",
    scale = 0.67,
})

for i = 1, 4 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "HDMI-A-3, eDP-1",
    })
end
for i = 5, 8 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "eDP-1",
    })
end

hl.workspace_rule({
    workspace = "name:wechat",
    monitor = "HDMI-A-3, eDP-1",
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland")
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1") -- card0 is intel, card1 is rtx
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("HF_HOME", "/mnt/ianch-Secondary/Programming/DeepLearning/huggingface/")
hl.env("XCURSOR_THEME", "default")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("QT_STYLE_OVERRIDE", "qt5ct")


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("hyprctl setcursor breeze_cursors 24")
    -- hl.exec_cmd("solaar -w \"hide\"")
    hl.exec_cmd("wl-clipboard-history -t")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("rm \"$HOME/.cache/cliphist/db\"")
    -- hl.exec_cmd("eww open bar1")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("udiskie -t")
    hl.exec_cmd("lxpolkit")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("swww init; swww img /home/fustigate/Pictures/frieren_camping.gif --transition-fps 30 --transition-type any --transition-duration 3")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/home/fustigate/.startup-wallpaper.sh")
    hl.exec_cmd("pkill .exe")
    hl.exec_cmd("XDG_MENU_PREFIX=arch- kbuildsycoca6")
    hl.exec_cmd("sleep 2; blueman-applet")
    hl.exec_cmd("sleep 2; powerprofilesctl set power-saver")
    hl.exec_cmd("~/.set_asus_profile.sh")
    -- hl.exec_cmd("bongocat --config ~/.config/bongocat.conf --watch-config")
    -- hl.exec_cmd("~/.wechat_monitor_hyprland.sh")
    -- hl.exec_cmd("VBoxManage startvm \"Windows 10\" --type headless")
end)


-------------------
---- VARIABLES ----
-------------------

hl.config({
    debug = {
        disable_logs = false,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 2,
        force_no_accel = 0,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
    },

    general = {
        gaps_in = 4,
        gaps_out = { top = 0, right = 7, bottom = 7, left = 7 },
        border_size = 3,
        layout = "dwindle",
    },

    decoration = {
        rounding = 7,

        blur = {
            enabled = true,
            ignore_opacity = true,
            size = 10,
            passes = 1,
        },
    },

    opengl = {
        nvidia_anti_flicker = false,
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    gestures = {
        workspace_swipe_forever = true,
        workspace_swipe_direction_lock = false,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    misc = {
        allow_session_lock_restore = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5.5, bezier = "myBezier", style = "slidevert" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear", style = "loop" })

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "logitech-usb-receiver-mouse",
    sensitivity = -0.75,
})

hl.device({
    name = "asuf1416:00-2808:0108-touchpad",
    enabled = true,
})

hl.device({
    name = "logitech-usb-receiver-mouse",
    enabled = true,
})


----------------------
---- WINDOW RULES ----
----------------------

local window_rules = {
    {
        name = "windowrule-1",
        stay_focused = true,
        match = { initial_title = "^(EmotionView)$" },
    },
    {
        name = "windowrule-2",
        float = true,
        match = { class = "^(org.pulseaudio.pavucontrol)$" },
    },
    {
        name = "windowrule-3",
        tile = true,
        match = { class = "^(acrord32.exe)$" },
    },
    {
        name = "windowrule-4",
        float = true,
        match = { class = "^(wechat.exe)$" },
    },
    {
        name = "windowrule-5",
        tile = true,
        match = { title = "^WPS Writer" },
    },
    {
        name = "windowrule-6",
        no_focus = true,
        match = {
            class = "^jetbrains-.*",
            float = true,
            title = "^win\\d+$",
        },
    },
    {
        name = "windowrule-7",
        tile = true,
        match = { class = "^(ONLYOFFICE Desktop Editors)$" },
    },
    {
        name = "windowrule-8",
        tile = true,
        match = { title = "^LINE$" },
    },
    {
        name = "windowrule-9",
        float = true,
        match = { title = "^Floorp — Sharing Indicator$" },
    },
    {
        name = "windowrule-10",
        float = true,
        match = { title = "^Sony Headphones App v1.3.1$" },
    },
    {
        name = "windowrule-11",
        float = true,
        match = { title = "^Kalk — Calculator$" },
    },
    {
        name = "windowrule-12",
        opacity = "0.9 override 0.9 override",
        match = { class = "^kitty$" },
    },
    {
        name = "windowrule-13",
        opacity = "0.95 override 0.95 override",
        match = {
            class = "^kitty$",
            title = ".*nvim.*",
        },
    },
    {
        name = "windowrule-14",
        opacity = "0.88 override 0.8 override",
        xray = true,
        match = { class = "^(discord)$" },
    },
    {
        name = "windowrule-15",
        opacity = "0.8 override 0.8 override",
        match = { class = "^(org.kde.dolphin)$" },
    },
    {
        name = "windowrule-16",
        opacity = "0.85 override 0.85 override",
        match = { class = "^(jetbrains-pycharm)$" },
    },
    {
        name = "windowrule-17",
        opacity = "0.85 override 0.9 override",
        match = { class = "^(DesktopEditors)$" },
    },
    {
        name = "windowrule-18",
        opacity = "0.83 override 0.83 override",
        match = { class = "^(org.kde.kate)$" },
    },
    {
        name = "windowrule-19",
        opacity = "0.92 override 0.92 override",
        match = { class = "^(notion-app-enhanced)$" },
    },
    {
        name = "windowrule-20",
        opacity = "0.96 override 0.96 override",
        match = { class = "^(firefox)$" },
    },
    {
        name = "windowrule-21",
        opacity = "0.85 override 0.9 override",
        match = { class = "^(anki)$" },
    },
    {
        name = "windowrule-22",
        opacity = "0.75 override 0.75 override",
        workspace = "special:sw1",
        xray = true,
        match = { class = "^(YouTube Music)$" },
    },
    {
        name = "windowrule-23",
        animation = "popin",
        match = { title = "^eww-calendar$" },
    },
    {
        name = "windowrule-24",
        workspace = "special:sw7",
        match = { class = "^(explorer.exe)$" },
    },
    {
        name = "windowrule-25",
        workspace = "special:sw7",
        match = { class = "^(whale.exe)$" },
    },
}

for _, rule in ipairs(window_rules) do
    hl.window_rule(rule)
end


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + J", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind("CTRL + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, silent = true }))
end

hl.bind("ALT + Q", hl.dsp.workspace.toggle_special("sw1"))
-- hl.bind("ALT + W", hl.dsp.workspace.toggle_special("sw2"))
hl.bind("ALT + W", hl.dsp.focus({ workspace = "name:wechat" }))
hl.bind("ALT + E", hl.dsp.workspace.toggle_special("sw3"))
hl.bind("ALT + R", hl.dsp.workspace.toggle_special("sw4"))
hl.bind("ALT + T", hl.dsp.workspace.toggle_special("sw5"))
hl.bind("ALT + D", hl.dsp.workspace.toggle_special("sw6"))
hl.bind("ALT + F", hl.dsp.workspace.toggle_special("sw7"))
hl.bind("ALT + G", hl.dsp.workspace.toggle_special("sw8"))

hl.bind("ALT + SHIFT + Q", hl.dsp.window.move({ workspace = "special:sw1" }))
-- hl.bind("ALT + SHIFT + W", hl.dsp.window.move({ workspace = "special:sw2" }))
hl.bind("ALT + SHIFT + W", hl.dsp.window.move({ workspace = "name:wechat" }))
hl.bind("ALT + SHIFT + E", hl.dsp.window.move({ workspace = "special:sw3" }))
hl.bind("ALT + SHIFT + R", hl.dsp.window.move({ workspace = "special:sw4" }))
hl.bind("ALT + SHIFT + T", hl.dsp.window.move({ workspace = "special:sw5" }))
hl.bind("ALT + SHIFT + D", hl.dsp.window.move({ workspace = "special:sw6" }))
hl.bind("ALT + SHIFT + F", hl.dsp.window.move({ workspace = "special:sw7" }))
hl.bind("ALT + SHIFT + G", hl.dsp.window.move({ workspace = "special:sw8" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("http_proxy=http://127.0.0.1:10810 https_proxy=http://127.0.0.1:10810 anki"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o /mnt/ianch-Secondary/Downloads/Images/screenshots/"))
-- hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("pycharm"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("kitty -e zsh -c \"source '/mnt/ianch-Secondary/Programming/linux_venv/bin/activate'; cd '/mnt/ianch-Secondary/Programming/'; exec nvim\""))
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
-- hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("kate ~/.config/hypr/hyprland.conf"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("kitty -e nvim ~/.config/hypr/hyprland.lua"))
-- hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kate --startanon"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("youtube-music"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("gnome-system-monitor"))

hl.bind("ALT + F11", hl.dsp.window.fullscreen())
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 2%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/eww/scripts/change_volume.sh \"down\""), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/eww/scripts/change_volume.sh \"up\""), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl -- set-sink-volume 0 0%"), { locked = true, repeating = true })
-- hl.bind("CTRL + SHIFT + W", hl.dsp.exec_cmd("bottles-cli run -b Whale -e /home/fustigate/Desktop/Whale.exe"))
hl.bind("CTRL + SHIFT + W", hl.dsp.exec_cmd("wine /home/fustigate/Desktop/Whale.exe"))
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("/home/fustigate/.toggle-touchpad.sh"))
hl.bind("Print", hl.dsp.exec_cmd("/home/fustigate/.toggle-touchpad.sh"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("BEMOJI_PICKER_CMD=\"fuzzel -d -p 🔍\" bemoji -t -c -n"))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("ALT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("ALT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("ALT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/fuzzel/wallpaper-change.sh"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 20, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 20 }), { repeating = true })
hl.bind("CTRL + SHIFT + K", hl.dsp.exec_cmd("xdotool windowunmap $(xwininfo -root -children | grep wechat.exe | grep 570x1014 | head -n 1 | awk '{printf \"%s \", $1}')"))
-- hl.bind("CTRL + SHIFT + L", hl.dsp.exec_cmd("~/.togglex2cameravbox.sh"))
hl.bind("CTRL + SHIFT + L", hl.dsp.exec_cmd("echo 0 | sudo tee /sys/bus/usb/devices/1-8/bConfigurationValue"))
hl.bind("CTRL + SHIFT + J", hl.dsp.exec_cmd("VBoxManage startvm \"Windows 10\" --type headless"))
hl.bind("SUPER + BackSpace", hl.dsp.exec_cmd("pkill -SIGUSR1 hyprlock && hyprlock"), { locked = true })
hl.bind("mouse:276", hl.dsp.exec_cmd("XDG_MENU_PREFIX=arch- kbuildsycoca6; notify-send \"Excuted XDG...\" -t 2000"))
-- hl.bind("mouse:275", hl.dsp.exec_cmd("hyprctl dispatch workspace 2"))
hl.bind("ALT + M", hl.dsp.exec_cmd("~/.config/eww/scripts/toggle_microphone.sh"))
