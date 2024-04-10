local M = {}

M.setup = function(username)
	M.name = username
end

local has_telescope, _ = pcall(require, "telescope")

if not has_telescope then
	error("This plugins requires nvim-telescope/telescope.nvim to work.")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local mit = require("license.licenses.mit")
local apache2 = require("license.licenses.apache2")
local unlicense = require("license.licenses.unlicense")
local gpl3 = require("license.licenses.gpl3")
local gpl2 = require("license.licenses.gpl2")
local agpl3 = require("license.licenses.agpl3")
local lgpl2 = require("license.licenses.lgpl2")
local epl2 = require("license.licenses.epl2")
local glwts = require("license.licenses.glwts")
local mpl2 = require("license.licenses.mpl2")
local bsd3 = require("license.licenses.bsd3")
local bsd2 = require("license.licenses.bsd2")
local bsl1 = require("license.licenses.bsl1")
local cc0 = require("license.licenses.cc0")

local telescope_license_table = {
	["MIT"] = mit,
	["Apache 2"] = apache2,
	["Unlicense"] = unlicense,
	["GNU General Public License v.3 (GPL3)"] = gpl3,
	["GNU General Public License v.2 (GPL2)"] = gpl2,
	["GNU Affero General Public License v.3 (AGPL3)"] = agpl3,
	["GNU Lesser General Public License v.2.1 (LGPL2)"] = lgpl2,
	["Eclipse Public License v.2 (EPL2)"] = epl2,
	["Good Lock With That Shit"] = glwts,
	["Mozilla Public License 2.0 (MPL2)"] = mpl2,
	["BSD 3-Clause (BSD3)"] = bsd3,
	["BSD 2-Clause (BSD2)"] = bsd2,
	["Boost Software License"] = bsl1,
	["Creative Commons Legal Code (CC0)"] = cc0,
}

local license_table = {
	["MIT"] = mit.get_license,
	["Apache2"] = apache2.get_license,
	["Unlicense"] = unlicense.get_license,
	["GPL3"] = gpl3.get_license,
	["GPL2"] = gpl2.get_license,
	["AGPL3"] = agpl3.get_license,
	["LGPL2"] = lgpl2.get_license,
	["GLWTS"] = glwts.get_license,
	["MPL2"] = mpl2.get_license,
	["BSD3"] = bsd3.get_license,
	["BSD2"] = bsd2.get_license,
	["BSL1"] = bsl1.get_license,
	["CC0"] = cc0.get_license,
}

local set_license = function(bufnr, license)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(license or "", "\n"))
end

M.paste_license = function()
	local bufnr = vim.api.nvim_get_current_buf()
	pickers
		.new({}, {
			prompt_title = "Select License",

			finder = finders.new_table({
				results = vim.tbl_keys(telescope_license_table),
			}),

			sorter = conf.generic_sorter({}),

			attach_mappings = function(_, map)
				local paste_license_mapping = function(prompt_bufnr)
					local license = action_state.get_selected_entry().value
					set_license(bufnr, telescope_license_table[license].get_license(M.name))
					vim.api.nvim_buf_delete(prompt_bufnr, { force = true })
				end

				map("i", "<CR>", paste_license_mapping)
				map("n", "<CR>", paste_license_mapping)

				return true
			end,

			previewer = previewers.new_buffer_previewer({
				title = "License Content",

				define_preview = function(self, entry, _)
					local license = entry.value
					set_license(self.state.bufnr, telescope_license_table[license].license)
				end,
			}),
		})
		:find()
end

local function keyExists(table, key)
	for k, _ in pairs(table) do
		if k == key then
			return true
		end
	end
	return false
end

vim.api.nvim_create_user_command("License", function(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	if #opts.fargs < 1 or not keyExists(license_table, opts.fargs[1]) then
		local error_msg = "Valid licenses are: "
		for _, i in pairs(vim.tbl_keys(license_table)) do
			error_msg = error_msg .. i .. ", "
		end
		error_msg = error_msg:sub(1, -3)
		print(error_msg)
	else
		local license = opts.fargs[1]
		set_license(bufnr, license_table[license](M.name))
	end
end, {
	nargs = 1,
	complete = function()
		return vim.tbl_keys(license_table)
	end,
})

return M
