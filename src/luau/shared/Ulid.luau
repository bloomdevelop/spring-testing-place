local UlidModules = {}

-- Crockford's Base32 alphabet
local BASE32 = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

-- Helper to encode a number to base32 with fixed length
local function encodeBase32(num, length)
    local str = ""
    for _ = 1, length do
        str = BASE32:sub((num % 32) + 1, (num % 32) + 1) .. str
        num = math.floor(num / 32)
    end
    return str
end

function UlidModules.createUlid()
    -- 48 bits timestamp (ms)
    local timestamp = math.floor(os.time() * 1000)
    -- 80 bits randomness (5 x 16 bits)
    local randomParts = {}
    for _ = 1, 5 do
        local part = math.random(0, 65535)
        table.insert(randomParts, part)
    end
    -- Combine randomness into a single 80-bit number
    -- Lua numbers are doubles, so we use 5x16 bits and encode each separately
    -- Encode timestamp (10 chars)
    local tsStr = encodeBase32(timestamp, 10)
    -- Encode randomness (16 chars)
    local randStr = ""
    for _, part in ipairs(randomParts) do
        randStr = randStr .. encodeBase32(part, 4)
    end
    -- ULID: 26 chars
    return tsStr .. randStr
end

return UlidModules