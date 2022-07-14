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