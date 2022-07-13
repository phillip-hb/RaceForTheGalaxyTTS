owner = nil

function onsave()
    local data = {}
    data.owner = owner
    return JSON.encode(data)
end

function onload(saved_data)
    if saved_data ~= "" then
        local data = JSON.decode(saved_data)
        owner = data.owner
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
        broadcastToAll((Player[player].steam_name or player) .. ' claims the "' .. self.getName() .. '" goal.', player)
    end
end

-- [1] = current phase, [2] = tableau zone guid, [3] = player data
function endPhaseCheck(params)
    if owner then return end

    local card_db = Global.getVar("card_db")
    local currentPhase = params[1]
    local zone_GUID = params[2]
    local playerData = params[3]

    local winners = {}

    if self.getName() == "Galactic Standard of Living" and currentPhase == 4 then
        for player, data in pairs(playerData) do
            local zone = getObjectFromGUID(zone_GUID[data.index])
            local count = 0

            for _, obj in pairs(zone.getObjects()) do
                if obj.hasTag("VP Chip") then
                    count = count + math.max(1, obj.getQuantity())
                    if count >= 5 then
                        winners[#winners + 1] = player
                        break
                    end
                end
            end
        end
    elseif self.getName() == "Overlord Discoveries" and (currentPhase == 2 or currentPhase == 3) then
        for player, data in pairs(playerData) do
            local zone = getObjectFromGUID(zone_GUID[data.index])
            local count = 0

            for _, obj in pairs(zone.getObjects()) do
                local info = card_db[obj.getName()]
                if info and info.flags["ALIEN"] then
                    count = count + 1
                    if count >= 3 then
                        winners[#winners + 1] = player
                        break
                    end
                end
            end
        end
    end

    -- if currentPhase < 2 or currentPhase > 3 then return end

    -- local winners = {}
    -- for player, data in pairs(playerData) do
    --     local count = 0

    --     for _, card in allCardsInTableau(player, false) do
    --         local info = card_db[card.getName()]
    --         if info.flags["ALIEN"] then
    --             count = count + 1
    --             if count >= 3 then break end
    --         end
    --     end

    --     if count >= 3 then
    --         winners[#winners + 1] = player
    --     end
    -- end

    assignGoal(winners)
end