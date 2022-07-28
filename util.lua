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

function appendList(list, add)
    for _, item in pairs(add) do
        list[#list + 1] = item
    end
    return list
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

function add(v1, v2)
    return {v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3]}
end

function getCardSlot(card)
    local hits = Physics.cast({
         origin = add(card.getPosition(), {0,1,0}),
         direction = {0,-1,0},
         max_distance = 5
    })

    for _, hit in pairs(hits) do
         if hit.hit_object.hasTag("Slot") then
              return hit.hit_object
         end
    end

    return nil
end

function getCard(slot)
    local hits = Physics.cast({
         origin = add(slot.getPosition(), {0,1,0}),
         direction = {0,-1,0},
         max_distance = 2
    })

    for _, hit in pairs(hits) do
         if hit.hit_object.type == 'Card' and hit.hit_object.is_face_down == false then
              return hit.hit_object
         end
    end

    return nil
end

function deleteLinkedListNode(list, value)
    local node = list

    while node and node.value do
        if node.value == value then   -- head of list
            list = {}
            break
        elseif node.next and node.next.value == value then
            node.next = nil
            break
        elseif not node.next then
            break
        end
        node = node.next
    end

    return list
end

function getLinkedListNode(list, value)
    local node = list

    while node do
        if node.value == value then
            return node
        end
        
        if not node.next then return nil end

        node = node.next
    end

    return nil
end

function getLastNode(list)
    local node = list
    while node and node.next do
        node = node.next
    end
    return node
end

function concatPowerName(power)
    local value = power.name
    if power.name ~= "DISCARD" then return value end
    for code, _ in pairs(power.codes) do
        value = value .. "|" .. code
    end
    return value
end

function uiSetVisibilityToPlayer(id, playerColor, visible)
    local attr = UI.getAttribute(id, "visibility")
    if visible then
         attr = attr .. "|" .. playerColor
    else
         local newAttr = ""
         tokens = split(attr, "|")

         for i=1, #tokens do
              if tokens[i] ~= playerColor then
                   newAttr = newAttr .. tokens[i] .. "|"
              end
         end

         if newAttr == "" then
              attr = "Brown"
         else
              attr = newAttr:sub(1, newAttr:len() - 1)
         end
    end

    UI.setAttribute(id, "visibility", attr)
end