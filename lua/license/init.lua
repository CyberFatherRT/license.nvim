local M = {}

M.setup = function (username)
    M.name = username
end

local mit = require("license.licenses.mit")
local apache2 = require("license.licenses.apache2")
local gpl3 = require("license.licenses.gpl3")
local bsd3 = require("license.licenses.bsd3")

local set_license = function (bufnr, license)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(license, "\n"))
end

vim.api.nvim_create_user_command("License", function (opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local license = opts.fargs[1]
    if license == "MIT" then
        set_license(bufnr, mit.get_license(M.name))
    elseif license == "Apache2" then
        set_license(bufnr, apache2.get_license(M.name))
    elseif license == "GPL3" then
        set_license(bufnr, gpl3.get_license(M.name, opts.fargs[2]))
    elseif license == "BSD3" then
        set_license(bufnr, bsd3.get_license(M.name))
    end
end, {
        nargs = "*",
        complete = function ()
            return {
                "MIT",
                "Apache2",
                "GPL3",
                "BSD3",
            }
        end
})

return M
