vim.g.localleader = "\\"
-- vim.keymap.set("n", "<localleader>rc", ":!gcc -o %:r % && %:r<CR>", {desc="execute c code"})

local function run_and_display_c()
	local current_win = vim.api.nvim_get_current_win()
	local source_file = vim.fn.expand("%:p") -- Absolute path of the source file
	local output_file = vim.fn.expand("%:p:r") -- Absolute path for the output file

	local cmd = string.format("gcc -o '%s' '%s' && '%s' 2>&1", output_file, source_file, output_file)
	local output = vim.fn.system(cmd)

	-- Find the existing buffer or create a new one
	local buf_name = "C Output"
	local buf = vim.fn.bufnr(buf_name)

	if buf == -1 then
		vim.cmd("set splitbelow")
		vim.cmd("split | enew")
		vim.api.nvim_buf_set_name(0, buf_name)
		buf = vim.fn.bufnr()

		vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
		vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
		vim.api.nvim_buf_set_option(buf, "swapfile", false)

	else
		local win_id = vim.fn.bufwinnr(buf)
		if win_id == -1 then
			vim.cmd("set splitbelow")
			vim.cmd("split | buffer " .. buf)
		else
			vim.cmd(win_id .. "wincmd w")
		end
	end

	-- Prepare the output lines
	local lines = vim.split(output, "\n")
	table.insert(lines, "-----------🌟-----------")  -- Add separator line at the end

	-- Append new output to the buffer
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	-- Check if the buffer is empty
	if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "" then
		-- If empty, start with a separator line
		table.insert(lines, 1, "-----------🌟-----------")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	else
		-- If not empty, just append the new lines
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
	end

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.cmd("normal! G")  -- Move cursor to the bottom of the buffer

	-- Return to the original window
	vim.api.nvim_set_current_win(current_win)
end

-- Map the function to <localleader>rc
vim.keymap.set("n", "<localleader>rc", run_and_display_c, { desc = "Execute and display C output" })

