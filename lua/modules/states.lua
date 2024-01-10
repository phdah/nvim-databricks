local utils = require('modules/utils')

----------------------
-- Base state class --
----------------------

local State = {}
State.__index = State

function State:clean()
    for k in pairs(self) do
        self[k] = nil
    end
end

------------
-- Buffer --
------------

local Buffer = {
    profiles = nil
}
Buffer.__index = Buffer
setmetatable(Buffer, State)

function Buffer.new(profiles)
    local self = setmetatable({}, Buffer)
    setmetatable(self, {__index = Buffer, __tostring = State.__tostring})

    self.profiles = profiles

    return self
end

---------------
-- Selection --
---------------

local Selection = {}
Selection.__index = Selection
setmetatable(Selection, State)

function Selection.new()
    local self = setmetatable({}, Selection)
    setmetatable(self, {__index = Selection, __tostring = State.__tostring})
    return self
end

-------------
-- Returns --
-------------

local M = {}

M.Buffer = Buffer
M.Selection = Selection

return M
