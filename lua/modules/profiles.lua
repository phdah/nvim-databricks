local utils = require('modules/utils')

-------------------
-- Class Profile --
-------------------

local ProfileWrapper = {}
ProfileWrapper.__index = ProfileWrapper

function ProfileWrapper.new(name)
    local self = setmetatable({}, ProfileWrapper)
    table.insert(self, name)
    return self
end

function ProfileWrapper.__tostring(self)
    return tostring(self[1])
end

---------------------
-- Profiles struct --
---------------------

local ProfilesStruct = {}
ProfilesStruct.__index = ProfilesStruct

function ProfilesStruct.new()
    local self = setmetatable({}, ProfilesStruct)
    return self
end

function ProfilesStruct:populate(tbl)
    if tbl then
        for _, val in ipairs(tbl) do
            table.insert(self, ProfileWrapper.new(val))
        end
    else
        print("List of profiles is empty")
    end
end

-----------------------
-- List all profiles --
-----------------------

local function listProfiles(file)
    local fileName = file or "~/.databrickscfg"
    local command = "grep '^\\[' " .. fileName .. " | sed 's/[][]//g'"

    return utils.callAndPaseCommand(command)

end


-------------
-- Returns --
-------------

local M = {}

M.listProfiles = listProfiles
M.ProfilesStruct = ProfilesStruct

return M
