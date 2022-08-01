
function setHelpText(player, text)
    local i = playerData[player].index
    local obj = getObjectFromGUID(helpDisplay_GUID[i])
    obj.UI.setValue("label", text)
end

function updateHelpText(playerColor)
    if not playerColor then return end

    local p = playerData[playerColor]
    local i = p.index
    local powers = p.powersSnapshot
    local handCount = p.handCountSnapshot
    local cardsInHand = countCardsInHand(playerColor, currentPhaseIndex == #selectedPhases)
    local discarded = handCount - cardsInHand
    local currentPhase = getCurrentPhase()

    if currentPhase ~= 4 and currentPhase ~= 5 then
        p.canReady = false
    end

    p.canFlip = false
    p.canConfirm = true

    if transitionNextPhase then
        setHelpText(playerColor, "")
        return
    -- opening hand
    elseif gameStarted and currentPhaseIndex == -1 then
        if p.selectedCard then
            p.canFlip = true
            local discardTarget = powers["DISCARD"]
            if discarded >= discardTarget then p.canReady = true end
            setHelpText(playerColor, "Determine starting hand. (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "▼ Select your start world.")
        end
    -- end of round
    elseif currentPhaseIndex > #selectedPhases then
        p.canFlip = true
    -- start of round
    elseif currentPhaseIndex == 0 then
        if powers["START_SAVE"] and p.selectedCard then
            discarded = countDiscardInHand(playerColor, false)
            if discarded < 1 then
                p.canFlip = true
                p.canConfirm = false
            end
            setHelpText(playerColor, "▼ Select card to save. (" .. discarded .. "/1)")
        else
            setHelpText(playerColor, "▲ Select an action.")
        end
    -- explore
    elseif currentPhase == 1 then
        if p.beforeExplore then
            local discardTarget = p.powersSnapshot["DISCARD_PRESTIGE"] or 1
            if discarded < discardTarget then p.canFlip = true end
            setHelpText(playerColor, "▼ Explore: may discard for prestige. (" .. discarded .. "/" .. discardTarget .. ")")
        else
            p.canFlip = true
            local discardTarget = math.max(0, powers["DRAW"] - powers["KEEP"])
            if discarded >= discardTarget then p.canReady = true end
            setHelpText(playerColor, "Explore: draw " .. powers["DRAW"] .. ", keep " .. powers["KEEP"] .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
        end
    -- develop
    elseif currentPhase == 2 then
        if p.beforeDevelop then
            local discardTarget = p.powersSnapshot["MUST_DISCARD"] or 0
            if discardTarget == 0 then
                p.beforeDevelop = false
            else
                if discarded < discardTarget then p.canFlip = true end
                setHelpText(playerColor, "▼ Develop: discard from hand. (" .. discarded .. "/" .. discardTarget .. ")")
                return
            end
        end
        
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]
            local discardTarget = math.max(0, info.cost - (powers["REDUCE"] or 0))
            local node = p.miscSelectedCards

            while node and node.value do
                local miscCard = getObjectFromGUID(node.value)
                local miscPowers = card_db[miscCard.getName()].activePowers["2"]

                if miscPowers then
                    if miscPowers["DISCARD_REDUCE"] then
                        discardTarget = math.max(0, discardTarget - miscPowers["DISCARD_REDUCE"].strength)
                    end
                end

                node = node.next
            end

            for goodsGuid, usedPowers in pairs(p.markedGoods) do
                if usedPowers.power.name == "CONSUME_RARE" then
                    discardTarget = math.max(0, discardTarget - usedPowers.power.strength)
                end
            end

            if discarded >= discardTarget then p.canReady = true end
            p.canFlip = true
            setHelpText(playerColor, "Develop: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "▼ Develop: may play a development.")
        end
    -- settle
    elseif currentPhase == 3 and exploreAfterPhase then
        local discardTarget = 1
        if p.afterSettle then
            if discarded < discardTarget then
                p.canFlip = true
                p.canConfirm = false
            end
            setHelpText(playerColor, "▼ Settle: discard from hand. (" .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "Settle: waiting for other players.")
        end
    elseif currentPhase == 3 then
        local planningTakeover = planningTakeover(playerColor)

        if isUpgradingWorld(playerColor) then
            if p.upgradeWorldOld then
                setHelpText(playerColor, "▼ Settle: select world to replace target.")
            else
                setHelpText(playerColor, "▲ Settle: select target world on tableau.")
            end
        elseif p.selectedCard or p.beingTargeted or planningTakeover then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card and card_db[card.getName()] or nil

            -- Check for special settle power modifiers
            local reduceZero = false
            local reduceZeroName = ""
            local doMilitary = info and info.flags["MILITARY"]
            local payMilitary = false
            local payDiscount = 0
            local payMilitaryStr = 0
            local militaryDiscount = 0
            local tempMilitary = p.tempMilitary
            local node = p.miscSelectedCards

            while node and node.value do
                local miscCard = getObjectFromGUID(node.value)
                if miscCard then
                    local miscPowers = card_db[miscCard.getName()].activePowers["3"]
                    if miscPowers then
                        if miscPowers["DISCARD"] and miscPowers["DISCARD"].codes["REDUCE_ZERO"] then
                            reduceZero = true
                            reduceZeroName = miscCard.getName()
                        elseif miscPowers["PAY_MILITARY"] then
                            payMilitary = true
                            payMilitaryStr = miscPowers["PAY_MILITARY"].strength
                        elseif miscPowers["MILITARY_HAND"] then
                            local discardCount = p.handCountSnapshot - countCardsInHand(playerColor, false)
                            local usedAmount = 0
                            if p.cardsAlreadyUsed[node.value] and p.cardsAlreadyUsed[node.value][node.power.name] then
                                usedAmount = p.cardsAlreadyUsed[node.value][node.power.name].strength
                            end
                            if discarded + usedAmount < miscPowers["MILITARY_HAND"].strength then
                                p.canFlip = true
                            end

                            setHelpText(playerColor, "▼ Settle: discard for bonus military. (" .. discarded + usedAmount .. "/" .. miscPowers["MILITARY_HAND"].strength .. ")")
                            return
                        elseif miscPowers["DISCARD_CONQUER_SETTLE"] then
                            doMilitary = true
                            militaryDiscount = miscPowers["DISCARD_CONQUER_SETTLE"].strength
                        end
                    end
                end
                node = node.next
            end

            for goodsGuid, usedPowers in pairs(p.markedGoods) do
                if usedPowers.power.codes["REDUCE"] then
                    payDiscount = payDiscount + usedPowers.power.strength
                elseif usedPowers.power.codes["EXTRA_MILITARY"] then
                    tempMilitary = tempMilitary + usedPowers.power.strength
                end
            end

            if planningTakeover then
                setHelpText(playerColor, "Settle: takeover. (Military " .. p.powersSnapshot["EXTRA_MILITARY"] + p.powersSnapshot["BONUS_MILITARY"] + tempMilitary .. ")")
                return
            end

            if takeoverPhase then
                if p.beingTargeted then
                    setHelpText(playerColor, "Settle: defend against takeover.")
                else
                    setHelpText(playerColor, "Settle: waiting for other players.")
                end
            elseif doMilitary and not payMilitary then
                local def = info.cost - militaryDiscount
                local specialtyBonus = 0
                if info.goods and p.powersSnapshot[info.goods .. "_BONUS_MILITARY"] then
                    specialtyBonus = p.powersSnapshot[info.goods .. "_BONUS_MILITARY"]
                elseif info.flags["REBEL"] and p.powersSnapshot["AGAINST_REBEL_BONUS_MILITARY"] then
                    specialtyBonus = p.powersSnapshot["AGAINST_REBEL_BONUS_MILITARY"]
                end
                local totalMil = p.powersSnapshot["EXTRA_MILITARY"] + p.powersSnapshot["BONUS_MILITARY"] + tempMilitary + specialtyBonus
                if totalMil >= def then p.canReady = true end
                setHelpText(playerColor, "Settle: " .. def .. " defense. (Military " .. totalMil .. "/" .. def .. ")")
            elseif rebelSneakAttackPhase and p.selectedCard then
                setHelpText(playerColor, "Settle: can only play Military worlds.")
            else
                if reduceZero then
                    p.canReady = truefff
                    setHelpText(playerColor, "Settle: paid w/ " .. reduceZeroName .. ".")
                else
                    if payMilitary then
                        payDiscount = payDiscount + payMilitaryStr + (p.powersSnapshot["PAY_DISCOUNT"] or 0)
                    end
                    local discardTarget = math.max(0, info.cost - (powers["REDUCE"] or 0) - payDiscount)
                    if discarded >= discardTarget then p.canReady = true end
                    p.canFlip = true
                    setHelpText(playerColor, "Settle: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
                end
            end
        else
            if rebelSneakAttackPhase and p.rebelSneakAttack then
                setHelpText(playerColor, 'Settle: resolve "Rebel Sneak Attack."')
            elseif placeTwoPhase then
                if not p.powersSnapshot["PLACE_TWO"] then
                    setHelpText(playerColor, "Settle: waiting for other players.")
                else
                    setHelpText(playerColor, "▼ Settle: may play a 2nd world.")
                end
            else
                setHelpText(playerColor, "▼ Settle: may play a world.")
            end
        end
    elseif currentPhase == 4 then
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]

            if p.selectedCardPower == "TRADE_ACTION" then
                setHelpText(playerColor, "▲ Consume: select a good to sell.")
            elseif p.selectedCardPower == "DISCARD_HAND" then
                local reward = ""
                local power = info.activePowers["4"][p.selectedCardPower]
                if power.codes["GET_VP"] then reward = "get VP"
                elseif power.codes["GET_CARD"] then reward = "draw card"
                elseif power.codes["GET_PRESTIGE"] then reward = "get prestige"
                end

                local discardCount = p.handCountSnapshot - countCardsInHand(playerColor, false)
                local times = power.times
                if power.codes["CONSUME_TWO"] then
                    times = 2
                end
                local appendStr = ". (" .. discardCount .. "/" .. times .. ")"

                if discardCount < times then
                    p.canFlip = true
                    if power.codes["CONSUME_TWO"] then
                        p.canConfirm = false
                    end
                end

                setHelpText(playerColor, "▼ Consume: discard to " .. reward .. appendStr)
            elseif p.selectedCardPower == "CONSUME_PRESTIGE" then
                setHelpText(playerColor, "▲ Consume: use prestige?")
            else
                setHelpText(playerColor, "▲ Consume: select goods to consume.")
            end
        else
            setHelpText(playerColor, "▲ Consume: use powers.")
        end
    elseif currentPhase == 5 then
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]
            local power = info.activePowers["5"]
            local paidCost = p.paidCost[card.getGUID()]

            if p.selectedCardPower:sub(1,8) == "WINDFALL" or (p.selectedCardPower == "DISCARD_HAND" and (power["DISCARD_HAND"].codes["WINDFALL_ANY"] or power["DISCARD_HAND"].codes["WINDFALL_ALIEN"]) and paidCost) then
                setHelpText(playerColor, "▲ Produce: produce on windfall world.")
            elseif p.selectedCardPower == "DISCARD_HAND" then
                local discardCount = p.handCountSnapshot - countCardsInHand(playerColor, false)
                if discardCount < 1 then
                    p.canFlip = true
                end
                setHelpText(playerColor, "▼ Produce: discard to use power. (" .. discardCount .. "/1)")
            end
        else
            setHelpText(playerColor, "▲ Produce: use powers.")
        end
    elseif currentPhase == 100 then
        local maxHandSize = p.powersSnapshot["DISCARD_TO_12"] and 12 or 10
        local discardTarget = cardsInHand - maxHandSize
        discarded = cardsInHand - countCardsInHand(playerColor, false)

        if cardsInHand > maxHandSize then
            p.canFlip = true
            if discarded >= discardTarget then p.canReady = true end
            setHelpText(playerColor, "Enforce hand size. (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            p.canReady = true
            setHelpText(playerColor, "Round End: waiting for other players.")
        end
    end
end