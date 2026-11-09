package module

options: {}

file: home: {
		".config/gammastep/config.ini": {
			type: "ini"
			values: {
				general: {
					"temp-day":          options.screentemp.temperature.day
					"temp-night":        options.screentemp.temperature.night
					"location-provider": "manual"
					"adjustment-method": "wayland"
				}
				manual: {
					lat: options.screentemp.location.latitude
					lon: options.screentemp.location.longitude
				}
			}
		}
	}
