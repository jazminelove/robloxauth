-- keyauth.lua

local validKeys = {
    zjxfmcsl = "3186D30C-2785-4C36-B9A7-660386201427",
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
