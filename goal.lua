require("util")

owner = nil
tiedOwners = {}

mostGoalsPlacement = {{5.69, 1.48, -1.01},{5.69, 1.48, 0.96}}
tableSurface_GUID = "4ee1f2"
tiedVpBag_GUID = "d95c9e"

function onsave()
    local data = {}
    data.owner = owner
    data.tiedOwners = tiedOwners
    return JSON.encode(data)
end

function onload(saved_data)
    if saved_data ~= "" then
        local data = JSON.decode(saved_data)
        owner = data.owner
        tiedOwners = data.tiedOwners

        if not tiedOwners then tiedOwners = {} end
    end
end

function assignGoal(winners)
    for i=1, #winners do
        local player = winners[i]
        local goal = nil
        if i == 1 then
            owner = player
            goal = self
        else
            goal = self.clone()
            goal.setPosition(self.getPosition())
            Wait.frames(function()
                goal.setVar("owner", player)
            end, 1, 0)
        end

        Wait.frames(function() Global.call("moveGoalToPlayer", {goal, player}) end, 2, 0)
        broadcastToAll((Player[player].steam_name or player) .. ' has claimed the "' .. self.getName() .. '" goal.', player)
    end
end

function assignMostGoal(winnersTable)
    if #winnersTable <= 0 then return end

    tiedVpBag = getObjectFromGUID(tiedVpBag_GUID)

    table.sort(winnersTable, function(v1, v2)
        if v1[2] == v2[2] then
            return v1[1] == owner
        end
        return v1[2] > v2[2]
    end)

    local winningValue = #winnersTable > 0 and winnersTable[1][2] or 0
    local tiedPlayers = {}
    local ties = 0
    -- count number of ties with the winner
    for i=2, #winnersTable do
        local entry = winnersTable[i]
        if entry[2] == winningValue then
            tiedPlayers[entry[1]] = true
            ties = ties + 1

            -- include the first player winner
            if i == 2 then
                tiedPlayers[winnersTable[1][1]] = true
                ties = ties + 1
            end
        end
    end

    -- remove tied player vp tokens
    for player, guid in pairs(tiedOwners) do
        if not tiedPlayers[player] then
            local token = getObjectFromGUID(guid)
            if token then token.destruct() end
            tiedOwners[player] = nil
        end
    end

    if #winnersTable > 0 then
        -- only 1 player beat the value, they get the goal
        if ties == 0 then
            local player = winnersTable[1][1]
            local value = winnersTable[1][2]

            if winnersTable[1][1] ~= owner then
                broadcastToAll((Player[player].steam_name or player) .. ' has claimed the "' .. self.getName() .. '" goal.', player)
                Wait.frames(function() Global.call("moveGoalToPlayer", {self, player}) end, 1)
            end

            owner = player
        elseif ties > 0 then
            if owner and tiedPlayers[owner] or not owner then
                -- players tied with the leader get the 3 VP token
                for player, tied in pairs(tiedPlayers) do
                    if player ~= owner and not tiedOwners[player] then
                        local token = tiedVpBag.takeObject()
                        token.setName("Tied w/ " .. self.getName())
                        tiedOwners[player] = token.getGUID()
                        Wait.frames(function() Global.call("moveGoalToPlayer", {token, player}) end, 1)
                    end
                end
            end
        end
    end
end

function loseMostGoal(player)
    broadcastToAll((Player[player].steam_name or player) .. ' has lost the "' .. self.getName() .. " goal.", player)
    owner = nil
    returnMostGoal()
end

function returnMostGoal()
    for _, pos in pairs(mostGoalsPlacement) do
        local hits = Physics.cast({
            origin = add(pos, {0, 1, 0}),
            direction = {0,-1,0},
            max_distance = 3
        })

        for _, hit in pairs(hits) do
            if not hit.hit_object.hasTag("Most Goal") then
                self.setPosition(add(pos, {0, 1, 0}))
                self.setRotation({0,90,0})
                return
            end
        end
    end
end