-- keyauth.lua

local validKeys = {
    jazmine = "02d36cb2-8db4-4292-bf07-838c1d943dbf",
    cyvvdxhn = "1a2b-3c4d-5e6f",
    wxryxmkl = "abc-123-def-456",
    vbyzrlhf = "xyz-987-pqr-654",
}

function validateKey(playerKey, hwid)
    local requiredHWID = validKeys[playerKey]
    if requiredHWID then
        return hwid == requiredHWID
    end
    return false
end
