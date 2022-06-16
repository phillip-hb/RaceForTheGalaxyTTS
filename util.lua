function magiclines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

function all_trim(s)
    return s:gsub('%s+', '')
end

function wait(time)
    local start = os.time()
    repeat
        coroutine.yield(0)
    until os.time() > start + time
end

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function split(str, delimiter)
    local fields = {}

    local sep = delimiter or " "
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(str, pattern, function(c) fields[#fields + 1] = c end)

    return fields
end

function tableLength(tbl)
    local count = 0
    for k, v in pairs(tbl) do count = count + 1 end
        return count
    end

    function getSeatedPlayersWithHands()
    local results = {}
    local players = getSeatedPlayers()

    for i=1, #players do
        if Player[players[i]].seated and Player[players[i]].getHandCount() > 0 then
            results[#results + 1] = players[i]
        end
    end
    return results
end
