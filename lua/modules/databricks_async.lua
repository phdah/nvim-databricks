local p = require('modules/profiles')

-------------------
-- AsyncClusters --
-------------------

local AsyncClusters = {}
AsyncClusters.__index = AsyncClusters

function AsyncClusters.new(opts)
    local self = setmetatable({}, AsyncClusters)
    local profiles = p.listProfiles(opts.DBConfigFile) or {}

    for _, profile in pairs(profiles) do
        self[profile] = {}
    end
    self:asyncGetClusters()

    return self
end

function AsyncClusters:createOnRead(profile)
    local data_accumulator = {}

    return {
        on_stdout = function(err, data)
            if err then
                -- print("Error on profile " .. profile .. ": ", err)
            end
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(data_accumulator, line)
                    end
                end
            end
        end,
        on_exit = function(job_id, exit_code)
            if exit_code == 0 then
                for _, line in ipairs(data_accumulator) do
                    local parts = vim.split(line, " ")
                    if #parts >= 2 then
                        local state = parts[1]
                        local cluster_name = table.concat(parts, " ", 2)
                        table.insert(self[profile], state .. " " .. cluster_name)
                    end
                end
            else
                print("Job exited with code: ", exit_code)
            end
        end
    }
end

function AsyncClusters:asyncGetClusters()
    for profile, _ in pairs(self) do
        local command = "databricks --profile " .. profile .. " clusters list --output JSON | jq -r '.[] | select(.cluster_name | startswith(\"job-\") | not) | .state + \" \" + .cluster_name'"

        local handlers = self:createOnRead(profile)
        vim.fn.jobstart(command, {
            stdout_buffered = true,
            on_stdout = function(err, data)
                handlers.on_stdout(err, data)
            end,
            on_exit = handlers.on_exit
        })
    end
end

-------------
-- Returns --
-------------

local M = {}

M.AsyncClusters = AsyncClusters

return M
