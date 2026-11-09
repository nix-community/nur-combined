package module

#gtkSettingsShared: {
	"gtk-theme-name":           options.base16_gtk.theme_name
	"gtk-icon-theme-name":      options.base16_gtk.icon_theme
	"gtk-font-name":            options.base16_gtk.font_name
	"gtk-cursor-theme-name":    options.base16_gtk.cursor_theme
	"gtk-cursor-theme-size":    options.base16_gtk.cursor_size
	"gtk-application-prefer-dark-theme": options.base16_gtk.prefer_dark
	...
}

file: home: {
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

options: {
	palette: options.base16.palette
	prefer_dark: int
	if options.base16.mode == "dark" {
		prefer_dark: 1
	}
	if options.base16.mode == "light" {
		prefer_dark: 0
	}

	// adw-gtk3 reads libadwaita named colors from ~/.config/gtk-{3,4}.0/gtk.css
	theme_name: string
	if options.base16.mode == "dark" {
		theme_name: *"adw-gtk3-dark" | string
	}
	if options.base16.mode == "light" {
		theme_name: *"adw-gtk3" | string
	}

	icon_theme:   string | *"modot-base16"
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
			if options.base16.mode == "dark" {
				"color-scheme": *"prefer-dark" | string
			}
			if options.base16.mode == "light" {
				"color-scheme": *"prefer-light" | string
			}
		}
	}
}
