-- KEYS
local validKeys = {
    jazmine = "02E9DB8F-8551-4B6A-9380-4BFF82B309A0",
    cyvvdxhn = "N/A", -- oulyo guy 
    wxgazryxmkl = "N/A",
    vbyzrlxcvhf = "N/A",
    fwasudaswda = "N/A",
    rdpuifasgne = "N/A",
    pmvsedmxoe = "N/A",
    spwxuezdcqs = "N/A",
}

function validateKey(playerKey, hwid)
    local requiredHWID = validKeys[playerKey]

    if requiredHWID then
        if requiredHWID == "N/A" then
            return true
        end
        if hwid then
            return hwid == requiredHWID
        end
        return false
    end

    return false
end

return validateKey
