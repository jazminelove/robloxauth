-- KEYS
local validKeys = {
    jazmine = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0",
    cyvvdxhn = "N/A", -- oulyo guy
    wxryxmkl = "N/A",
    vbyzrlhf = "N/A",
    bruhwtf = "N/A", -- allows access regardless of HWID
}

function validateKey(playerKey, hwid)
    local requiredHWID = validKeys[playerKey]
    
    -- Check if the key exists in the validKeys table
    if requiredHWID then
        -- If the requiredHWID is "N/A", allow access regardless of the HWID
        if requiredHWID == "N/A" then
            return true
        end
        -- If the HWID matches the one associated with the key, grant access
        return hwid == requiredHWID
    end
    
    -- Return false if the key is invalid or not found in validKeys
    return false
end

return validateKey
