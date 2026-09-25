package module

modules: "base16-tmux": config: {
	}

drivers: {
		"github.com/lewtec/modot/internal/driver/notification.Driver": {
			notification_dbus:        100
			notification_notify_send: 10
		}
	}
