local M = {}

M.setup = function (username)
    M.name = username
end

local mit = require("license.licenses.mit")

local set_license = function (bufnr, license)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(license, "\n"))
end

vim.api.nvim_create_user_command("License", function (opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local license = opts.fargs[1]
    if license == "MIT" then
        set_license(bufnr, mit.get_license(M.name))
    end
end, { nargs = "*" })

return M
