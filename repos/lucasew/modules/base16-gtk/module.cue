package module

#gtk: workspaced.modules["base16-gtk"].config

#gtkSettingsShared: {
	"gtk-theme-name":         #gtk.theme_name
	"gtk-icon-theme-name":    #gtk.icon_theme
	"gtk-font-name":          #gtk.font_name
	"gtk-cursor-theme-name":  #gtk.cursor_theme
	"gtk-cursor-theme-size":  #gtk.cursor_size
	if workspaced.modules.base16.config.dark_mode {
		"gtk-application-prefer-dark-theme": 1
	}
	if workspaced.modules.base16.config.dark_mode == false {
		"gtk-application-prefer-dark-theme": 0
	}
	...
}

module: {
	meta: {
		requires: ["base16"]
		recommends: []
	}

	file: {
		".config/gtk-3.0/settings.ini": {
			type: "ini"
			values: {
				Settings: #gtkSettingsShared & {
					"gtk-toolbar-style":                "GTK_TOOLBAR_BOTH_HORIZ"
					"gtk-toolbar-icon-size":            "GTK_ICON_SIZE_LARGE_TOOLBAR"
					"gtk-button-images":                0
					"gtk-menu-images":                  0
					"gtk-enable-event-sounds":          1
					"gtk-enable-input-feedback-sounds": 0
					"gtk-xft-antialias":                1
					"gtk-xft-hinting":                  1
					"gtk-xft-hintstyle":                "hintslight"
					"gtk-xft-rgba":                     "rgb"
				}
			}
		}
		".config/gtk-4.0/settings.ini": {
			type: "ini"
			values: {
				Settings: #gtkSettingsShared
			}
		}
	}

	config: {
		// adw-gtk3 reads libadwaita named colors from ~/.config/gtk-{3,4}.0/gtk.css
		theme_name: string
		if workspaced.modules.base16.config.dark_mode {
			theme_name: *"adw-gtk3-dark" | string
		}
		if workspaced.modules.base16.config.dark_mode == false {
			theme_name: *"adw-gtk3" | string
		}

		icon_theme:   string | *"workspaced-base16"
		font_name:    string | *"Sans 10"
		cursor_theme: string | *"Adwaita"
		cursor_size:  int | *24
		extra_css:    string | *""

		dconf: {
			"org/gnome/desktop/interface": {
				"gtk-theme":    string | *theme_name
				"icon-theme":   string | *icon_theme
				"cursor-theme": string | *cursor_theme
				"color-scheme": string
				if workspaced.modules.base16.config.dark_mode {
					"color-scheme": *"prefer-dark" | string
				}
				if workspaced.modules.base16.config.dark_mode == false {
					"color-scheme": *"prefer-light" | string
				}
			}
		}
	}

	drivers: {
		"workspaced/pkg/driver/notification.Driver": {
			notification_dbus:        100
			notification_notify_send: 10
		}
	}
}
