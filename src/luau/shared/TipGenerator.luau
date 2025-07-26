local TipGenerator = {}

function TipGenerator.generateTip()
    local tips = {
        "This game was created by using a mix between Luau and TypeScript.",
        "React my beloved",
        ":3"
    }

    local randomIndex = math.random(1, #tips)
    return tips[randomIndex]
end

return TipGenerator