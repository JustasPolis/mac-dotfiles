return {
	dir = "git-quickfix",
	virtual = true,
	config = function()
		local cwd = vim.fn.getcwd()
		local gc = "git -C " .. vim.fn.shellescape(cwd)
		local toplevel = vim.fn.system(gc .. " rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
		local snapshot_dir = "/tmp/nvim-git-snapshot" .. toplevel

		local function create_snapshot()
			vim.fn.system("rm -rf " .. vim.fn.shellescape(snapshot_dir))
			vim.fn.system("cp -rc " .. vim.fn.shellescape(toplevel) .. " " .. vim.fn.shellescape(snapshot_dir))
			-- restore snapshot to HEAD state
			vim.fn.system("git -C " .. vim.fn.shellescape(snapshot_dir) .. " checkout -- .")
			vim.fn.system("git -C " .. vim.fn.shellescape(snapshot_dir) .. " clean -fd")
		end

		local function update_git_qf()
			local modified = vim.fn.systemlist(gc .. " diff --name-only -- . 2>/dev/null")
			local untracked = vim.fn.systemlist(gc .. " ls-files --others --exclude-standard -- . 2>/dev/null")
			local items = {}
			for _, file in ipairs(modified) do
				if file ~= "" then
					table.insert(items, { filename = toplevel .. "/" .. file, lnum = 1, text = "modified" })
				end
			end
			for _, file in ipairs(untracked) do
				if file ~= "" then
					table.insert(items, { filename = toplevel .. "/" .. file, lnum = 1, text = "untracked" })
				end
			end
			vim.fn.setqflist({}, "r", { title = "Git Changes", items = items })
		end

		local function open_diff()
			local entry = vim.fn.getqflist()[vim.fn.line(".")]
			if not entry or entry.bufnr == 0 then
				return
			end
			local filepath = vim.api.nvim_buf_get_name(entry.bufnr)
			local relpath = filepath:sub(#toplevel + 2)
			local snapshot_file = snapshot_dir .. "/" .. relpath

			if not vim.uv.fs_stat(snapshot_file) then
				vim.notify("No snapshot version: " .. relpath, vim.log.levels.WARN)
				return
			end

			vim.cmd("wincmd k")
			vim.cmd("edit " .. vim.fn.fnameescape(filepath))
			vim.cmd("diffthis")
			vim.cmd("vsplit " .. vim.fn.fnameescape(snapshot_file))
			vim.cmd("diffthis")
		end

		local function watch(path)
			local w = vim.uv.new_fs_event()
			if w and vim.uv.fs_stat(path) then
				w:start(path, { recursive = true }, vim.schedule_wrap(function()
					update_git_qf()
				end))
			end
		end
		local git_dir = vim.fn.finddir(".git", cwd .. ";")
		if git_dir ~= "" then
			watch(git_dir)
		end
		watch(cwd)

		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = update_git_qf,
		})

		vim.api.nvim_create_user_command("GitChanges", function()
			create_snapshot()
			update_git_qf()
			vim.cmd("copen")
		end, {})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "qf",
			callback = function()
				vim.keymap.set("n", "<CR>", open_diff, { buffer = true })
			end,
		})

		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				vim.fn.system("rm -rf " .. vim.fn.shellescape(snapshot_dir))
			end,
		})
	end,
}
