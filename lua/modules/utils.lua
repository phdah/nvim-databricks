local M = {}

function M.printTable(tbl, _msg)
    local function prepareResult(t, _indent)
        local indent = string.rep(" ", 4) .. _indent
        local result = {}
        if type(t) == 'table' and getmetatable(t) and getmetatable(t).__tostring then
            return tostring(t)
        else
            for k, v in pairs(t) do
                if type(v) == 'table' and getmetatable(v) and getmetatable(v).__tostring then
                    table.insert(result, indent .. tostring(k) .. ": " .. tostring(v))
                elseif type(v) == 'table' then
                    table.insert(result, indent .. tostring(k) .. ": {\n" .. prepareResult(v, indent) .. "\n" .. indent .. "}")
                else
                    table.insert(result, indent .. tostring(k) .. ": " .. tostring(v))
                end
            end
        end
        return table.concat(result, ",\n")
    end

    local msg = _msg or ""
    print(msg .. "{\n" .. prepareResult(tbl, "") .. "\n}")
end

function M.parseCommandReturnList(list)
    local result = {}
    local resultIteration = 0
    for s in list:gmatch("[^\r\n]+") do
        table.insert(result, s)
        resultIteration = resultIteration + 1
    end

    return result
end

function M.callAndPaseCommand(command)
    local commandResult = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        print("Error executing command: " .. command)
        return
    end

    return M.parseCommandReturnList(commandResult)
end

return M
