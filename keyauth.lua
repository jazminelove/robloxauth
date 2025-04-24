-- keyauth script (keyauth.lua)

-- List of valid keys and corresponding HWIDs
local validKeys = {
    zjxfmcsl = "02E9DB8F-8551-4X6A-9380-4BFF82B309A0",  -- example HWID, replace with real one
    cyvvdxhn = "02E9DB8F-8551-4F6A-9380-4BFF82B309A0",
    wxryxmkl = "abc-123-def-456",
    vbyzrlhf = "xyz-987-pqr-654",
}

-- Function to validate key and HWID
function validateKey(playerKey, hwid)
    local validHWID = validKeys[playerKey]
    return validHWID and hwid == validHWID
end
