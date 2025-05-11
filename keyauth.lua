-- KEYS
local validKeys = {
    jazmine = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0",
    cyvvdxhn = "C43DD5B6-23AB-4B3A-86FD-5A36319471E2", -- oulyo guy
    wxryxmkl = "abc-123-def-456",
    vbyzrlhf = "xyz-987-pqr-654",
    bruhwtf = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0", -- allows access regardless of HWID
}

function validateKey(playerKey, hwid)
    local requiredHWID = validKeys[playerKey]
    if requiredHWID then
        if requiredHWID == "N/A" then
            return true -- Allow any HWID if key is marked N/A
        end
        return hwid == requiredHWID
    end
    return false
end

return validateKey
