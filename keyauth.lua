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
