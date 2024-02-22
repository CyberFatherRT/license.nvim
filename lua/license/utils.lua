local M = {}

function M.split(string)
    Result = {}
    for line in string.gmatch(string, "(.-)\n") do
        table.insert(Result, line)
    end
    return Result
end


function M.get_keys(t)
    Keys = {}
    for key,_ in pairs(t) do
        table.insert(Keys, key)
    end
    print(vim.inspect(Keys))
    return Keys
end


return M
