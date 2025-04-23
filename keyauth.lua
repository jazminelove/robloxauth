-- Lua script on Pastebin to validate keys
 
-- Predefined valid keys (you can change this to a more secure system if needed)
local validKeys = {
    "T0F6ETM9T65OVT34",  -- 4/23
    "1RVL90TP2PFESMPW",
	  "fotrnitebidf",
	  "ABC123XYZ456",
	  "ABC123XYZ456",
	  "ABC123XYZ456",
	  "ABC123XYZ456",
}
 
-- Function to validate the key
function validateKey(playerKey)
    for _, validKey in ipairs(validKeys) do
        if playerKey == validKey then
            return true
        end
    end
    return false
