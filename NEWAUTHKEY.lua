local validKeys = {
    "jazmine",
    "cyvvdxhn",
    "bf3483asr9ns",
    "dw3ager4as08",
    "4e59jse76sdf",
    "d2da4swe0sdf",
    "f32bao34uin2",
    "896fb7drntom",
    "vnxa34r87ujf",
    "r23jap9seu8d",
    "350ws78erhsr",
    "3srdbs0dir33",
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
