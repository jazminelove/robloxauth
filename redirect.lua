return function(key, hwid)
    local HttpService = game:GetService("HttpService")

    local baseURL = "https://auth-fbcb4-default-rtdb.firebaseio.com/auth/"
    local url = baseURL .. key .. ".json"

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if not success then
        warn("HTTP error: " .. response)
        return false
    end

    if response == "null" then
        warn("Key not found.")
        return false
    end

    local data = HttpService:JSONDecode(response)

    if data.hwid == hwid then
        print("✅ Access granted.")
        return true
    else
        warn("❌ HWID mismatch.")
        return false
    end
end
