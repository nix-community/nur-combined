package module

options: {
	mode: *"dark" | "light"
	palette: {
		base00: *"#1d2021" | string & =~"^#[0-9a-fA-F]{6}$"
		base01: *"#282828" | string & =~"^#[0-9a-fA-F]{6}$"
		base02: *"#32302f" | string & =~"^#[0-9a-fA-F]{6}$"
		base03: *"#665c54" | string & =~"^#[0-9a-fA-F]{6}$"
		base04: *"#a89984" | string & =~"^#[0-9a-fA-F]{6}$"
		base05: *"#d5c4a1" | string & =~"^#[0-9a-fA-F]{6}$"
		base06: *"#ebdbb2" | string & =~"^#[0-9a-fA-F]{6}$"
		base07: *"#fbf1c7" | string & =~"^#[0-9a-fA-F]{6}$"
		base08: *"#fb4934" | string & =~"^#[0-9a-fA-F]{6}$"
		base09: *"#fe8019" | string & =~"^#[0-9a-fA-F]{6}$"
		base0A: *"#fabd2f" | string & =~"^#[0-9a-fA-F]{6}$"
		base0B: *"#b8bb26" | string & =~"^#[0-9a-fA-F]{6}$"
		base0C: *"#8ec07c" | string & =~"^#[0-9a-fA-F]{6}$"
		base0D: *"#83a598" | string & =~"^#[0-9a-fA-F]{6}$"
		base0E: *"#d3869b" | string & =~"^#[0-9a-fA-F]{6}$"
		base0F: *"#d65d0e" | string & =~"^#[0-9a-fA-F]{6}$"
	}
}

drivers: {
	"github.com/lewtec/modot/internal/driver/dialog.Chooser": {
		rofi:     100
		terminal: 50
	}
}
