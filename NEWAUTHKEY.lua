local validKeys = {
    "jazmine",
    "cyvvdxhn",
    "3se3f987s",
    "6tr4jdff3",
    "36e9un6u4",
    "6t09yjkjm",
    "6toh6t756",
    "56r0r8ogm",
    "456fdfsfg",
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
