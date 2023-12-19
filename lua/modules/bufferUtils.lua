local M = {}

M.strBufferList = function(list)
    local bufferStr = ""
    for i, buffer in ipairs(list) do
        bufferStr = bufferStr .. "{Index: " .. i .. ", Buffer:" .. buffer .. "}, "
    end
    -- Remove the last comma and space
    bufferStr = bufferStr:sub(1, -3)
    return bufferStr
end

M.closeListOfBuffers = function(bufferList)
    for _, buf in ipairs(bufferList) do
        -- Close each buffer if it's valid
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    return {}
end

return M
