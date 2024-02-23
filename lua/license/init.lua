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
local previewers = require('telescope.previewers')
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local mit = require("license.licenses.mit")
local apache2 = require("license.licenses.apache2")
local unlicense = require("license.licenses.unlicense")
local gpl3 = require("license.licenses.gpl3")
local gpl2 = require("license.licenses.gpl2")
local agpl3 = require("license.licenses.agpl3")
local lgpl3 = require("license.licenses.lgpl3")
local mpl2 = require("license.licenses.mpl2")
local bsd3 = require("license.licenses.bsd3")
local cc0 = require("license.licenses.cc0")

local function getTableKeys(tab)
    local keyset = {}
    for k, _ in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end


local telescope_license_table = {
    ["MIT"] = mit,
    ["Apache 2"] = apache2,
    ["Unlicense"] = unlicense,
    ["GNU General Public License v.3 (GPL3)"] = gpl3,
    ["GNU General Public License v.2 (GPL2)"] = gpl2,
    ["GNU Affero General Public License v.3 (AGPL3)"] = agpl3,
    ["GNU Lesser General Public License v.3 (LGPL3)"] = lgpl3,
    ["Mozilla Public License 2.0 (MPL2)"] = mpl2,
    ["BSD 3-Clause (BSD3)"] = bsd3,
    ["Creative Commons Legal Code (CC0)"] = cc0,
}

local license_table = {
    ["MIT"] = mit.get_license,
    ["Apache2"] = apache2.get_license,
    ["Unlicense"] = unlicense.get_license,
    ["GPL3"] = gpl3.get_license,
    ["GPL2"] = gpl2.get_license,
    ["AGPL3"] = agpl3.get_license,
    ["LGPL3"] = lgpl3.get_license,
    ["MPL2"] = mpl2.get_license,
    ["BSD3"] = bsd3.get_license,
    ["CC0"] = cc0.get_license,
}

local set_license = function(bufnr, license)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(license or "", "\n"))
end

vim.keymap.set("n", "<leader>gl", function()
    local bufnr = vim.api.nvim_get_current_buf()
    pickers.new({}, {
        prompt_title = "Select License",

        finder = finders.new_table {
            results = getTableKeys(telescope_license_table)
        },

        sorter = conf.generic_sorter({}),

        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local license = action_state.get_selected_entry().value
                set_license(bufnr, telescope_license_table[license].get_license(M.name))
                vim.api.nvim_buf_delete(prompt_bufnr, { force = true })
            end)
            return true
        end,

        previewer = previewers.new_buffer_previewer {
            title = "License Content",

            define_preview = function(self, entry, _)
                local license = entry.value;
                set_license(self.state.bufnr, telescope_license_table[license].license)
            end
        }

    }):find()
end)

vim.api.nvim_create_user_command("License", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local license = opts.fargs[1]
    set_license(bufnr, license_table[license](M.name))
end, {
        nargs = 1,
        complete = function()
            return getTableKeys(license_table)
        end
    }
)

return M
