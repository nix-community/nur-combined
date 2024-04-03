{ pkgs, ... }:
{
	programs.neovim = {
		enable = true;
		withPython3 = true;
		withNodeJs = true;
		plugins = with pkgs.vimPlugins; [
			haskell-vim
			plenary-nvim
			# typst ... TODO
			rust-vim
			dracula-vim
      lf-vim
		];

		coc.enable = true;
		coc.settings = {
      "rust-analyzer.cargo.sysroot" = "discover";
		  "rust-analyzer.server.path" = "/etc/profiles/per-user/me/bin/rust-analyzer";
		  "coc.preferences.extensionUpdateCheck" = "never";
		  "cSpellExt.enableDictionaries" = [ "german" ];
		  "cSpell.language" = "en,de";
		  "rust-analyzer.enable" = true;
		  "rust-analyzer.diagnostics.enable" = true;
		  "rust-analyzer.checkOnSave.enable" = false;
		  "languageserver" = {
			  "vhdl" = {
				  "command" = "/home/sebastian/work/config/nvim/language-servers/vhdl/vhdl-tool";
				  "args" = [ "lsp" ];
				  "filetypes" = [ "vhdl" ];
			  };
				"csharp-ls" = {
					"command" = "csharp-ls";
					"filetypes" = [ "cs" ];
					"rootPatterns" = [ "*.csproj" ".vim/" ".git/" ".hg/" ];
				};
				"nix" = {
					"command" = "nil";
					"filetypes" = [ "nix" ];
					"rootPatterns" =  [ "flake.nix" ];
				};
		  };
		  "svelte.enable-ts-plugin" = true;
		};

		extraConfig = ''

			syntax enable
			filetype plugin indent on

			" the nord colorscheme
			"source ~/.config/nvim/plugins/nord-vim/colors/nord.vim
			colorscheme dracula

			autocmd BufReadPost * call Setup()

			function Setup()
				if index(["typst", "haskell", "tex", "c", "rust", "js", "vhdl", "nix"], &syntax) >= 0
					execute "call Setup_" . &syntax . "()"
				endif
			endfunction

			""""""""""""""""""""""""""""" mappings """""""""""""""""""""""""""""
			nmap <LEFT> gT
			map <RIGHT> gt
			imap <LEFT> <ESC>gT
			imap <RIGHT> <ESC>gt

			map <C-l> gt
			map <C-h> gT
			imap <C-l> <ESC>gt
			imap <C-h> <ESC>gT

			:tnoremap <Esc> <C-\><C-n>
			:tmap <C-h> <Esc><C-h>
			:tmap <C-l> <Esc><C-l>


         nmap <C-n> :LfNewTab<ENTER>
			cnoreabbrev e LfCurrentFile
         let g:floaterm_width = 0.88
         let g:floaterm_height = 0.88

         nmap <C-w> :wq<ENTER>
         imap <C-w> :wq<ENTER>
			cnoreabbrev ta LfNewTab
			cnoreabbrev hh TSHighlightCapturesUnderCursor

			nnoremap ga :call CocActionAsync('doHover')<ENTER>
			nnoremap gd :call CocActionAsync('jumpDefinition')<ENTER>

			nmap <C-,> A;<Esc>

			nmap <C-d> <C-d>zz
			nmap <C-u> <C-u>zz

			nmap # *

			nmap ' /aöeiääääaöfj<ENTER>:<ESC>

			nmap j gj
			nmap k gk
			nmap 0 g0
			nmap $ g$
			inoremap <C-BS> <ESC>bcw

			cnoreabbrev s set filetype=javascriptreact

			"nnoremap <C-n> <cmd>lua require('renamer').rename()<cr>

			"cmap t <TAB>
			"cmap <C-j> <C-i>
			"cnoremap <C-k> <S-TAB>
			"cnoremap <C-i> <C-n>
			"cnoremap <TAB> <C-n>
			"cnoremap <C-j> <C-i>
			"cnoremap <C-j> <TAB>
			"cnoremap <C-n> <TAB>
			noremap <ENTER> i<ENTER>
			set nohlsearch
			set backupdir=~/.local/state/nvim/backup

			cnoreabbrev cdf :lcd %:p:h
			cnoreabbrev tspell call CocAction('toggleExtension', 'coc-spell-checker')



			""""""""""""""""""""""""""""" neovide """""""""""""""""""""""""""""

			" Being able to paste system clipboard in neovide
			imap <C-v> <ESC>"+pi
			nmap <C-v> "+p

			vmap <C-c> "+y


			let g:neovide_cursor_vfx_mode = "wireframe"
			set guifont=Hack:h10
			"set guifont=Monospace:h6



			""""""""""""""""""""""""""""" coc """""""""""""""""""""""""""""

			imap <C-k> <UP>
			imap <C-j> <DOWN>
			imap <C-ENTER> <C-j><ENTER>
			imap <C-s> <C-j><C-j><ENTER>

			"let g:coc_snippet_next = ${"''"}
			"let g:coc_snippet_prev = ${"''"}

			"inoremap <expr> <c-j>
				"\ pumvisible() ? "\<DOWN>" :
				"\ coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetNext', [])<cr>" :
				"\ "\<c-j>"
			"inoremap <expr> <c-k>
				"\ pumvisible() ? "\<UP>" :
				"\ coc#jumpable() ? "\<c-r>=coc#rpc#request('snippetPrev', [])<cr>" :
				"\ "\<c-k>"

			" use enter for completing with coc
			inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"


			function! s:TernimalRun(cmd)
			  execute '5new'
			  call termopen(a:cmd, {
					  \ 'on_exit': 's:OnExit',
					  \ 'buffer_nr': bufnr('%'),
					  \})
			  execute 'wincmd p'
			endfunction



			""""""""""""""""""""""""""""" languages """""""""""""""""""""""""""""

			" ###### nix ###### "
			function! Setup_nix()
            " use spaces for indentation with nix .. so that multiline strings get stripped of tabs
            set smartindent
            set tabstop=2
            set expandtab
            set shiftwidth=2

         endfunction





			" ###### typst ###### "
			"Typst highlight customisation
			function! Setup_typst()
				" set highlight of Headings to not be underlined
				"autocmd TermClose * echo v:shell_error
				"au TermClose * call feedkeys("ii")
				:hi! link typstMarkupHeading markdownH1
				:hi markdownH1 cterm=bold, gui=bold

				" to keep indent the same when making a "-" list
				set cindent

				cnoreabbrev c call SaveAndCompile_typst()

				function! OnExit(job_id, exit_code, event) dict
					let lines = line("$")
					if a:exit_code == "0"
						"echo "good"
						call feedkeys("ii")
					else
						"echo "bad"
					endif


				endfunction

			endfunction


			function! SaveAndCompile_typst()
				:silent w
			  "execute '5new'
			  let path = expand('%:p')
				:belowright new 20split
				":belowright 20split call termopen("echo hello")
				call termopen("typst --root ~/work/config/typst --font-path ~/config/typst/fonts compile " . path . " out.pdf", {
					  \ 'on_exit': 'OnExit',
					  \ 'buffer_nr': bufnr('%'),
					  \})
			  "execute 'wincmd p'
				":execute '!typst compile ' . expand('%:p')
				":belowright 20split term://typst compile doku.typ
				":belowright 20split 
				"s:TernimalRun("!echo hello")
			endfunction




			" ###### js ###### "
			set tabstop=3 shiftwidth=3
			function! Setup_js()

			"autocmd Filetype js set tabstop=2 shiftwidth=2 expandtab
				set tabstop=4 shiftwidth=4
				cnoreabbrev c echo JSSSSSSSSSSSSSSSSSS is interpreted.....
			" autocmd Filetype  setlocal ts=2 sw=2 expandtab

			endfunction



			" ###### c ###### "
			function! Setup_c()
				cnoreabbrev c call SaveAndCompile_c()
			endfunction


			function! SaveAndCompile_c()
					:w
					execute '!gcc main.c -o main.out; if [ $? -ne 0 ]; then echo ======= ERROR =======; exit; fi ; echo "======= NO ERROR = PROGRAMM ======="; ./main.out'
			endfunction



			" ###### latex ###### "

			let g:UltiSnipsExpandTrigger = '<tab>'
			let g:UltiSnipsJumpForwardTrigger = '<c-j>'
			let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

			function! Setup_tex()
				set tabstop=2 shiftwidth=2
				"command SaveAndCompilelatex
				cnoreabbrev c call SaveAndCompile_latex()
				cnoreabbrev o call Open_latex()<ENTER>

				function Latex_toggle_comment()
					let line=getline('.')
					let chars = split(line, '\zs') 
					let index = 0
					while 1
						if len(chars) == 0
							return
							break
						endif
						if chars[index] == " "
							let index += 1
						else
							break
						endif
					endwhile
					if chars[index] == "%"
						execute 's@^%@@g'
					else
						execute 's/^/%/g'
					endif
				endfunction

				vnoremap s :call Latex_toggle_comment()<Enter>
			endfunction

			function SaveAndCompile_latex()
				:w
				execute '!pdflatex --output-directory=' . expand('%:p:h') . " " . expand('%:p')
			endfunction

			function Open_latex()
				execute '!zathura ./main.pdf 1>/dev/null 2>/dev/null &'
			endfunction
			" end latex


			" ###### vhdl ###### "

			function! Setup_vhdl()
				function Vhdl_toggle_comment()
					let line=getline('.')
					let chars = split(line, '\zs') 
					let index = 0
					while 1
						if len(chars) == 0
							return
							break
						endif
						if chars[index] == " "
							let index += 1
						else
							break
						endif
					endwhile
					if chars[index] == "-"
						execute 's@^--@@g'
					else
						execute 's/^/--/g'
					endif
				endfunction

				vnoremap s :call Vhdl_toggle_comment()<Enter>

			endfunction

			" ###### haskell ###### "

			function! Setup_haskell()
				set tabstop=4 shiftwidth=4 expandtab

				"command SaveAndCompile_haskell
				cnoreabbrev c call SaveAndCompile_haskell()
				"command Debugger_haskell
				cnoreabbrev d call Debugger_haskell()
			endfunction


			function SaveAndCompile_haskell()
				:w
				execute '!ghc ' . @%
			endfunction


			function Debugger_haskell()
				:w
				execute '!ghci ' . @%
			endfunction

			let g:haskell_classic_highlighting = 0
			let g:haskell_indent_if = 3
			let g:haskell_intdent_disable = 0
			let g:haskell_indent_case = 2
			let g:haskell_indent_let = 4
			let g:haskell_indent_where = 6
			let g:haskell_indent_before_where = 2
			let g:haskell_indent_after_bare_where = 2
			let g:haskell_indent_do = 3
			let g:haskell_indent_in = 1
			let g:haskell_indent_guard = 2
			let g:haskell_indent_case_alternative = 1
			let g:cabal_indent_section = 2



			" ###### rust ###### "

			function! Setup_rust()

				vnoremap s :call Rust_toggle_comment()<Enter>

				cnoreabbrev c call Cargo_ceck()
				cnoreabbrev r call Cargo_run()
				cnoreabbrev b call Cargo_build()

			endfunction

			function Cargo_build()
				:w
				":term cargo build
				:belowright 20split term://cargo build
			endfunction

			function Cargo_run()
				:w
				":term cargo run
				:belowright 20split term://cargo run
			endfunction

			"tnoremap J :call Cargo_jump()
			augroup MyTermMappings
			  autocmd!
			  autocmd TermOpen * nnoremap <buffer> J :lua Cargo_jump()<Enter>
			augroup END

			function Cargo_ceck()
				:w
				:belowright 20split term://cargo check
			endfunction

			function Rust_toggle_comment()
				let line=getline('.')
				let chars = split(line, '\zs') 
				let index = 0
				while 1
					if len(chars) == 0
						return
						break
					endif
					if chars[index] == " "
						let index += 1
					else
						break
					endif
				endwhile
				if chars[index] == "/"
					execute 's@^//@@g'
				else
					execute 's/^/\/\//g'
				endif
			endfunction
		'';

		extraLuaConfig = ''
			function Cargo_jump()
				local line,c = unpack(vim.api.nvim_win_get_cursor(0))
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				print("hiiiiiiiiiii")
				print("hiiiiiiiiiii")
				print("hiiiiiiiiiii")
				print("hiiiiiiiiiii")
				print("hiiiiiiiiiii")
        		print("lines", lines)
        		print("line", line)

				local line_iter = line
				local line_to_jump = nil
				local file_to_jump = nil
				if line == 1 then
					line_iter = 2
				end
				while true do
					if (lines[line_iter]:sub(1,5) == "error") then
						local split_line = mysplit(lines[line_iter +1], ":")
						line_to_jump = split_line[2]
						file_to_jump = split_line[1]:sub(7, -1)
            file_to_jump = file_to_jump:gsub("%s+", "")
						break
					end
					line_iter = line_iter - 1
				end

				local buffers = get_buffers()
				local abs_file_to_jump = vim.fn.getcwd() .. "/" .. file_to_jump

				for i,buf in pairs(buffers) do
					-- local status, name = pcall(function () vim.api.nvim_buf_get_name(buf) end)
					-- if status then print("error getting buf name"); goto continue else print("got name: " .. name) end

					local name = vim.fn["bufname"](buf)
					if name == "" then
            -- print("buf name empty")
            goto continue
          end

					-- print("name: " .. name .. "  file_to_jump: " .. file_to_jump)
					if name == file_to_jump then
						local tab_num = get_tab(name)
						print("jumping to" .. tostring(tab_num))
						-- vim.cmd(tab_num .. "gt")
						-- local keys = vim.api.nvim_replace_termcodes("<ENTER>"..tab_num.."gt", false, false, false)
						-- vim.api.nvim_feedkeys("<ENTER>", "m", true)
						vim.cmd("q")
						vim.api.nvim_feedkeys(tab_num .. "gt", "m", false)
						vim.api.nvim_feedkeys(line_to_jump .. "G", "m", false)
						return
					else
					end

					::continue::
				end
				-- vim.cmd(":tabnew" .. abs_file_to_jump)
			end

			function get_tab(name)
				print("the messssssssssssssssss")
				local listing = vim.api.nvim_command_output("tabs")
				local tab
				local file
				for i,line in pairs(mysplit(listing, "\n")) do
					print("line: " .. line)
					if line:sub(1,8) == "Tab page" then
						tab = line:sub(-1)
						print("tab:", tab)
					else
						file = line:sub(5,-1)
						print("file: " .. file .. " on tab: " .. tostring(tab))
						if file == name then
							return tab
						end
					end
				end
			end

			function mysplit (inputstr, sep)
					  if sep == nil then
								 sep = "%s"
					  end
					  local t={}
					  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
								 table.insert(t, str)
					  end
					  return t
			end


			function dump(o)
				if type(o) == 'table' then
					local s = '{ '
					for k,v in pairs(o) do
						print(k)
						if type(k) ~= 'number' then k = '"'..k..'"' end
						s = s .. '['..k..'] = ' .. dump(v) .. ','
					end
					return s .. '} '
				else
					return tostring(o)
				end
			end

			function get_buffers()
				 local buffers = {}

				 for buffer = 1, vim.fn.bufnr('$') do
					  local is_listed = vim.fn.buflisted(buffer) == 1
							table.insert(buffers, buffer)
				 end

				 return buffers
			end


		'';
	};
}
