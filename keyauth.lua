-- KEYS
local validKeys = {
    jazmine = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0",
    cyvvdxhn = "N/A", -- oulyo guy
    wxryxmkl = "N/A",
    vbyzrlhf = "N/A",
    bruhwtf = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0", -- allows access regardless of HWID
}


function validateKey(playerKey, hwid)
    print("Validating key:", playerKey)
    print("Player HWID:", hwid)

    local requiredHWID = validKeys[playerKey]

    -- Check if the key is valid and whether it requires HWID validation
    if requiredHWID then
        -- If the key is "N/A", allow access regardless of HWID
        if requiredHWID == "N/A" then
            print("HWID not required for key:", playerKey)
            return true
        end
        
        -- If the HWID matches the required one, grant access
        if hwid then
            print("Required HWID for key:", requiredHWID)
            print("Comparing HWIDs:", hwid, requiredHWID)
            return hwid == requiredHWID
        end
        
        -- If HWID is nil but a HWID is required, deny access
        print("HWID is required but not provided.")
        return false
    end
    
    -- If the key doesn't exist in validKeys, deny access
    print("Key not found:", playerKey)
    return false
end

return validateKey
