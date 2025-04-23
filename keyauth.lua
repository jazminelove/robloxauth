-- keyauth script (keyauth.lua)

-- List of valid keys (for simplicity, using a hardcoded list)
local validKeys = {
    "T0F6ETM9T65OVT34",
    "12345ABCDE",
    "1RVL90TP2PFESMPW",
    "spiderman"
}

-- Function to validate the key
function validateKey(playerKey)
    for _, key in ipairs(validKeys) do
        if key == playerKey then
            return true  -- Key is valid
        end
    end
    return false  -- Key is invalid
end
