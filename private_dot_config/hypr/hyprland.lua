------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Matched by description, not connector name: DP-N numbering is not stable
-- across boots, so a stale DP-1/DP-2 rule silently falls back to 60Hz.
hl.monitor({
	output = "desc:Dell Inc. S2419HGF 8QNG7P2",
	mode = "1920x1080@120",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "desc:Dell Inc. S2419HGF 95WK7P2",
	mode = "1920x1080@120",
	position = "1920x0",
	scale = 1,
})

-- Fallback for any other output: highest available refresh rate
hl.monitor({
	output = "",
	mode = "highrr",
	position = "auto",
	scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "nautilus --new-window"
local menu = "anyrun"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "22")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "22")
hl.env("GTK_THEME", "Adwaita-dark")
hl.env("NVD_BACKEND", "direct")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "$XDG_RUNTIME_DIR") .. "/keyring/ssh")

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	-- uwsm waits for this signal before considering the session started
	hl.exec_cmd("uwsm finalize")
	-- hl.exec_cmd("ashell") -- replaced by wayle 2026-06-22 (re-enable to revert)
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("wayle panel start")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("easyeffects --service-mode")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
	hl.exec_cmd("swayosd-server")
	hl.exec_cmd("wayscriber --daemon")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,

		col = {
			active_border = { colors = { "rgba(beff00ff)", "rgba(ff637dff)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = true,

		layout = "master",
	},

	decoration = {
		rounding = 5,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
	master = {
		new_status = "slave",
		mfact = 0.5,
	},

	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
	},

	cursor = {
		no_hardware_cursors = false,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "default", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = false })
hl.animation({ leaf = "fadeIn", enabled = false })
hl.animation({ leaf = "fadeOut", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "default", style = "slide" })

-- Disable layer animations for anyrun launcher
hl.layer_rule({
	name = "no-anim-anyrun",
	match = { namespace = "^anyrun$" },
	no_anim = true,
})

---------------
---- INPUT ----
---------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
		},
	},
})

-- Gestures
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Application & Window actions
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd(
		[[sh -c "cliphist list | tail -n +11 | cliphist delete; cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"]]
	)
)
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + T", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only -s"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only -s"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("waypaper"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("wayscriber --daemon-toggle"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -anl"))
hl.bind(mainMod .. " + End", hl.dsp.exit())

-- Multimedia / OSD Keys
hl.bind("Caps_Lock", hl.dsp.exec_cmd("sleep 0.1 && swayosd-client --caps-lock"), { locked = true })
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause --player spotify"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl prev --player spotify"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next --player spotify"), { locked = true })

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move Windows with mainMod + SHIFT + hjkl
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignore maximize requests from all apps
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "hyprland-run-rules",
	match = { class = "^(hyprland-run)$" },
	float = true,
	move = "20 100%-",
})

-- Hyprshot float
hl.window_rule({
	name = "hyprshot-float",
	match = { title = "^(Hyprshot)$" },
	float = true,
})

-- Disable blur on right-click menus (Chrome, etc.)
hl.window_rule({
	name = "disable-context-menu-blur",
	match = { class = "^$", title = "^$" },
	no_blur = true,
})

-- Zoom annotation overlay - don't blur
hl.window_rule({
	name = "zoom-no-blur",
	match = { class = "^(zoom)$" },
	no_blur = true,
})
