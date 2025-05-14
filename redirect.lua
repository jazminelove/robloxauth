-- Function to validate the key and HWID against Firebase
return function(key, hwid)
    local HttpService = game:GetService("HttpService")
    local baseURL = "https://auth-fbcb4-default-rtdb.firebaseio.com/auth/"  -- Your Firebase Realtime DB URL
    local url = baseURL .. key .. ".json"  -- URL to access the key in Firebase

    -- Attempt to get data from Firebase
    local success, response = pcall(function()
        return HttpService:GetAsync(url)  -- Make HTTP GET request to Firebase
    end)

    -- If the request fails, log the error
    if not success then
        warn("Error with HTTP request: " .. response)  -- Logs the error message
        return false
    end

    -- If the key doesn't exist, Firebase returns "null"
    if response == "null" then
        warn("Key not found in Firebase.")
        return false
    end

    -- Decode the JSON response from Firebase
    local data = HttpService:JSONDecode(response)

    -- Check if the HWID matches the one stored in Firebase
    if data.hwid == hwid then
        print("✅ HWID matches. Access granted.")
        return true
    else
        warn("❌ HWID mismatch.")
        return false
    end
end
