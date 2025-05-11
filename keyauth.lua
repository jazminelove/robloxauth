-- KEYS
local validKeys = {
    jazmine = "N/A",
    cyvvdxhn = "N/A", -- oulyo guy 
    wxgazryxmkl = "N/A",
    vbyzrlxcvhf = "N/A",
    fwasudaswda = "N/A",
    rdpuifasgne = "N/A",
    pmvsedmxoe = "N/A",
    spwxuezdcqs = "N/A",
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
