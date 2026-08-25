package module

module: {
	meta: {
		requires: []
		recommends: []
	}
	config: {}
	file: {
		".config/gammastep/config.ini": {
			type: "ini"
			values: {
				general: {
					"temp-day":          5500
					"temp-night":        3700
					"location-provider": "manual"
					"adjustment-method": "wayland"
				}
				manual: {
					lat: -24.0
					lon: -54.0
				}
			}
		}
	}
}
