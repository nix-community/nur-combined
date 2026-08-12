package module

module: {
	meta: {
		requires: ["base16"]
		recommends: []
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
