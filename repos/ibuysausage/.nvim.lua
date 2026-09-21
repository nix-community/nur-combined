vim.api.nvim_create_user_command("UpdatePkgGeneric", function()
	local bufnr = 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content = table.concat(lines, "\n")

	local owner = content:match('owner%s*=%s*"([^"]+)"')
	local repo = content:match('repo%s*=%s*"([^"]+)"')

	if not owner or not repo then
		vim.notify("Could not find owner or repo in this file", vim.log.levels.ERROR)
		return
	end

	vim.notify("Fetching latest commit for " .. owner .. "/" .. repo, vim.log.levels.INFO)

	vim.system(
		{ "git", "ls-remote", string.format("https://github.com/%s/%s.git", owner, repo), "HEAD" },
		{ text = true },
		function(res)
			if res.code ~= 0 then
				vim.schedule(function()
					vim.notify("git ls-remote failed", vim.log.levels.ERROR)
				end)
				return
			end

			local full_rev = res.stdout:match("([a-fA-F0-9]+)%s+HEAD")
			if not full_rev then
				return
			end
			local short_rev = full_rev:sub(1, 7)

			local url = string.format("https://github.com/%s/%s/archive/%s.tar.gz", owner, repo, full_rev)
			vim.system({ "nix-prefetch-url", "--unpack", url }, { text = true }, function(hash_res)
				if hash_res.code ~= 0 then
					vim.schedule(function()
						vim.notify("Hash prefetch failed", vim.log.levels.ERROR)
					end)
					return
				end

				-- Convert base32 to SRI hash or use base32 depending on legacy sha256 field
				local raw_hash = vim.trim(hash_res.stdout)
				-- nix to SRI if needed, or pass base32 directly if your nix expects base32 for sha256 = "..."
				vim.system({ "nix", "hash", "to-sri", "--type", "sha256", raw_hash }, { text = true }, function(sri_res)
					local final_hash = sri_res.code == 0 and vim.trim(sri_res.stdout) or ("sha256-" .. raw_hash)

					vim.schedule(function()
						local new_lines = {}
						for _, line in ipairs(lines) do
							line = line:gsub('version%s*=%s*"[^"]+"', string.format('version = "%s"', short_rev))
							line = line:gsub('sha256%s*=%s*"[^"]+"', string.format('sha256 = "%s"', final_hash))
							table.insert(new_lines, line)
						end
						vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
						vim.notify(string.format("Updated package -> version: %s", short_rev), vim.log.levels.INFO)
					end)
				end)
			end)
		end
	)
end, { desc = "Generic GitHub package updater for current buffer" })

vim.keymap.set("n", "<leader>up", ":UpdatePkgGeneric<CR>", { buffer = true, silent = true })
