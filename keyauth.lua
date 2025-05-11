-- KEYS
local validKeys = {
    jazmine = "N/A",
    cyvvdxhn = "N/A", -- oulyo guy
    wxryxmkl = "N/A",
    vbyzrlhf = "N/A",
    bruhwtf = "N/A", -- allows access regardless of HWID
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
