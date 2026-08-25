package module

#hex: {
	for k, v in workspaced.modules.base16.config if k =~ "^base" {
		(k): "#\(v)"
	}
}

module: {
	meta: {
		requires: ["base16"]
		recommends: []
	}

	config: {}

	file: {
		".config/helix/themes/base16.toml": {
			type: "toml"
			values: {
				"ui.background":             {bg: #hex.base00}
				"ui.background.separator":   {fg: #hex.base03}
				"ui.cursor":                 {fg: #hex.base00, bg: #hex.base05}
				"ui.cursor.match":           {fg: #hex.base0A, modifiers: ["bold"]}
				"ui.cursor.primary":         {fg: #hex.base00, bg: #hex.base05}
				"ui.cursorline.primary":     {bg: #hex.base01}
				"ui.selection":              {bg: #hex.base02}
				"ui.linenr":                 {fg: #hex.base03}
				"ui.linenr.selected":        {fg: #hex.base04}
				"ui.statusline":             {fg: #hex.base04, bg: #hex.base01}
				"ui.statusline.inactive":    {fg: #hex.base03, bg: #hex.base01}
				"ui.statusline.normal":      {fg: #hex.base00, bg: #hex.base0B, modifiers: ["bold"]}
				"ui.statusline.insert":      {fg: #hex.base00, bg: #hex.base0D, modifiers: ["bold"]}
				"ui.statusline.select":      {fg: #hex.base00, bg: #hex.base0E, modifiers: ["bold"]}
				"ui.popup":                  {fg: #hex.base05, bg: #hex.base01}
				"ui.window":                 {fg: #hex.base03}
				"ui.help":                   {fg: #hex.base05, bg: #hex.base01}
				"ui.text":                   #hex.base05
				"ui.text.focus":             #hex.base05
				variable:                    #hex.base08
				constant:                    #hex.base09
				"constant.character.escape": #hex.base0C
				comment:                     {fg: #hex.base03, modifiers: ["italic"]}
				"variable.other.member":     #hex.base08
				label:                       #hex.base0E
				string:                      #hex.base0B
				"string.regexp":             #hex.base08
				escape:                      #hex.base0C
				type:                        #hex.base0A
				constructor:                 #hex.base0D
				function:                    #hex.base0D
				keyword:                     #hex.base0E
				operator:                    #hex.base05
				attribute:                   #hex.base0A
				namespace:                   #hex.base0E
				special:                     #hex.base0D
				"markup.heading":            #hex.base0D
				"markup.list":               #hex.base08
				"markup.bold":               {fg: #hex.base0A, modifiers: ["bold"]}
				"markup.italic":             {fg: #hex.base0E, modifiers: ["italic"]}
				"markup.link.url":           {fg: #hex.base09, modifiers: ["underline"]}
				"markup.link.text":          #hex.base08
				"markup.raw":                #hex.base09
				diagnostic:                  {modifiers: ["underline"]}
				error:                       #hex.base08
				warning:                     #hex.base0A
				info:                        #hex.base0D
				hint:                        #hex.base0C
			}
		}
	}
}
