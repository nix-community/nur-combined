package module

modules: "base16": config: {
		dark_mode: bool | *true
		[=~"^base[0-9A-F]{2}$"]: string & =~"^[0-9a-fA-F]{6}$"
	}

drivers: {
		"github.com/lewtec/modot/internal/driver/notification.Driver": {
			notification_dbus:        100
			notification_notify_send: 10
		}
		"github.com/lewtec/modot/internal/driver/dialog.Chooser": {
			rofi:     100
			terminal: 50
		}
	}
