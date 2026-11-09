package module

options: {
	default: {
		browser: string
		webapp: string
	}
	apps?: [string]: {
		browser: default.webapp | *null
		url: string
		profile?: string
		desktop_name?: string
		icon?: string
		extra_flags: [...string]
	}
}
