package module

module: {
	meta: {
		requires: []
		recommends: []
	}

	config: {
		apps?: [string]: {
			browser: string | *null
			url: string
			profile?: string
			desktop_name?: string
			icon?: string
			extra_flags: [...string]
		}
	}
}
