local validKeys = {
    "key123",
    "testkey2025",
    "myfreeaccesskey"
}

function validateKey(key)
    for _, valid in ipairs(validKeys) do
        if key == valid then
            return true
        end
    end
    return false
end

return validateKey
