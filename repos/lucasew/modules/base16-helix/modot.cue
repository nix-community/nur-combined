package module

options: {
	palette: options.base16.palette
}

file: home: {
		".config/helix/themes/base16.toml": {
			type: "toml"
			values: {
				"ui.background":             {bg: options.base16_helix.palette.base00}
				"ui.background.separator":   {fg: options.base16_helix.palette.base03}
				"ui.cursor":                 {fg: options.base16_helix.palette.base00, bg: options.base16_helix.palette.base05}
				"ui.cursor.match":           {fg: options.base16_helix.palette.base0A, modifiers: ["bold"]}
				"ui.cursor.primary":         {fg: options.base16_helix.palette.base00, bg: options.base16_helix.palette.base05}
				"ui.cursorline.primary":     {bg: options.base16_helix.palette.base01}
				"ui.selection":              {bg: options.base16_helix.palette.base02}
				"ui.linenr":                 {fg: options.base16_helix.palette.base03}
				"ui.linenr.selected":        {fg: options.base16_helix.palette.base04}
				"ui.statusline":             {fg: options.base16_helix.palette.base04, bg: options.base16_helix.palette.base01}
				"ui.statusline.inactive":    {fg: options.base16_helix.palette.base03, bg: options.base16_helix.palette.base01}
				"ui.statusline.normal":      {fg: options.base16_helix.palette.base00, bg: options.base16_helix.palette.base0B, modifiers: ["bold"]}
				"ui.statusline.insert":      {fg: options.base16_helix.palette.base00, bg: options.base16_helix.palette.base0D, modifiers: ["bold"]}
				"ui.statusline.select":      {fg: options.base16_helix.palette.base00, bg: options.base16_helix.palette.base0E, modifiers: ["bold"]}
				"ui.popup":                  {fg: options.base16_helix.palette.base05, bg: options.base16_helix.palette.base01}
				"ui.window":                 {fg: options.base16_helix.palette.base03}
				"ui.help":                   {fg: options.base16_helix.palette.base05, bg: options.base16_helix.palette.base01}
				"ui.text":                   options.base16_helix.palette.base05
				"ui.text.focus":             options.base16_helix.palette.base05
				variable:                    options.base16_helix.palette.base08
				constant:                    options.base16_helix.palette.base09
				"constant.character.escape": options.base16_helix.palette.base0C
				comment:                     {fg: options.base16_helix.palette.base03, modifiers: ["italic"]}
				"variable.other.member":     options.base16_helix.palette.base08
				label:                       options.base16_helix.palette.base0E
				string:                      options.base16_helix.palette.base0B
				"string.regexp":             options.base16_helix.palette.base08
				escape:                      options.base16_helix.palette.base0C
				type:                        options.base16_helix.palette.base0A
				constructor:                 options.base16_helix.palette.base0D
				function:                    options.base16_helix.palette.base0D
				keyword:                     options.base16_helix.palette.base0E
				operator:                    options.base16_helix.palette.base05
				attribute:                   options.base16_helix.palette.base0A
				namespace:                   options.base16_helix.palette.base0E
				special:                     options.base16_helix.palette.base0D
				"markup.heading":            options.base16_helix.palette.base0D
				"markup.list":               options.base16_helix.palette.base08
				"markup.bold":               {fg: options.base16_helix.palette.base0A, modifiers: ["bold"]}
				"markup.italic":             {fg: options.base16_helix.palette.base0E, modifiers: ["italic"]}
				"markup.link.url":           {fg: options.base16_helix.palette.base09, modifiers: ["underline"]}
				"markup.link.text":          options.base16_helix.palette.base08
				"markup.raw":                options.base16_helix.palette.base09
				diagnostic:                  {modifiers: ["underline"]}
				error:                       options.base16_helix.palette.base08
				warning:                     options.base16_helix.palette.base0A
				info:                        options.base16_helix.palette.base0D
				hint:                        options.base16_helix.palette.base0C
			}
		}
	}
