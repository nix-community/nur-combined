package workspaced

import "strings"

workspaced: {

	desktop: wallpaper: {
		dir:     "\(workspaced.runtime.dotfiles_root)/assets/wallpapers"
		default: "wall.jpg"
	}

	hosts: {
		riverwood: {
			ips:  ["100.82.35.120", "192.168.69.2"]
			port: 22
		}
		whiterun: {
			ips:  ["100.85.38.19", "192.168.69.1"]
			mac:  "a8:a1:59:9c:ab:32"
			port: 22
		}
		ravenrock: {
			ips:  ["100.122.87.59"]
			port: 22
		}
		phone: {
			ips:  ["100.76.88.29", "192.168.69.4"]
			port: 22
		}
	}


	drivers: {
		"github.com/lucasew/workspaced/pkg/driver/terminal.Driver": {
			"terminal_kitty": 70
		}
	}


	lazy_tools: {
		zed: {
			ref: "github:zed-industries/zed"
			bins: ["zed"]
		}
		codex: {
			ref: "github:openai/codex"
			bins: ["codex"]
			global: true
		}
		bun: {
			ref: "github:oven-sh/bun"
			bins: ["bun"]
		}
		docker_compose: {
			ref: "github:docker/compose"
			global: true
			bins: ["docker-compose"]
		}
		fd: {
			ref: "github:sharkdp/fd"
			global: true
			bins: ["fd"]
		}
		difftastic: {
			ref: "github:Wilfred/difftastic"
			global: true
			bins: ["difft"]
		}
		opencode: {
			ref: "github:anomalyco/opencode"
			global: true
			bins: ["opencode"]
		}
		rclone: {
			ref: "github:rclone/rclone"
			global: true
			bins: ["rclone"]
		}
		rtk: {
			ref: "github:rtk-ai/rtk"
			global: true
			bins: ["rtk"]
		}
		ripgrep: {
			ref: "github:burntsushi/ripgrep"
			global: true
			bins: ["rg"]
		}
		fzf: {
			ref: "github:junegunn/fzf"
			global: true
			bins: ["fzf", "fzf-tmux"]
		}
		ruff: {
			ref: "github:astral-sh/ruff"
			bins: ["ruff"]
		}
		shfmt: {
			ref: "github:patrickvane/shfmt"
			bins: ["shfmt"]
		}
		shellcheck: {
			ref: "github:koalaman/shellcheck"
			bins: ["shellcheck"]
		}
		sops: {
			ref: "github:getsops/sops"
			bins: ["sops"]
		}
		uv: {
			ref: "github:astral-sh/uv"
			global: true
			bins: ["uv", "uvx"]
		}
		terraform: {
			ref: "github:hashicorp/terraform"
			bins: ["terraform"]
		}
		tflint: {
			ref: "github:terraform-linters/tflint"
			bins: ["tflint"]
		}
		go: {
			ref: "golang"
			bins: ["go", "gofmt"]
		}
		golangci_lint: {
			ref: "github:golangci/golangci-lint"
			bins: ["golangci-lint"]
		}
		docker_language_server: {
			ref: "github:docker/docker-language-server"
			global: true
			bins: ["docker-langserver"]
		}
		ffmpeg: {
			ref: "github:ffbinaries/ffbinaries-prebuilt"
			bins: ["ffmpeg", "ffprobe"]
		}
		helix: {
			ref: "github:helix-editor/helix"
			global: true
			bins: ["hx"]
		}
		ltex_ls: {
			ref: "github:valentjn/ltex-ls"
			global: true
			bins: ["ltex-ls"]
		}
		typos_lsp: {
			ref: "github:tekumara/typos-lsp"
			global: true
			bins: ["typos-lsp"]
		}
		refactree: {
			ref: "github:lucasew/refactree"
			global: true
			bins: ["rft"]
		}
		contapila: {
			ref: "github:lewtec/contapila"
			global: true
			bins: ["contapila"]
		}
		// bash_language_server: {
		// 	ref: "mise:npm:bash-language-server"
		// 	global: true
		// 	bins: ["bash-language-server"]
		// }
		// vscode_langservers: {
		// 	ref: "mise:npm:vscode-langservers-extracted"
		// 	bins: [
		// 		"vscode-html-language-server",
		// 		"vscode-css-language-server",
		// 		"vscode-json-language-server",
		// 		"vscode-eslint-language-server",
		// 	]
		// }
		clang: {
			ref: "llvm"
			bins: ["clang", "clang-cpp"]
		}
		jless: {
			ref: "github:PaulJuliusMartinez/jless"
			global: true
			bins: ["jless"]
		}
		gh: {
			ref: "github:cli/cli"
			global: true
			bins: ["gh"]
		}
		ast_grep: {
			ref: "github:ast-grep/ast-grep"
			global: true
			bins: ["ast-grep", "sg"]
		}
		scc: {
			ref: "github:boyter/scc"
			global: true
			bins: ["scc"]
		}
		tirith: {
			ref: "tirith"
			global: true
			bins: ["tirith"]
		}
		jujutsu: {
			ref: "github:jj-vcs/jj"
			global: true
			bins: ["jj"]
		}
		pi: {
			ref: "github:badlogic/pi-mono"
			global: true
			bins: ["pi"]
		}
		coder: {
			ref: "github:coder/coder"
			global: true
			bins: ["coder"]
		}
		herdr: {
			ref: "github:ogulcancelik/herdr"
			global: true
			bins: ["herdr"]
		}
		grok: {
			ref: "grok-build"
			global: true
			bins: ["grok"]
		}
	}

	modules: {
		fontconfig: {
			input: "self:modules/fontconfig"
			enable:      true
			config: {
				serif:       "Fira Code"
				sans_serif:  "Fira Code"
				monospace:   "Fira Code"
				emoji:       "Noto Color Emoji"
			}
		}
		
		"script-directory": {input: "self:modules/script-directory", enable: true}
		mise: {input: "self:modules/mise", enable: true}
		hermes: {input: "self:modules/hermes", enable: true}
		nix: {input: "self:modules/nix", enable: true}
	}
}

// ========== Base 16
workspaced: {
	inputs: {
		papirus: {
			from: "github:PapirusDevelopmentTeam/papirus-icon-theme"
			version: "HEAD"
		}
	}
	modules: {
		icons: {
			input: "core:base16-icons-linux"
			enable: !workspaced.runtime.is_phone && !(workspaced.runtime.hostname == "ravenrock")
			config: {
				input_dir: "papirus:Papirus"
			}
		}

		base16: {
			input: "self:modules/base16"
			enable: true
			config: {
				// From: workspaced utils palette generate assets/wallpapers/bliss.jpg --driver materialyou --polarity dark
				base00: "131313"
				base01: "131313"
				base02: "1f1f1f"
				base03: "2a2a2a"
				base04: "474747"
				base05: "e2e2e2"
				base06: "c6c6c6"
				base07: "e2e2e2"
				base08: "ffb4ab"
				base09: "c0cbac"
				base0A: "a0d0cb"
				base0B: "a9d472"
				base0C: "304f00"
				base0D: "404a33"
				base0E: "1f4e4b"
				base0F: "93000a"
			}
		}

		"base16-shell":   {input: "self:modules/base16-shell", enable: true}
		"base16-helix":   {input: "self:modules/base16-helix", enable: true}
		"base16-vscode":  {input: "self:modules/base16-vscode", enable: true}
		"base16-sway":    {input: "self:modules/base16-sway", enable: true}
		"base16-gtk":     {input: "self:modules/base16-gtk", enable: true}
		"base16-rofi":    {input: "self:modules/base16-rofi", enable: true}
		"base16-dunst":   {input: "self:modules/base16-dunst", enable: true}
		"base16-tmux":    {input: "self:modules/base16-tmux", enable: true}
		"base16-opencode": {input: "self:modules/base16-opencode", enable: true}
		"base16-swaylock": {input: "self:modules/base16-swaylock", enable: true}
	}
}

// Webapps
#default_borderless_browser: "helium"

workspaced: {
	browser: {
		default: "zen"
		webapp:  "helium"
	}
	lazy_tools: {
		helium_browser: {
			ref: "github:imputnet/helium-linux"
			global: true
			bins: ["helium"]
		}
	}
	modules: {
		webapp: {
			input: "self:modules/webapp"
			enable: true
			config: {
				apps: {
					main: {
						browser: #default_borderless_browser
						desktop_name: "Navegador"
						url: ""
					}
					workx: {
						browser: #default_borderless_browser
						profile: "XAI"
						desktop_name: "Trabson"
						url: ""
						extra_flags: [
							"--proxy-server",
							"socks5h://job-xai.stargazer-shark.ts.net:1080"
						]
					}
					"castable-iframe": {
						browser: #default_borderless_browser
						url:     "https://castable-iframe.vercel.app/"
						profile: "castable-iframe"
					}
					gemini: {
						browser: #default_borderless_browser
						url: "https://gemini.google.com"
					}
					element: {
						browser: #default_borderless_browser
						url:          "https://app.element.io"
						profile:      "element"
						desktop_name: "Element Matrix"
					}
					reemo: {
						browser: #default_borderless_browser
						url:          "https://reemo.io"
						desktop_name: "Remote control"
					}
					clickup: {
						browser: #default_borderless_browser
						url:          "https://clickup.com"
						desktop_name: "ClickUp"
					}
					facebook: {
						browser: #default_borderless_browser
						url:          "https://facebook.com"
						profile:      "facebook"
						desktop_name: "Facebook"
					}
					pocketcasts: {
						browser: #default_borderless_browser
						url:          "https://pocketcasts.com"
						desktop_name: "PocketCasts"
						icon:         "sound"
					}
					twitter: {
						browser: #default_borderless_browser
						url:          "https://twitter.com"
						profile:      "twitter"
						desktop_name: "Twitter"
					}
					"discord-pessoal": {
						browser: #default_borderless_browser
						url:          "https://discord.com/channels/me"
						profile:      "discord-pessoal"
						desktop_name: "Discord (pessoal)"
					}
					"discord-profissional": {
						browser: #default_borderless_browser
						url:          "https://discord.com/channels/me"
						profile:      "discord-profissional"
						desktop_name: "Discord (profissional)"
					}
					"youtube-tv": {
						browser: #default_borderless_browser
						url:          "https://youtube.com/tv"
						profile:      "youtube-tv"
						desktop_name: "YouTube (UI para TV)"
					}
					whatsapp: {
						browser: #default_borderless_browser
						url:          "web.whatsapp.com"
						profile:      "zap"
						desktop_name: "WhatsApp"
					}
					notion: {
						browser: #default_borderless_browser
						url:          "notion.so"
						profile:      "notion"
						desktop_name: "Notion"
					}
					duolingo: {
						browser: #default_borderless_browser
						url:          "duolingo.com"
						desktop_name: "Duolingo"
					}
					"youtube-music": {
						browser: #default_borderless_browser
						url:          "music.youtube.com"
						profile:      "youtubemusic"
						desktop_name: "Youtube Music"
					}
					planttext: {
						browser: #default_borderless_browser
						url:          "https://www.planttext.com/"
						desktop_name: "PlantText"
					}
					rainmode: {
						browser: #default_borderless_browser
						url:          "https://youtu.be/mPZkdNFkNps"
						desktop_name: "Tocar som de chuva"
						icon:         "weather-showers"
					}
					gmail: {
						browser: #default_borderless_browser
						url:          "gmail.com"
						desktop_name: "GMail"
					}
					keymash: {
						browser: #default_borderless_browser
						url:          "https://keyma.sh/learn"
						desktop_name: "keyma.sh: Keyboard typing train"
					}
					calendar: {
						browser: #default_borderless_browser
						url:          "https://calendar.google.com/calendar/u/0/r/customday"
						desktop_name: "Calendário"
						icon:         "x-office-calendar"
					}
					"twitch-dashboard": {
						browser: #default_borderless_browser
						url: "https://dashboard.twitch.tv/stream-manager"
					}
					"geforce-now": {
						browser: #default_borderless_browser
						url: "play.geforcenow.com"
					}
				}
			}
		}
	}
}


// =========== Backup
#rsyncnet_user: "de3163@de3163.rsync.net"
#is_whiterun: workspaced.runtime.hostname == "whiterun"
#is_riverwood: workspaced.runtime.hostname == "riverwood"
#is_phone: workspaced.runtime.is_phone
#remote_path: "backup/lucasew"

workspaced: {
	backup: {
		actions: [
			for repo_name in [
				"personal-zettel-obsidian",
				"personal-beancount",
				"personal-keepass",
				"personal-bookmarks",
				"personal-decsync",
				"personal-zettel-org",
			] if (#is_whiterun || #is_phone || #is_riverwood) {
				name: "git repo \(repo_name)"
				kind: "git_repo_sync"
				src:  "\(workspaced.runtime.home)/.personal/\(repo_name)"
				dst:  "\(#rsyncnet_user):git-personal/\(repo_name)"
			},
			if (#is_whiterun || #is_riverwood) {
				name: "cantgit"
				kind: "rsync"
				skip_permissions: true
				src:  "\(workspaced.runtime.home)/WORKSPACE/CANTGIT/"
				dst:  "\(#rsyncnet_user):\(#remote_path)/CANTGIT"
			},
			if #is_phone {
				name:     "camera"
				kind:     "rsync"
				skip_permissions: true
				src:      "/sdcard/DCIM/Camera/"
				dst:      "\(#rsyncnet_user):\(#remote_path)/camera"
				excludes: [".thumbnails"]
			},
			if #is_phone {
				name:     "pictures"
				kind:     "rsync"
				skip_permissions: true
				src:      "/sdcard/Pictures/"
				dst:      "\(#rsyncnet_user):\(#remote_path)/pictures"
				excludes: [".thumbnails"]
			},
			if #is_phone {
				name:     "whatsapp media"
				kind:     "rsync"
				skip_permissions: true
				src:      "/sdcard/Android/media/com.whatsapp/WhatsApp/Media/"
				dst:      "\(#rsyncnet_user):\(#remote_path)/WhatsApp"
				excludes: [".Links", ".Statuses"]
			},
			if #is_phone {
				name: "whatsapp backups"
				kind: "rsync"
				skip_permissions: true
				src:  "/sdcard/Android/media/com.whatsapp/WhatsApp/Backups/"
				dst:  "\(#rsyncnet_user):\(#remote_path)/WhatsApp"
			},
			// if workspaced.runtime.is_phone {
			// 	name: "termux packages list"
			// 	kind: "termux_packages_snapshot"
			// 	output: "\(workspaced.runtime.home)/.cache/backup/termux/packages.txt"
			// },
			if #is_phone {
				name: "termux sync home"
				kind: "rsync"
				skip_permissions: true
				src:  "\(workspaced.runtime.home)/.cache/backup/termux/"
				dst:  "\(#rsyncnet_user):\(#remote_path)/termux/"
			},
			if #is_phone {
				name:      "termux archive"
				kind:      "archive"
				input_dir: "\(workspaced.runtime.home)/.cache/backup/termux"
				output:    "\(workspaced.runtime.home)/.cache/backup/termux.tar"
				format:    "tar"
			},
			if #is_phone {
				name: "termux archive upload"
				kind: "rsync"
				skip_permissions: true
				src:  "\(workspaced.runtime.home)/.cache/backup/termux.tar"
				dst:  "\(#rsyncnet_user):\(#remote_path)/termux.tar"
			},
		]
	}
}

// ========== Agent skills

#skills: {
	if !#is_phone {
		lewtec: {
			from: "github:lewtec/skills"
			version: "cc6a092360b137d55de349ea9f6c4eb98ee29746"
		}
	}
	workspaced: {
		from: "github:lucasew/workspaced"
	}
	// Local skills come straight from the workspace tree.
	// We reference the built-in "self" input directly below instead of
	// creating a pointless named alias like "skills_local_skills".
	local_skills: {
		from: "self:skills"
	}
}

#skills: [string]: {
	from: string
	version: string | *"HEAD"
	origin: string | *"skills"
	destination: string | *""
}

// Remote (github etc.) skills need named inputs for locking/version pins.
// Local self-based ones do not — we reference "self:..." directly.
// core:place TargetBase is $HOME, so destinations are under ~/.agents/skills.
workspaced: {
	inputs: {
		for name, src in #skills if !strings.HasPrefix(src.from, "self") {
			"skills_\(name)": {
				from: src.from
				version: src.version
			}
		}
	}

	// Generate place modules for all skills.
	// For self sources we use the direct "self:..." ref (no named input needed).
	modules: {
		for name, value in #skills if !strings.HasPrefix(value.from, "self") {
			"skills_\(name)": {
				from: "core:place"
				config: {
					items: {
						".agents/skills/\(value.destination)": "skills_\(name):\(value.origin)"
					}
				}
			}
		}
		for name, value in #skills if strings.HasPrefix(value.from, "self") {
			"skills_\(name)": {
				from: "core:place"
				config: {
					items: {
						".agents/skills/\(value.destination)": "self:\(value.origin)"
					}
				}
			}
		}
	}
}

