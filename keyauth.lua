-- keyauth script (keyauth.lua)

-- List of valid keys (for simplicity, using a hardcoded list)
local validKeys = {
    "zjxfmcsl",
    "cyvvdxhn",
    "wxryxmkl",
    "vbyzrlhf"
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
