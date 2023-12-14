local M = {}

M.populateBuffer = function(headerLength)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Define the shell command
    local command = "databricks clusters list --output JSON | jq -r '.clusters[] | \"\" + .state + \" \" + .cluster_name'"

    -- Execute the shell command and get the clusterList
    local clusterList = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        print("Error executing command: " .. command)
        return
    end

    -- Split the clusterList into lines for buffer
    local lines = {}
    for s in clusterList:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    -- Insert the header line and an empty line
    local header = "[q] quit, [enter] select cluster"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {header, ""})

    -- Set lines in the buffer
    local columns = "Status    Cluster Name"
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, {columns})
    vim.api.nvim_buf_set_lines(buf, headerLength, -1, false, lines)

    return buf
end

M.restrictBufferMovement = function(headerLength, buf)
    -- Create an autocommand group
    local augroup = vim.api.nvim_create_augroup('LimitCursorMovement', { clear = true })

    -- Restrict cursor movement between line 3 and end of file
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = augroup,
        buffer = buf,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            if cursor[1] < (headerLength+1) then
                vim.api.nvim_win_set_cursor(0, {headerLength+1, cursor[2]})
            end
        end,
    })
    return augroup
end

return M
