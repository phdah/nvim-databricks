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

function M.getClusterStateAndName(states, splitLines)
    local transformed = {}
    for _, v in pairs(splitLines) do
        -- Concatenate the state and name with a space and add to the new table
        -- Subbstitute the state with signs
        local state = v[2]
        if v[2] == "TERMINATED" then
            state = states.terminated
        elseif v[2] == "RUNNING" then
            state = states.running
        elseif v[2] == "PENDING" then
            state = states.pending
        elseif v[2] == "TERMINATING" then
            state = states.terminating
        elseif v[2] == "RESIZING" then
            state = states.resizing
        elseif v[2] == "RESTARTING " then
            state = states.restarting
        end

        table.insert(transformed, state .. " " .. v[3])
    end
    return transformed
end

function M.callLines(command, seperator)
    local lines = vim.fn.systemlist(command)
    -- Databricks API returns a message starting with `Error:`, which is used
    -- here for detecting a failed call. This is due to systemlist failing to
    -- return non-zero shell_error when call fails. Unsure why this is
    if vim.v.shell_error ~= 0 or lines[1]:match("^Error:") ~= nil then
        print("Error executing command: " .. command)
        for _, line in ipairs(lines) do
            print(line)
        end
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


--[[
Dynamically set the height of the window
and return a table with settings. Input is in
percentage for both height and width
]]
function M.setWindowSize(winOpts, height, width)
    winOpts.width = math.floor(vim.o.columns * width)
    winOpts.height = math.floor(vim.o.lines * height)
    winOpts.row = math.floor((vim.o.lines - winOpts.height) / 2)
    winOpts.col = math.ceil((vim.o.columns - winOpts.width) / 2)

    return winOpts
end

return M
