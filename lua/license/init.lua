local util = require("license.utils")

local licenses = {}

for file in io.popen("ls -1 licenses"):lines() do
    local content = io.popen("cat" .. " licenses/" .. file):read("*a")
    licenses[file] = content
end

vim.api.nvim_create_user_command("License", function (opts)
    local bufnr = vim.fn.bufnr("%")
    local license = licenses[opts.fargs[1]]
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, 0, util.split(license))
end, {
        nargs = 1,
        complete = function ()
            return util.get_keys(licenses)
        end
})
