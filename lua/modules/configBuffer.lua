local M = {}

M.populateBuffer = function(opts, bufferStatus)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- tab specific
    local command = ""
    local tabs = ""
    if #bufferStatus.bufferList == 0 then
        command = "databricks clusters list --output JSON | jq -r '.clusters[] | \"\" + .state + \" \" + .cluster_name'"
        tabs = "[default]    test     prod "
    elseif #bufferStatus.bufferList == 1 then
        command = "echo 'THIS IS TESTING'"
        tabs = " default    [test]    prod "
    else
        command = "echo 'THIS IS PROD'"
        tabs = " default     test    [prod]"
    end

    -- Execute the shell command and get the clusterList
    local clusterList = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        print("Error executing command: " .. command)
        return
    end

    -- Split the clusterList into lines for buffer
    local lines = {}
    local linesHeight = 0
    for s in clusterList:gmatch("[^\r\n]+") do
        table.insert(lines, s)
        linesHeight = linesHeight + 1
    end

    local boarder = "---------------------------"
    -- Insert the header line and an empty line
    local header = "[q] quit, [enter] select cluster"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {header, ""})

    -- Set lines in the buffer
    local columns = "Status    Cluster Name"
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, {columns, boarder})
    -- print(opts.headerLength)
    vim.api.nvim_buf_set_lines(buf, opts.headerLength, -1, false, lines)

    -- Static tabs line
    local lastLine = opts.headerLength + linesHeight
    vim.api.nvim_buf_set_lines(buf, lastLine, lastLine, false, {boarder, tabs})

    M.restrictBufferMovement(opts, buf, lastLine, bufferStatus)

    return buf
end

M.restrictBufferMovement = function(opts, buf, lastLine, bufferStatus)
    -- Restrict cursor movement between line 3 and end of file
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = bufferStatus.augroup,
        buffer = buf,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            if cursor[1] < (opts.headerLength+1) or cursor[1] > (lastLine - 1) then
                -- TODO: make this persistent for when swapping tabs
                vim.api.nvim_win_set_cursor(0, {math.min(math.max(opts.headerLength+1, cursor[1]), lastLine), cursor[2]})
            end
        end,
    })
end

return M
