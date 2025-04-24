-- keyauth script (keyauth.lua)

-- List of valid keys and HWIDs (linked by key)
local validKeys = {
    zjxfmcsl = "HWID123456",  -- example pair
    cyvvdxhn = "HWID654321",
    wxryxmkl = "HWID111222",
    vbyzrlhf = "HWID333444",
}

-- Function to validate the key and HWID
function validateKey(playerKey, hwid)
    local expectedHwid = validKeys[playerKey]
    if expectedHwid and expectedHwid == hwid then
        return true  -- Valid key + HWID
    end
    return false  -- Invalid combo
end
