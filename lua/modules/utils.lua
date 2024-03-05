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

function M.addTableKeys(table, keyNumber)
        local newTable = {}
        for _, v in ipairs(table) do
            newTable[v[keyNumber]] = v
        end
        return newTable
end

function M.getClusterStateAndName(splitLines)
    local transformed = {}
    for _, v in pairs(splitLines) do
        -- Concatenate the state and name with a space and add to the new table
        table.insert(transformed, v[2] .. " " .. v[3])
    end
    return transformed
end

function M.callLines(command, seperator)
    local lines = vim.fn.systemlist(command)
    if vim.v.shell_error ~= 0 then
        print("Error executing command: " .. command)
        return
    end

    if seperator then
        local splitLines = {}
        for _, line in ipairs(lines) do
            table.insert(splitLines, vim.split(line, seperator))
        end
        return splitLines
    end

    return lines

end

function M.tableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return M
