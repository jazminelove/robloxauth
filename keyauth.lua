-- KEYS
local validKeys = {
    jazmine = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0",
    cyvvdxhn = "N/A", -- oulyo guy
    wxryxmkl = "N/A",
    vbyzrlhf = "N/A",
    bruhwtf = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0", -- allows access regardless of HWID
}

function validateKey(playerKey, hwid)
    local requiredHWID = validKeys[playerKey]
    
    -- If the key exists and requires HWID validation
    if requiredHWID then
        if requiredHWID == "N/A" then
            return true -- Allows access regardless of HWID
        end
        
        -- If an HWID is required, check if it matches the stored HWID
        if hwid then
            return hwid == requiredHWID
        end
        
        -- If HWID is nil but the key requires one, deny access
        return false
    end
    
    -- If the key doesn't exist, deny access
    return false
end

return validateKey
