local M = {}

M.setup = function(username)
    M.name = username
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require('telescope.previewers')
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local mit = require("license.licenses.mit")
local apache2 = require("license.licenses.apache2")
local gpl3 = require("license.licenses.gpl3")
local agpl3 = require("license.licenses.agpl3")
local lgpl3 = require("license.licenses.lgpl3")
local mpl2 = require("license.licenses.mpl2")
local bsd3 = require("license.licenses.bsd3")

local function getTableKeys(tab)
    local keyset = {}
    for k, _ in pairs(tab) do
        keyset[#keyset + 1] = k
    end
    return keyset
end


local license_table = {
    ["MIT"] = mit,
    ["Apache 2"] = apache2,
    ["GNU General Public License v.3 (GPL3)"] = gpl3,
    ["GNU Affero General Public License v.3 (AGPL3)"] = agpl3,
    ["GNU Lesser General Public License v.3 (LGPL3)"] = lgpl3,
    ["Mozilla Public License 2.0 (MPL2)"] = mpl2,
    ["BSD 3-Clause (BSD3)"] = bsd3,
}

local set_license = function(bufnr, license)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(license or "", "\n"))
end

vim.keymap.set("n", "<leader>gl", function()
    local bufnr = vim.api.nvim_get_current_buf()
    pickers.new({}, {
        prompt_title = "Select License",

        finder = finders.new_table {
            results = getTableKeys(license_table)
        },

        sorter = conf.generic_sorter({}),

        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local license = action_state.get_selected_entry().value
                set_license(bufnr, license_table[license].get_license(M.name))
                vim.api.nvim_buf_delete(prompt_bufnr, { force = true })
            end)
            return true
        end,

        previewer = previewers.new_buffer_previewer {
            title = "License Content",

            define_preview = function(self, entry, _)
                local license = entry.value;
                set_license(self.state.bufnr, license_table[license].license)
            end
        }

    }):find()
end)

vim.api.nvim_create_user_command("License", function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local license = opts.fargs[1]
    if license == "MIT" then
        set_license(bufnr, mit.get_license(M.name))
    elseif license == "Apache2" then
        set_license(bufnr, apache2.get_license(M.name))
    elseif license == "GPL3" then
        set_license(bufnr, gpl3.get_license(M.name))
    elseif license == "AGPL3" then
        set_license(bufnr, agpl3.get_license(M.name))
    elseif license == "LGPL3" then
        set_license(bufnr, lgpl3.get_license(M.name))
    elseif license == "MPL2" then
        set_license(bufnr, mpl2.get_license())
    elseif license == "BSD3" then
        set_license(bufnr, bsd3.get_license(M.name))
    end
end, {
    nargs = 1,
    complete = function()
        return {
            "MIT",
            "Apache2",
            "GPL3",
            "AGPL3",
            "LGPL3",
            "MPL2",
            "BSD3",
        }
    end
}
)

return M
