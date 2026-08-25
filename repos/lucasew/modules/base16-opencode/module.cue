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
		".config/opencode/themes/workspaced.json": {
			type: "json"
			values: {
				"$schema": "https://opencode.ai/theme.json"
				defs: {
					base00: #hex.base00
					base01: #hex.base01
					base02: #hex.base02
					base03: #hex.base03
					base04: #hex.base04
					base05: #hex.base05
					base06: #hex.base06
					base07: #hex.base07
					base08: #hex.base08
					base09: #hex.base09
					base0A: #hex.base0A
					base0B: #hex.base0B
					base0C: #hex.base0C
					base0D: #hex.base0D
					base0E: #hex.base0E
					base0F: #hex.base0F
				}
				theme: {
					primary:                {dark: "base0D", light: "base0C"}
					secondary:              {dark: "base0E", light: "base0A"}
					accent:                 {dark: "base0F", light: "base09"}
					error:                  {dark: "base08", light: "base08"}
					warning:                {dark: "base0A", light: "base0E"}
					success:                {dark: "base0B", light: "base0B"}
					info:                   {dark: "base0C", light: "base0D"}
					text:                   {dark: "base05", light: "base06"}
					textMuted:              {dark: "base03", light: "base04"}
					background:             {dark: "base00", light: "base07"}
					backgroundPanel:        {dark: "base01", light: "base06"}
					backgroundElement:      {dark: "base02", light: "base05"}
					border:                 {dark: "base03", light: "base02"}
					borderActive:           {dark: "base04", light: "base01"}
					borderSubtle:           {dark: "base05", light: "base03"}
					diffAdded:              {dark: "base0B", light: "base0B"}
					diffRemoved:            {dark: "base08", light: "base08"}
					diffContext:            {dark: "base03", light: "base02"}
					diffHunkHeader:         {dark: "base09", light: "base09"}
					diffHighlightAdded:     {dark: "base0B", light: "base0B"}
					diffHighlightRemoved:   {dark: "base08", light: "base08"}
					diffAddedBg:            {dark: "base01", light: "base06"}
					diffRemovedBg:          {dark: "base01", light: "base06"}
					diffContextBg:          {dark: "base01", light: "base01"}
					diffLineNumber:         {dark: "base03", light: "base02"}
					diffAddedLineNumberBg:   {dark: "base01", light: "base06"}
					diffRemovedLineNumberBg: {dark: "base01", light: "base06"}
					markdownText:            {dark: "base05", light: "base05"}
					markdownHeading:         {dark: "base0E", light: "base0E"}
					markdownLink:            {dark: "base0D", light: "base0D"}
					markdownLinkText:        {dark: "base0A", light: "base0A"}
					markdownCode:            {dark: "base0B", light: "base0B"}
					markdownBlockQuote:      {dark: "base0A", light: "base0A"}
					markdownEmph:            {dark: "base0A", light: "base0A"}
					markdownStrong:          {dark: "base09", light: "base09"}
					markdownHorizontalRule:   {dark: "base04", light: "base04"}
					markdownListItem:         {dark: "base0D", light: "base0D"}
					markdownListEnumeration:  {dark: "base0A", light: "base0A"}
					markdownImage:           {dark: "base0D", light: "base0D"}
					markdownImageText:       {dark: "base0A", light: "base0A"}
					markdownCodeBlock:        {dark: "base05", light: "base05"}
					syntaxComment:           {dark: "base03", light: "base02"}
					syntaxKeyword:           {dark: "base0E", light: "base0E"}
					syntaxFunction:          {dark: "base0D", light: "base0D"}
					syntaxVariable:          {dark: "base08", light: "base08"}
					syntaxString:            {dark: "base0B", light: "base0B"}
					syntaxNumber:            {dark: "base09", light: "base09"}
					syntaxType:              {dark: "base0A", light: "base0A"}
					syntaxOperator:          {dark: "base0A", light: "base0A"}
					syntaxPunctuation:       {dark: "base05", light: "base05"}
				}
			}
		}
	}
}
