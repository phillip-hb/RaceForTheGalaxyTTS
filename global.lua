require("util")
require("cardtxt")
require("gameUi")
require("vpCalculator")
require("helpText")

---1: starting hand, 0: select action. 100: end of round. Otherwise, index of selectedPhases
currentPhaseIndex = -1
gameStarted = false
advanced2p = false
placeTwoPhase = false
takeoverPhase = false
securityCouncilPhase = false
useTakeovers = false
queuePlaceTwoPhase = false
searchPhase = false
selectLastPhase = false
exploreAfterPhase = false
rebelSneakAttackPhase = false
queueRebelSneakAttackPhase = false
expansionLevel = 0
selectedPhases = {}
firstPlayer = "Yellow"
firstRound = false
-- nil if no choice was made, otherwise GUID of selected object

function player(i)
    return {
        index = i,
        selectedGoods = {},
        handCountSnapshot = 0,
        powersSnapshot = {},
        selectedCard = nil,
        selectedCardPower = "",
        cardsAlreadyUsed = {},
        miscSelectedCards = {},
        prevMiscSelectedCards = {},
        mustConsumeCount = 0,
        produceCount = {},
        paidCost = {},
        tempMilitary = 0,
        incomingGood = false,
        forcedReady = false,
        lastPlayedCard = nil,
        roundEndDiscardCount = 0,
        takeoverSource = nil,
        takeoverPower = nil,
        takeoverTarget = nil,
        beingTargeted = nil,
        usedPower = false,
        canReady = false,
        canFlip = false,
        canConfirm = false,
        beforeExplore = false,
        beforeDevelop = false,
        improvedLogistics = false,
        rebelSneakAttack = false,
        doTakeover = false,
        securityCouncil = false,
        securityCouncilTarget = nil,
        exploreAfterPower = false,
        upgradeWorldOld = nil,
        upgradeWorldNew = nil,
        startSavePhase = nil,
        selectedAnte = nil,
        anteSucceed = false,
        selectedReward = nil,
        recordedCards = {},
        prestigeChips = {},
        prestigeCount = 0,
        consumedPrestige = 0,
        markedGoods = {},
        ignoreCards = {},
        discardLaterFromTableau = {},
        takeoverMenuMap = {},
    }
end

playerData = {Yellow=player(1),Red=player(2),Blue=player(3),Green=player(4)}
playerOrder = {"Yellow", "Red", "Blue", "Green"}
queueUpdateState = {Yellow=false, Red=false, Blue=false, Green=false}
updateTimeSnapshot = {Yellow=0, Red=0, Blue=0, Green=0}

playmat12 = "http://cloud-3.steamusercontent.com/ugc/1867319584733434168/76E4F818BB730F1F8713043E8000EC832B60EE87/"
playmat14 = "http://cloud-3.steamusercontent.com/ugc/1930373378495832995/BB2FCAE46BF72CF143C028808B787EB109064297/"

gameEndMessage = false
gameDone = false
enforceRules = true
delayNextPhase = false
delayNextPhaseTime = 0
transitionNextPhase = false
triggerExploreAfterPhase = false

requiresConfirm = {["DISCARD_HAND"]=1, ["MILITARY_HAND"]=1, ["DISCARD"]=1, ["CONSUME_PRESTIGE"]=1, ["UPGRADE_WORLD"]=1,["DRAW_LUCKY"]=1,["ANTE_CARD"]=1,["PREVENT_TAKEOVER"]=1}
requiresGoods = {["TRADE_ACTION"]=1,["CONSUME_ANY"]=1,["CONSUME_NOVELTY"]=1,["CONSUME_RARE"]=1,["CONSUME_GENE"]=1,["CONSUME_ALIEN"]=1,["CONSUME_3_DIFF"]=1,["CONSUME_N_DIFF"]=1,["CONSUME_ALL"]=1}
canCancelAfter = {["MILITARY_HAND"]=1,["CONSUME_GENE"]=1,["CONSUME_RARE"]=1,["UPGRADE_WORLD"]=1,["CONSUME_PRESTIGE"]=1}
goodsHighlightColor = {
     ["NOVELTY"] = color(0.345, 0.709, 0.974),
     ["RARE"] = color(0.709, 0.407, 0.129),
     ["GENE"] = color(0.278, 0.760, 0.141),
     ["ALIEN"] = color(0.933, 0.909, 0.105)
}
optionalPowers = {["DISCARD_HAND"]=1,["DISCARD"]=1,["CONSUME_PRESTIGE"]=1,["ANTE_CARD"]=1}

-- Determines which settle powers can chain with other settle powers. If separated with '|', the first word is the key, the rest are matching codes.
-- Key = card's power, Value = what the key can be chained with
compatible = {
    ["DISCARD|EXTRA_MILITARY"] = {["MILITARY_HAND"]=1,["CONSUME_PRESTIGE"]=1},
    ["DISCARD_PLACE_MILITARY"] = {["DISCARD_CONQUER_SETTLE"]=1,["DISCARD|EXTRA_MILITARY"]=1,["MILITARY_HAND"]=1},
    ["DISCARD_CONQUER_SETTLE"] = {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_PLACE_MILITARY"]=1},
    ["DISCARD|TAKEOVER_MILITARY"] = {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_CONQUER_SETTLE"]=1},
    ["TAKEOVER_REBEL"] = {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_CONQUER_SETTLE"]=1},
    ["TAKEOVER_IMPERIUM"] = {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_CONQUER_SETTLE"]=1},
    ["TAKEOVER_PRESTIGE"] = {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_CONQUER_SETTLE"]=1},
    ["TAKEOVER_MILITARY"]= {["MILITARY_HAND"]=1,["DISCARD|EXTRA_MILITARY"]=1,["CONSUME_PRESTIGE"]=1,["DISCARD_CONQUER_SETTLE"]=1},
    ["PAY_MILITARY"] = {["DISCARD|REDUCE_ZERO"]=1,["CONSUME_GENE"]=1},
}

handZone_GUID = {"7556a6", "2a2c18", "0180e0", "84db02"}
tableauZone_GUID = {"2f8337", "6a2b88", "6707c2", "970244"}
actionSelectorMenu_GUID = {"b44250", "7552ef", "5c95f7", "74c6f0"}
actionZone_GUID = {"98db35", "eec17a", "be1ba1", "dc1b97"}
selectedActionZone_GUID = {"d507c0", "820d9e", "b1409d", "326786"}
presentedPhaseCardTile_GUID = {"082406", "3e3772", "a5737a", "2c39a5"}
tableau_GUID = {"3f1c4d", "bcf758", "a22fe5", "b4aab3"}
consumeTradeCard_GUID = {"8723c4", "095953", "1f756f", "0f845a"}
readyTokens_GUID = {"8f6042", "6ed6bc", "169b57", "718265"}
smallReadyTokens_GUID = {"dd182c", "ab5795", "37d9aa", "476374"}
helpDisplay_GUID = {"f9c4ee", "5a39e2", "515d9a", "1dbea0"}
statTracker_GUID = {"3b078d", "2ed5dd", "dc9bac", "8865a8"}
advanced2pCards_GUID = {"f4313a", "eead6a", "3ee2da", "09a79a"}
prestigeButton_GUID = {"a276bc", "b5027c", "09bbe0", "77721b"}

disableInteract_GUID = {presentedPhaseCardTile_GUID, tableau_GUID, readyTokens_GUID, smallReadyTokens_GUID, helpDisplay_GUID, statTracker_GUID, actionSelectorMenu_GUID}

vpPoolBag_GUID = "c2e459"
vpInfBag_GUID = "5719f7"
drawZone_GUID = "32297e"
discardZone_GUID = "fe5c37"
prestigeBag_GUID = "f3bcc8"

handZoneOwner = {
     ["7556a6"] = "Yellow",
     ["2a2c18"] = "Red",
     ["0180e0"] = "Blue",
     ["84db02"] = "Green"
}

tableauZoneOwner = {
     ["2f8337"] = "Yellow",
     ["6a2b88"] = "Red",
     ["6707c2"] = "Blue",
     ["970244"] = "Green",
}

phaseTilePlacement = {
     {"e536e3", {-4.48, 1.68, -5.60}},
     {"34d2e8", {-2.24, 1.68, -5.60}},
     {"8df356", {0.00, 1.68, -5.60}},
     {"842722", {2.24, 1.68, -5.60}},
     {"6c0780", {4.48, 1.68, -5.60}},
}

phaseTilePlacementAdv2p = {
     {"e536e3", {-6.72, 1.68, -5.60}},
     {"34d2e8", {-4.48, 1.68, -5.60}},
     {"e80c84", {-2.24, 1.68, -5.60}},
     {"8df356", {0.00, 1.68, -5.60}},
     {"33a1c8", {2.24, 1.68, -5.60}},
     {"842722", {4.48, 1.68, -5.60}},
     {"6c0780", {6.72, 1.68, -5.60}},
}

phaseIndex = {["Explore"] = 1, ["Develop"] = 2, ["Settle"] = 3, ["Consume"] = 4, ["Produce"] = 5}
phaseIndexAdv2p = {["Explore"] = 1, ["Develop"] = 2, ["DevelopAdv2p"] = 3, ["Settle"] = 4, ["SettleAdv2p"] = 5, ["Consume"] = 6, ["Produce"] = 7}
phaseText = {"Phase I: Explore", "Phase II: Develop", "Phase III: Settle", "Phase IV: Consume", "Phase V: Produce"}
phaseTextAdv2p = {"Phase I: Explore", "Phase II: Develop 1", "Phase II: Develop 2", "Phase III: Settle 1", "Phase III: Settle 2", "Phase IV: Consume", "Phase V: Produce"}
phaseCardNames = {"Explore (+5)", "Explore (+1,+1)", "Develop", "Settle", "Consume ($)", "Consume (x2)", "Produce", "Prestige / Search"}
phaseCardNamesAdv2p = {"Explore (+5)", "Explore (+1,+1)", "Develop", "DevelopAdv2p", "Settle", "SettleAdv2p", "Consume ($)", "Consume (x2)", "Produce", "Prestige / Search"}

goodsSnapPointOffset = {-0.6, 0.1, 0.4}
drawDeck_GUID = ""
discardPile = nil
vpBag = nil

function onSave()
    local saved_data = {}
    saved_data.gameStarted = gameStarted
    saved_data.currentPhaseIndex = currentPhaseIndex
    saved_data.selectedPhases = selectedPhases
    saved_data.drawDeck_GUID = drawDeck_GUID
    saved_data.advanced2p = advanced2p
    saved_data.playerData = playerData
    saved_data.placeTwoPhase = placeTwoPhase
    saved_data.takeoverPhase = takeoverPhase
    saved_data.useTakeovers = useTakeovers
    saved_data.queuePlaceTwoPhase = queuePlaceTwoPhase
    saved_data.enforceRules = enforceRules
    saved_data.expansionLevel = expansionLevel
    saved_data.searchPhase = searchPhase
    saved_data.selectLastPhase = selectLastPhase
    saved_data.exploreAfterPhase = exploreAfterPhase
    saved_data.firstPlayer = firstPlayer
    saved_data.rebelSneakAttackPhase = rebelSneakAttackPhase
    saved_data.queueRebelSneakAttackPhase = queueRebelSneakAttackPhase
    saved_data.securityCouncilPhase = securityCouncilPhase
    return JSON.encode(saved_data)
end

function onload(saved_data)
    componentsBag = getObjectFromGUID("4c1650")
    drawDeck = getObjectFromGUID(drawDeck_GUID)
    drawZone = getObjectFromGUID(drawZone_GUID)
    discardZone = getObjectFromGUID(discardZone_GUID)

    if saved_data ~= "" then
        local data = JSON.decode(saved_data)
        gameStarted = data.gameStarted
        currentPhaseIndex = data.currentPhaseIndex
        selectedPhases = data.selectedPhases
        drawDeck_GUID = data.drawDeck_GUID
        advanced2p = data.advanced2p
        playerData = data.playerData
        placeTwoPhase = data.placeTwoPhase or false
        takeoverPhase = data.takeoverPhase or false
        useTakeovers = data.useTakeovers or false
        queuePlaceTwoPhase = data.queuePlaceTwoPhase or false
        enforceRules = data.enforceRules
        expansionLevel = data.expansionLevel
        searchPhase = data.searchPhase
        selectLastPhase = data.selectLastPhase
        exploreAfterPhase = data.exploreAfterPhase
        firstPlayer = data.firstPlayer or "Yellow"
        rebelSneakAttackPhase = data.rebelSneakAttackPhase
        queueRebelSneakAttackPhase = data.queueRebelSneakAttackPhase
        securityCouncilPhase = data.securityCouncilPhase
    end

    rulesBtn = getObjectFromGUID("fe78ab")
    Wait.frames(function() rulesBtn.call("changeEnforceRulesButtonLabel", enforceRules) end, 1)

    card_db = loadData(0)

    trySetAdvanced2pMode()

    for i=1, #disableInteract_GUID do
        for j=1, #disableInteract_GUID[i] do
            local obj = getObjectFromGUID(disableInteract_GUID[i][j])
            if obj then obj.interactable = false end
        end
    end

    for _, o in pairs(getObjectsWithTag("Slot")) do
        o.interactable = false
    end

    handZoneMap = {}
    for i=1, #handZone_GUID do
        handZoneMap[handZone_GUID[i]] = true
    end

    tableauZoneMap = {}
    for i=1, #tableauZone_GUID do
        tableauZoneMap[tableauZone_GUID[i]] = true
    end

    sound = getObjectFromGUID("416393")
    sound.interactable = false

    for color, data in pairs(playerData) do
        local index = data.index
        local o = getObjectFromGUID(readyTokens_GUID[index])
        if o then
            o.setVar("player", color)
        end

        o = getObjectFromGUID(smallReadyTokens_GUID[index])
        if o then
            o.setVar("player", color)
        end

        local statTracker = getObjectFromGUID(statTracker_GUID[index])
        if statTracker then
            statTracker.call("createButtons")
        end

        queueUpdate(color)
    end

    updatePhaseTilesHighlight()

    if takeoverPhase then
        drawTakeoverLines()
    else
        Global.setVectorLines(getDefaultVectorLines())
    end

    redisplayXmlUi()
end

function none() end

-- ======================
-- Game specific helper functions
-- ======================
function redisplayXmlUi()
    local players = getSeatedPlayersWithHands()
    for _, player in pairs(players) do
        local p = playerData[player]
        if p.securityCouncil then
            showSecurityCouncilMenu(player)
        end
    end
end

function getName(obj)
     return obj.getName() .. (obj.hasTag("Adv2p") and "Adv2p" or "")
end

function getKind(card)
    local info = card_db[card.getName()]
    if info.goods then
        if info.goods == "ANY" then
            return card.getVar("kind")
        else
            return info.goods
        end
    end

    return nil
end

function isTakeoverPower(power)
    local takeoverPowers = {["TAKEOVER_IMPERIUM"]=1,["TAKEOVER_REBEL"]=1,["TAKEOVER_PRESTIGE"]=1,["TAKEOVER_MILITARY"]=1}
    if takeoverPowers[power.name] then
        return power.name
    else
        for name, _ in pairs(takeoverPowers) do
            if power.codes[name] then
                return name
            end
        end
    end

    return nil
end

function isUpgradingWorld(player)
    local node = playerData[player].miscSelectedCards
    return node and node.power and node.power.name == "UPGRADE_WORLD"
end

function cardAlreadyUsedInit()
    return {
        selectedCard = nil,
        triggerCard = nil,
        power = nil,
        strength = 0,
        markedDiscards = {},
        markedGoods = {}
    }
end

-- converts the raw phase value into corresponding actual phase. Use selectedPhases[currentPhaseIndex] to get the raw value instead.
function getCurrentPhase()
    local phase = selectedPhases[currentPhaseIndex]
    if advanced2p and phase then
        if phase == 3 then
            phase = 2
        elseif phase == 4 or phase == 5 then
            phase = 3
        elseif phase >= 6 and phase < 100 then
            phase = phase - 2
        end
    end

    return phase
end

function trySetAdvanced2pMode()
    if advanced2p then
        phaseTilePlacement = phaseTilePlacementAdv2p
        phaseIndex = phaseIndexAdv2p
        phaseCardNames = phaseCardNamesAdv2p
        phaseText = phaseTextAdv2p
    end
end

function countTrait(player, trait, name, cardType)
    local count = 0
    for card in allCardsInTableau(player) do
        if card.hasTag("Action Card") == false then
            local info = card_db[card.getName()]

            if cardType and cardType ~= info.type then
                goto skip
            end

            if trait == "goods" and getKind(card) == name or
                trait ~= "goods" and info[trait][name] then
                count = count + 1
            end

            ::skip::
        end
    end

    return count
end

-- Retrieves the good that is sitting on the card (if one exists)
function getGoods(card)
    local goods = nil
    local pos = card.positionToWorld(goodsSnapPointOffset)
    local hits = Physics.cast({
        origin = {pos[1], pos[2] + 2, pos[3]},
        direction = {0, -1, 0},
        max_distance = 4
    })

    for _, hit in pairs(hits) do
        if hit.hit_object.type == 'Card' and hit.hit_object.getDescription() == card.getGUID() then
            goods = hit.hit_object
            break
        end
    end

    return goods
end

function tryProduceAt(player, card)
    local info = card_db[card.getName()]
    local powers = info.passivePowers["5"]

    local goods = getGoods(card)
    if not goods then
        local p = playerData[player]
        local kind = getKind(card)

        -- no goods, produce on planet
        p.produceCount[kind] = p.produceCount[kind] + 1
        card.memo = placeGoodsAt(card.positionToWorld(goodsSnapPointOffset), card.getRotation()[2], player)

        if powers and powers["DRAW_IF"] then dealTo(powers["DRAW_IF"].strength, player) end
        if powers and powers["PRESTIGE_IF"] then getPrestigeChips(player, powers["PRESTIGE_IF"].strength) end

        return true
    end

    return false
end

function getVpChips(player, n)
    if not vpBag then
        vpBag = getObjectFromGUID(vpPoolBag_GUID)
        if not vpBag then
            vpBag = getObjectFromGUID(vpInfBag_GUID)
        end
    end

    local tableau = getObjectFromGUID(tableau_GUID[playerData[player].index])

    for i=1, n do
        if vpBag.type == "Bag" and #vpBag.getObjects() <= 0 then
            replaceVpBag()
        end

        local token = vpBag.takeObject({
            rotation = tableau.getRotation()
        })

        token.setPositionSmooth(tableau.positionToWorld({-1.4, 2, -0.8}), false, true)
    end

    if n > 0 then
        delayNextPhase = true
        delayNextPhaseTime = os.clock()
    end
end

function getPrestigeChips(player, n)
    local bag = getObjectFromGUID(prestigeBag_GUID)

    if not bag then return end

    local tableau = getObjectFromGUID(tableau_GUID[playerData[player].index])
    for i=1, n do
        local token = bag.takeObject({
            rotation = tableau.getRotation(),
        })
        token.setPositionSmooth(tableau.positionToWorld({-1.8, 2, -0.8}), false, true)
    end

    if n > 0 then
        delayNextPhase = true
        delayNextPhaseTime = os.clock()
    end
end

function replaceVpBag()
    if not vpBag then
        vpBag = getObjectFromGUID(vpPoolBag_GUID)
    end

    local oldBag = vpBag
    local bagPos = oldBag.getPosition()
    vpBag = getObjectFromGUID(vpInfBag_GUID)
    vpBag.setRotation({0, 0, 0})    -- need to set this else the token in the bag will not move
    vpBag.setPosition(bagPos)
    componentsBag.putObject(oldBag)
end

function checkIfSelectedAction(player, actionName)
    local zone = getObjectFromGUID(selectedActionZone_GUID[playerData[player].index])

    for _, obj in pairs(zone.getObjects()) do
        if obj.hasTag("Action Card") and obj.getName() == actionName then
            return obj
        end
    end

    return nil
end

-- countMarked = whether or not to include face-down cards in the count (default is true)
function countCardsInHand(playerColor, countMarked)
    countMarked = countMarked == nil and true or countMarked

    local objs = Player[playerColor].getHandObjects(1)

    if countMarked then
        return #objs
    else
        local n = 0

        for _, obj in pairs(objs) do
            if (not obj.hasTag("Discard") or obj.hasTag("Marked")) and not obj.hasTag("Action Card") then
                n = n + 1
            end
        end

        return n
    end
end

function getDiscardInHand(playerColor, countMarked)
    countMarked = countMarked == nil and false or countMarked
    local objs = Player[playerColor].getHandObjects(1)
    local results = {}
    for _, obj in pairs(objs) do
        if obj.hasTag("Discard") and not obj.hasTag("Marked") or countMarked then
            results[#results + 1] = obj
        end
    end
    return results
end

-- returns number of selected actions. 0 = no actions selected.
function getSelectedActionsCount(player)
    local i = playerData[player].index
    local zone = getObjectFromGUID(selectedActionZone_GUID[i])
    local n = 0

    for _, obj in pairs(zone.getObjects()) do
        if obj.hasTag("Action Card") then
            n = n + 1
        end
    end

    return n
end

function getOwner(card)
    for _, zone in pairs(card.getZones()) do
        if tableauZoneOwner[zone.getGUID()] then
            return tableauZoneOwner[zone.getGUID()]
        end
    end
    return nil
end

function toggleEnforceRulesClick(obj, player)
    enforceRules = not enforceRules
    rulesBtn.call("changeEnforceRulesButtonLabel", enforceRules)
    broadcastToAll("Enforce rules has been turned " .. (enforceRules and "ON." or "OFF."), "Purple")
end

-- Discards all cards that are face down in hand. Returns guid of cards discarded as list
function discardMarkedCards(player, markForDiscard)
    if markForDiscard == nil then markForDiscard = false end

    local cards = {}
    for _, obj in pairs(Player[player].getHandObjects(1)) do
        if obj.type == 'Card' and (obj.hasTag("Discard") or obj.is_face_down) then
            if markForDiscard and not obj.hasTag("Marked") then
                obj.addTag("Marked")
                cards[#cards + 1] = obj.getGUID()
            elseif not markForDiscard then
                discardCard(obj)
                cards[#cards + 1] = obj.getGUID()
            end
        end
    end
    return cards
end

function getMarkedCards(player, target)
    local cards = {}
    for _, obj in pairs(Player[player].getHandObjects(1)) do
        if obj.type == 'Card' and (obj.hasTag("Discard") or obj.is_face_down) then
            obj.deal(1, target)
            cards[#cards + 1] = obj
        end
    end
    return cards
end

-- Check hand zone for any 'Selected' cards and attempt to play them
function attemptPlayCard(card, player)
    if type(card) == "table" then
        player = card[2]
        card = card[1]
    end

    local p = playerData[player]
    local tableau = getObjectFromGUID(tableau_GUID[p.index])
    local sp = tableau.getSnapPoints()

    -- Find first empty spot on tableau
    for i=1, #sp do
        local hits = Physics.cast({
            origin = tableau.positionToWorld(add(sp[i].position, {0,1,0})),
            direction = {0, -1, 0},
            max_direction = 2
        })

        -- found empty spot
        if hits[1].hit_object.hasTag("Slot") then
            -- trigger certain power bonuses based on phase
            if currentPhaseIndex > 0 and currentPhaseIndex <= #selectedPhases then
                local powers = p.powersSnapshot
                if powers["DRAW_AFTER"] then
                    dealTo(powers["DRAW_AFTER"], player)
                end

                if powers["EXPLORE_AFTER"] then
                    triggerExploreAfterPhase = true
                    dealTo(powers["EXPLORE_AFTER"], player)
                end
            end

            local goods = getGoods(card)

            local pos = tableau.positionToWorld(sp[i].position)
            local rot = tableau.getRotation()
            if not takeoverPhase then
                card.setPosition(add(pos, {0, 0.04, 0}))
            else
                card.setPositionSmooth(add(pos, {0, 0.04, 0}))
            end
            card.setRotation({rot[1], rot[2], 0})
            card.removeTag("Selected")
            card.setLock(true)
            highlightOff(card)
            p.lastPlayedCard = card.getGUID()
            p.ignoreCards[card.getGUID()] = true

            local info = card_db[card.getName()]
            local isWindfall = info.flags["WINDFALL"]

            -- if windfall, place a goods on top
            if (isWindfall or p.powersSnapshot["AUTO_PRODUCE"]) and not takeoverPhase then
                placeGoodsAt(card.positionToWorld(goodsSnapPointOffset), rot[2], player)
            elseif isWindfall and takeoverPhase and goods then
                goods.setPositionSmooth(tableau.positionToWorld(add(sp[i].position, {-0.1, 1, 0.07})))
                goods.setRotationSmooth({rot[1], rot[2], 180})
                p.incomingGood = true
            end

            local usedPayMilitary = false
            local node = p.miscSelectedCards
            while node and node.value do
                if node.power.name == "PAY_MILITARY" then
                    usedPayMilitary = true
                    break
                end
                node = node.next
            end

            -- place prestige
            local currentPhase = getCurrentPhase()
            if expansionLevel >= 3 and 
                info.flags["PRESTIGE"] or p.powersSnapshot["PRESTIGE"] or
                info.type == 2 and info.cost == 6 and p.powersSnapshot["PRESTIGE_SIX"] or
                info.type == 1 and not info.flags["WINDFALL"] and info.goods and p.powersSnapshot["PRODUCE_PRESTIGE"] or
                info.type == 1 and usedPayMilitary and p.powersSnapshot["PAY_PRESTIGE"] or
                ((currentPhase == 2 and info.type == 2) or (currentPhase == 3 and info.type == 1)) and info.flags["REBEL"] and p.powersSnapshot["PRESTIGE_REBEL"] then
                getPrestigeChips(player, 1)
            end

            -- save card
            if p.powersSnapshot["SAVE_COST"] and (not info.flags["MILITARY"] or usedPayMilitary) then
                local discards = getDiscardInHand(player, false)
                if #discards > 0 then
                    local placeUnderTarget = getObjectFromGUID(p.powersSnapshot["START_SAVE"])
                    local savedCard = discards[1]
                    local possibleSaves = {}

                    for _, discard in pairs(discards) do
                        if nearAngle(discard.getRotation().y, Player[player].getHandTransform(1).rotation.y, 100) then
                            possibleSaves[#possibleSaves + 1] = discard
                        end
                    end

                    if #possibleSaves > 0 then
                        savedCard = possibleSaves[math.random(#possibleSaves)]
                    else
                        savedCard = discards[math.random(#discards)]
                    end
                    storeCard(placeUnderTarget, savedCard)
                end
            end
            return
        end
    end
end

function getTooltip(phase, power)
    local tooltip = activePowers[phase][power.name]
    if power.name == "DISCARD" or power.name == "CONSUME_PRESTIGE" then
        for code, v in pairs(power.codes) do
            if subtooltip[code] then
                tooltip = tooltip .. subtooltip[code]
                break
            end
        end
    end
    return tooltip
end

function placeGoodsAt(position, yRotation, player)
     local card = drawCard()

     if card then
          card.setPositionSmooth(add(position, {0, 1, 0}), false, true)
          card.setRotation({0, yRotation, 180})
          playerData[player].incomingGood = true
          delayNextPhase = true
          delayNextPhaseTime = os.clock()
     else
          -- shouldn't ever happen, but just in case
          broadcastToAll("Error: No cards detected in draw or discard pile", color(1,0,0))
     end

     return card
end

function reshuffleDiscardPile()
     -- no deck or card found, reshuffle discard and return that
     item = getDeckOrCardInZone(discardZone)
     if item then
          broadcastToAll("Reshuffling the discard pile.", "White")
          item.setRotationSmooth({0,180,180})
          item.setPositionSmooth(drawZone.getPosition())
          item.shuffle()
     end

     return item
end

function getDeckOrCardInZone(zone)
    for _, obj in pairs(zone.getObjects()) do
        if obj.type == 'Deck' or obj.type == 'Card' then
            return obj
        end
    end

    return nil
end

function drawCard()
    local card = nil
    if not drawDeck or drawDeck.isDestroyed() then
        drawDeck = getDeckOrCardInZone(drawZone)
        if not drawDeck then
            drawDeck = reshuffleDiscardPile()
        end
    end

    if drawDeck.type == 'Deck' then
        card = drawDeck.takeObject()

        if drawDeck.remainder then
            drawDeck = drawDeck.remainder
        end
    elseif drawDeck.type == 'Card' then
        card = drawDeck
        drawDeck = reshuffleDiscardPile()
    end

    drawDeck_GUID = drawDeck.getGUID()

    return card
end

function discardCard(card)
    local good = nil
    if card.getDescription() == '' then
        good = getGoods(card)
    end

    card.memo = ''
    card.setDescription('')
    card.setTags({})
    card.highlightOff()
    card.setScale({1,1,1})
    card.setLock(false)

    if not discardPile or discardPile.isDestroyed() then
        discardPile = getDeckOrCardInZone(discardZone)
    end

    if discardPile then
        card.setPosition(add(card.getPosition(), {0, discardZone.getPosition()[2], 0}))
        discardPile = discardPile.putObject(card)
        if good then
            discardCard(good)
        end
        return
    end

    discardPile = card
    card.setPosition(discardZone.getPosition())
    card.setRotation({0, 0, 180})

    if good then discardCard(good) end
end

function discardPrestige(player, n)
    local p = playerData[player]
    local prestigeBag = getObjectFromGUID(prestigeBag_GUID)

    if n > 0 then
        for k, v in pairs(p.prestigeChips) do
            local chips = getObjectFromGUID(k)
            if chips and chips.getQuantity() < 0 then
                prestigeBag.putObject(chips)
                n = n - 1
            elseif chips then
                -- stack of chips
                for i=1, chips.getQuantity() do
                    prestigeBag.putObject(chips.takeObject())
                    n = n - 1

                    if n <= 0 then break end
                end
            end

            if n <= 0 then break end
        end
    end

    if n > 0 then
        broadcastToAll("Error: " .. (Player[player].steam_name or player) .. " spent non-existing Prestige.", color(1,0,0))
        n = 0
    end
end

function dealTo(n, player)
    for i=1, n do
        local card = drawCard()
        Wait.frames(
            function()
                card.addTag("Ignore Tableau")
                card.deal(1, player)
            end, 1, 0)
    end
end

function resetPlayerState(playerColor)
    local p = playerData[playerColor]
    local index = p.index
    local incomingGood = p.incomingGood
    local recordedCards = p.recordedCards

    playerData[playerColor] = player(index)
    playerData[playerColor].incomingGood = incomingGood
    playerData[playerColor].canReady = false
    playerData[playerColor].recordedCards = recordedCards
end

-- Check to see if player is planning to do a takeover
function planningTakeover(player)
    local p = playerData[player]
    local phase = getCurrentPhase()
    if phase ~= 3 or p.selectedCard then return false end

    local node = p.miscSelectedCards

    while node and node.value do
        if isTakeoverPower(node.power) then
            return true
        end
        node = node.next
    end
end

function storeCard(targetCard, card)
    local yoff = targetCard.getBounds().size.y / 2
    local good = getGoods(targetCard)
    local hits = Physics.cast({
        origin = targetCard.getPosition(),
        direction = {0, -1, 0}
    })

    card.setTags({})
    card.highlightOff()
    highlightOff(card)

    for _, hit in pairs(hits) do
        local other = hit.hit_object
        if other.type == 'Deck' or other.type == 'Card' and other.getDescription() == "" and other.is_face_down then
            local bounds = other.getBounds()
            local pos = other.getPosition()

            other.setLock(false)
            other = other.putObject(card)
            pos.y = pos.y + bounds.size.y/2 + yoff
            targetCard.setPosition(pos)

            if good then
                local p = good.getPosition()
                p.y = pos.y + 0.03
                good.setPosition(p)
            end

            Wait.frames(function()
                other.setLock(true)
            end, 5)
            return     
        end
    end

    card.setPosition(targetCard.getPosition())
    card.setRotation({targetCard.getRotation().x, targetCard.getRotation().y, 180})
    card.setLock(true)
    local bounds = card.getBounds()
    local pos = targetCard.getPosition()
    pos.y = pos.y + bounds.size.y/2 + yoff

    if good then
        local p = good.getPosition()
        p.y = pos.y + 0.03
        good.setPosition(p)
    end

    targetCard.setPosition(pos)
end

-- iterator to go through all face-up cards in tableau plus the selection action card(s)
function allCardsInTableau(player)
    local pi = playerData[player].index
    local objs = getObjectFromGUID(tableauZone_GUID[pi]).getObjects()
    local actionCards = getObjectFromGUID(selectedActionZone_GUID[pi]).getObjects()

    for _, item in pairs(actionCards) do
        if item.hasTag("Action Card") then
            objs[#objs + 1] = item
        end
    end

    local n = #objs
    local i = 0

    return function()
        i = i + 1

        while i <= n and objs[i] and (objs[i].type ~= 'Card' or objs[i].is_face_down) do
            i = i + 1
        end

        if i <= n then
            return objs[i]
        end
    end
end

-- ======================
-- Event functions
-- ======================

function tryObjectRotate(object, spin, flip, player_color, old_spin, old_flip)
    local inHandZone = false

    local zones = object.getZones()
    for i=1, #zones do
        if handZoneMap[zones[i].getGUID()] then
            inHandZone = true
            break
        end
    end

    -- check to see if the object is in the player's hand zone to prevent mark for deletion
    if (object.hasTag("Selected") or 
        object.hasTag("Explore Highlight") and currentPhaseIndex == -1 or 
        not object.hasTag("Explore Highlight") and getCurrentPhase() == 1 and not playerData[player_color].beforeExplore) and
        inHandZone and flip == 180 then
        return false
    elseif object.hasTag("Marked") and inHandZone and flip == 0 then
        return false
    end

    if inHandZone and flip ~= old_flip and not object.hasTag("Selected") then
        if player_color then
            local p = playerData[player_color]
            if enforceRules and (not p.canFlip or p.canReady) and flip == 180 then
                return false
            end

            if p.upgradeWorldNew == object.getGUID() and flip == 180 then
                return false
            end
        end

        if flip == 180 then
            object.addTag("Discard")
            if player_color then updateReadyButtons({player_color, false}) end
        elseif flip == 0 then
            object.removeTag("Discard")
            if player_color then updateReadyButtons({player_color, false}) end
        end

        updateHelpText(player_color)
    end

    return true
end

function onObjectLeaveZone(zone, object)
    if object.isDestroyed() then return end

    local isHandZone = handZoneMap[zone.getGUID()]
    local isTableauZone = tableauZoneMap[zone.getGUID()]

    if zone == drawZone then
    --      drawDeck = nil
    -- elseif zone == discardZone then
    --      discardPile = nil
    elseif isHandZone then
        local player = handZoneOwner[zone.getGUID()]

        object.removeTag("Discard")
        object.clearButtons()

        if object.hasTag("Explore Highlight") then
            highlightOff(object)
        end

        queueUpdate(player)
    elseif isTableauZone then
        if object.hasTag("Ignore Tableau") then return end

        local player = tableauZoneOwner[zone.getGUID()]
        local p = playerData[player]
        local selectedCard = getObjectFromGUID(p.selectedCard)

        if object.type == 'Card' or object.hasTag("VP") then
            -- Force deselect for removing selected card from tableau
            if (getCurrentPhase() == 4 or getCurrentPhase() == 5) and selectedCard == object then
                p.selectedCard = nil
            end

            if not object.hasTag("Explore Highlight") then
                object.highlightOff()
                highlightOff(object)
            end

            if object.getScale()[1] < 1 and object.type == "Card" then
                object.setScale({1, 1, 1})
                object.setDescription("")
                displayXOff(object)

                if p.selectedGoods[object.getGUID()] then
                    p.selectedGoods[object.getGUID()] = nil
                end
            end

            if object.type == 'Card' then
                displayVpHexOff(object)
                object.setSnapPoints({})
                object.clearButtons()
                local slot = getCardSlot(object)
                if slot then slot.clearButtons() end
            end

            p.miscSelectedCards = deleteLinkedListNode(p.miscSelectedCards, object.getGUID())
            queueUpdate(player)
        end
    end
end

function onObjectEnterZone(zone, object)
    if object.isDestroyed() then return end

    local isHandZone = handZoneMap[zone.getGUID()]
    local isTableauZone = tableauZoneMap[zone.getGUID()]

    if isHandZone then
        local player = handZoneOwner[zone.getGUID()]

        if object.is_face_down then
            object.addTag("Discard")
        end

        if object.hasTag("Ignore Tableau") then
            object.removeTag("Ignore Tableau")
        end

        if object.type == 'Card' then
            displayVpHexOff(object)
        end

        queueUpdate(player)
    elseif isTableauZone and (object.type == 'Card' or object.hasTag("VP")) then
        if object.hasTag("Ignore Tableau") then return end

        local player = tableauZoneOwner[zone.getGUID()]

        if object.is_face_down then
            -- Check to see if card is below it to decide if this card is a goods card
            local hits = Physics.cast({
                origin = object.getPosition(),
                direction = {0, -1, 0},
                max_distance = 2
            })

            for _, hit in pairs(hits) do
                local o = hit.hit_object
                if o.type == 'Card' and not o.is_face_down then
                    local data = card_db[o.getName()]
                    if data and data.goods then
                        object.setScale({0.6, 1, 0.6})
                        object.setDescription(o.getGUID())
                        object.highlightOn(goodsHighlightColor[getKind(o)])
                        playerData[player].incomingGood = false
                        break
                    end
                end
            end
        -- face up card, check if need to place snap point for goods placement
        else
            local data = card_db[object.getName()]
            if data and data.goods then
                object.setSnapPoints({{
                    position = goodsSnapPointOffset,
                    rotation = {0, 0, 0},
                    rotation_snap = true
                }})
            end
        end

        queueUpdate(player)
     end
end

function onObjectEnterContainer(container, enter_object)
    if container.hasTag("VP") then
        for _, zone in pairs(container.getZones()) do
            local owner = tableauZoneOwner[zone.getGUID()]
            if owner then
                queueUpdate(owner)
                return
            end
        end
    end
end

function onObjectLeaveContainer(container, leave_object)
    if container.hasTag("VP") then
        for _, zone in pairs(container.getZones()) do
            local owner = tableauZoneOwner[zone.getGUID()]
            if owner then
                queueUpdate(owner)
                return
            end
        end
    end
end

function onUpdate()
    for player, willUpdate in pairs(queueUpdateState) do
        if willUpdate and os.clock() > updateTimeSnapshot[player] + 0.2 then
            queueUpdateState[player] = false

            local p = playerData[player]
            if p.selectedCard and not getObjectFromGUID(p.selectedCard) then
                p.selectedCard = nil
                p.selectedCardPower = ""
                p.miscSelectedCards = {}
            end

            capturePowersSnapshot(player, tostring(getCurrentPhase()))
            updateHandState(player)
            updateTableauState(player)
            updateVp(player)
            updateHelpText(player)
        end
    end
end

function queueUpdate(playerColor, now)
     now = now or false
     queueUpdateState[playerColor] = true
     updateTimeSnapshot[playerColor] = now and 0 or os.clock()
end

-- ======================
-- Game functions
-- ======================

function gameStart(params)
    playerData = {Yellow=player(1),Red=player(2),Blue=player(3),Green=player(4)}

    firstRound = true
    gameStarted = true
    currentPhaseIndex = -1
    advanced2p = params.advanced2p
    useTakeovers = params.takeovers
    expansionLevel = params.expansionLevel

    trySetAdvanced2pMode()

    for _, data in pairs(phaseTilePlacement) do
        local tile = componentsBag.takeObject({
            guid = data[1],
            position = data[2],
            rotation = {0, 180, 180},
            smooth = false
        })

        tile.setLock(true)
        tile.interactable = false
    end

    for player, data in pairs(playerData) do
        local i = data.index
        data.handCountSnapshot = 6

        -- remove prestige search card
        if expansionLevel < 3 then
            local cards = getObjectsWithTag("PrestigeSearch")
            for _, card in pairs(cards) do
                componentsBag.putObject(card)
            end
        else
            -- add the prestige search button to menu
            local menu = getObjectFromGUID(actionSelectorMenu_GUID[i])
            local btn = componentsBag.takeObject({
                guid = prestigeButton_GUID[i],
                position = menu.positionToWorld({10.05, 0, 0}),
                rotation = menu.getRotation(),
                smooth = false,
                callback_function = function(x)
                    x.setLock(true)
                    x.interactable = false
                end
            })
        end

        -- remove 2p adv cards
        if advanced2p == false then
            local cards = getObjectsWithTag("Adv2p")
            for _, card in pairs(cards) do
                componentsBag.putObject(card)
            end
        else
            getObjectFromGUID(actionSelectorMenu_GUID[i]).rotate({0, 0, 180})
        end
    end

    broadcastToAll("Determine your starting hand.", "White")
end

function playerReadyClicked(playerColor, forced, playSound)
    local p = playerData[playerColor]
    local count = getSelectedActionsCount(playerColor)
    local currentPhase = getCurrentPhase()
    local maxCount = advanced2p and 2 or 1

    if p.powersSnapshot["SELECT_LAST"] and not selectLastPhase then maxCount = maxCount - 1 end

    if transitionNextPhase then
        updateReadyButtons({playerColor, false})
        return
    end

    if currentPhaseIndex < 0 and enforceRules then
        if not p.selectedCard then
            broadcastToColor("You must select a start world.", playerColor, "White")
            updateReadyButtons({playerColor, false})
            return
        elseif not p.canReady then
            broadcastToColor("Please discard the required number of cards.", playerColor, "White")
            updateReadyButtons({playerColor, false})
            return
        end
    elseif currentPhaseIndex == 0 and (advanced2p and count < maxCount or not advanced2p and count < maxCount) then
        if advanced2p then
            if p.powersSnapshot["SELECT_LAST"] then
                broadcastToColor("You must select at least 1 action card!", playerColor, "White")
            else
                broadcastToColor("You must select 2 action cards!", playerColor, "White")
            end
        else
            broadcastToColor("You must select an action card!", playerColor, "White")
        end

        updateReadyButtons({playerColor, false})
        return
    elseif currentPhase == 1 then
        if enforceRules then
            if p.beforeExplore then
                broadcastToColor("You must confirm the card's power before clicking ready!", playerColor, "White")
                return
            elseif not p.canReady then
                broadcastToColor("Please discard the required number of cards.", playerColor, "White")
                updateReadyButtons({playerColor, false})
                return
            end
        end
    elseif currentPhase == 2 or currentPhase == 3 then
        local node = getLastNode(p.miscSelectedCards)

        if p.beforeDevelop or p.exploreAfterPower or node and node.power and requiresConfirm[concatPowerName(node.power)] then
            broadcastToColor("You must confirm or cancel the card's power before clicking ready!", playerColor, "White")
            updateReadyButtons({playerColor, false})
            return
        end
        if currentPhase == 3 and planningTakeover(playerColor) and not p.takeoverTarget then
            broadcastToColor("You must have a valid takeover target.", playerColor, "White")
            updateReadyButtons({playerColor, false})
            return
        end
        if rebelSneakAttackPhase and p.rebelSneakAttack and p.selectedCard then
            local info = card_db[getObjectFromGUID(p.selectedCard).getName()]
            local conquerSettle = false
            local node = p.miscSelectedCards
            while node and node.value do
                if node.power.name == "DISCARD_CONQUER_SETTLE" then
                    conquerSettle = true
                    break
                end
                node = node.next
            end
            if not info.flags["MILITARY"] and not conquerSettle then
                broadcastToColor("You can only play Military worlds or use 'conquer non-military world' power.", playerColor, "White")
                updateReadyButtons({playerColor, false})
                return
            end
        elseif securityCouncilPhase and p.securityCouncil then
            broadcastToColor("You must confirm or cancel the card's power before clicking ready!", playerColor, "White")
            return
        end

        if enforceRules and p.selectedCard and not p.canReady then
            local info = card_db[getObjectFromGUID(p.selectedCard).getName()]
            local payMilitary = false
            local node = p.miscSelectedCards
            while node and node.value do -- check for some flags
                if node.power.name == "PAY_MILITARY" then payMilitary = true end
                node = node.next
            end
            if currentPhase == 3 and info.flags["MILITARY"] and not payMilitary then
                broadcastToColor("You do not have enough Military.", playerColor, "White")
            else
                broadcastToColor("Please discard the required number of cards.", playerColor, "White")
            end
            updateReadyButtons({playerColor, false})
            return
        end
    elseif currentPhase == 4 or currentPhase == 5 then
        if p.selectedCard then
            local info = card_db[getObjectFromGUID(p.selectedCard).getName()]
            if info.activePowers[tostring(currentPhase)] then
                local power = info.activePowers[tostring(currentPhase)][p.selectedCardPower]
                if power and requiresConfirm[concatPowerName(power)] then
                    broadcastToColor("You must confirm or cancel the card's power before clicking ready!", playerColor, "White")
                    updateReadyButtons({playerColor, false})
                    return
                end
            end
        end

        if enforceRules and not p.canReady then
            broadcastToColor("You have remaining powers to use.", playerColor, "White")
            updateReadyButtons({playerColor, false})
            return
        end
    elseif currentPhase == 100 and enforceRules and not p.canReady then
        broadcastToColor("Please discard the required number of cards.", playerColor, "White")
        updateReadyButtons({playerColor, false})
        return
    end

    if playSound then
        sound.AssetBundle.playTriggerEffect(3)
    end
    startLuaCoroutine(Global, "checkAllReadyCo")
end

function finalizeUsedResources(player)
    local p = playerData[player]
    for guid, v in pairs(p.markedGoods) do
        local good = getObjectFromGUID(guid)
        if good then
            displayXOff(good)
            discardCard(good)
        end

        if v.power.codes["EXTRA_MILITARY"] then
            p.tempMilitary = p.tempMilitary + v.power.strength
        end
    end

    -- remove used prestige
    discardPrestige(player, p.consumedPrestige)

    p.markedGoods = {}
    p.consumedPrestige = 0
end

-- Makes all the ready buttons belonging to player the same toggle state
-- [1] = owner, [2] = state
function updateReadyButtons(params)
    local player = params[1]
    local state = params[2]
    local playSound = false
    if #params >= 3 then
        playSound = params[3]
    end
    local i = playerData[player].index
    local token = getObjectFromGUID(readyTokens_GUID[i])
    if token then token.call("setToggleState", state) end
    token = getObjectFromGUID(smallReadyTokens_GUID[i])
    if token then token.call("setToggleState", state) end

    if params[2] then
        playerReadyClicked(player, true, playSound)
    end
end

function checkAllReadyCo()
    -- Check if all players are ready to move on to next step of game
    local players = getSeatedPlayersWithHands()
    local triggerSelectLast = false
    local selectLastPlayer = nil

    triggerExploreAfterPhase = false

    for _, player in pairs(players) do
        local readyToken = getObjectFromGUID(readyTokens_GUID[playerData[player].index])
        if readyToken and not readyToken.getVar("isReady") then return 1 end
        if playerData[player].powersSnapshot["SELECT_LAST"] then
            triggerSelectLast = true
            selectLastPlayer = player
        end
    end

    transitionNextPhase = true
    Wait.time(function() transitionNextPhase = false end, 3)

    Global.setVectorLines(getDefaultVectorLines())

    local discardHappened = false
    local takeDiscard = nil
    local phase = getCurrentPhase()

    for _, player in pairs(players) do
        local p = playerData[player]
        local node = p.miscSelectedCards

        p.lastPlayedCard = nil

        Global.UI.setAttribute("takeoverMenu_" .. player, "active", false)
        if p.powersSnapshot["TAKE_DISCARDS"] and phase == 100 then takeDiscard = player end

        -- remove misc selected cards if they have discard power
        while node and node.value do
            local card = getObjectFromGUID(node.value)
            if card then
                local info = card_db[card.getName()]
                local power = node.power
                if power and (power.name == 'DISCARD' and not power.codes["TAKEOVER_MILITARY"] or power.name == "DISCARD_REDUCE" or power.name == "DISCARD_CONQUER_SETTLE") then
                    if power.name == "DISCARD_CONQUER_SETTLE" or info.passivePowers["3"] and (info.passivePowers["3"]["EXTRA_MILITARY"] or info.passivePowers["3"]["BONUS_MILITARY"])
                        or power.name == "DISCARD" and isTakeoverPower(power) then
                        local data = cardAlreadyUsedInit()
                        
                        data.triggerCard = node.value
                        data.selectedCard = node.value

                        p.discardLaterFromTableau[card.getGUID()] = true

                        if not p.cardsAlreadyUsed[node.value] then p.cardsAlreadyUsed[node.value] = {} end
                        p.cardsAlreadyUsed[node.value][power.name] = data
                    else
                        discardCard(card)
                        discardHappened = true
                        if power.name == 'DISCARD' and power.codes["EXTRA_MILITARY"] then
                            p.tempMilitary = p.tempMilitary + power.strength
                        end
                    end
                end
            end
            node = node.next
        end

        -- remove marked goods
        if not p.takeoverTarget then
            finalizeUsedResources(player)
        end
    end

    if discardHappened then wait(0.1) end

    -- resolve takeovers
    if takeoverPhase and resolveTakeovers() then
        wait(1.5)
    end

    -- play selected cards in hand
    for _, player in pairs(players) do
        local p = playerData[player]
        for _, obj in pairs(Player[player].getHandObjects(1)) do
            if obj.type == 'Card' and obj.hasTag("Selected") then
                attemptPlayCard(obj, player)
            elseif not phase and obj.hasTag("Explore Highlight") then
                -- discard not selected starting homeworld
                discardCard(obj)
            end
        end

        -- Upgrade world
        if p.upgradeWorldOld and p.upgradeWorldNew then
            local old = getObjectFromGUID(p.upgradeWorldOld)
            local new = getObjectFromGUID(p.upgradeWorldNew)
            local newInfo = card_db[new.getName()]
            local oldPos = old.getPosition()
            local oldRot = old.getRotation()

            highlightOff(old)
            highlightOff(new)

            discardCard(old)

            new.setPosition(oldPos)
            new.setRotation(oldRot)
            new.setLock(true)

            p.ignoreCards[#p.ignoreCards + 1] = new

            if newInfo.flags["WINDFALL"] then
                wait(0.1)
                placeGoodsAt(new.positionToWorld(goodsSnapPointOffset), oldRot[2], player)
            end

            if expansionLevel >= 3 then
                local n = 1
                if newInfo.flags["PRESTIGE"] then
                    n = n + 1
                end
                getPrestigeChips(player, n)
            end
        end

        -- Set flags for rebel sneak attack
        if not takeoverPhase and not rebelSneakAttackPhase and phase == 3 and p.powersSnapshot["DISCARD_PLACE_MILITARY"] and p.lastPlayedCard then
            p.rebelSneakAttack = true
            queueRebelSneakAttackPhase = true
        end
        
        -- Set flags for improved logistics
        if not placeTwoPhase and phase == 3 and p.powersSnapshot["PLACE_TWO"] and p.lastPlayedCard and not rebelSneakAttackPhase then
            p.improvedLogistics = true
            queuePlaceTwoPhase = true
        end

        -- discard all face down cards in hand
        if currentPhaseIndex ~= 0 then
            local n = 0

            if takeDiscard then
                n = getMarkedCards(player, takeDiscard)
            else
                n = #discardMarkedCards(player)
            end

            if currentPhaseIndex == #selectedPhases then
                p.roundEndDiscardCount = n
            end
        end
        p.selectedCard = nil
    end

    wait(0.1)

    -- figure out who the 'first' player is going to be
    if firstRound then
        wait(0.2)
        local lowest = 100
        local index = 0

        for i, player in pairs(players) do
            local n = getStartWorldNumber(player)
            if n < lowest then
                lowest = n
                firstPlayer = player
                index = i
            end
        end

        firstRound = false
    end

    for _, player in pairs(players) do
        playerData[player].prevMiscSelectedCards = playerData[player].miscSelectedCards
        playerData[player].miscSelectedCards = {}
        updateReadyButtons({player, false})
        queueUpdate(player, true)
        playerData[player].beingTargeted = nil
    end

    -- Trigger Imperium Fuel Depot
    if triggerExploreAfterPhase and not exploreAfterPhase then
        exploreAfterPhase = true
        wait(1)
        transitionNextPhase = false
        for _, player in pairs(players) do
            local p = playerData[player]
            if p.powersSnapshot["EXPLORE_AFTER"] then
                broadcastToAll("Waiting for " .. (Player[player].steam_name or player) .. " to resolve \"Imperium Fuel Depot.\"", player)
                p.exploreAfterPower = true
                p.handCountSnapshot = countCardsInHand(player)
            else
                updateReadyButtons({player, true})
            end
            queueUpdate(player)
        end
        sound.AssetBundle.playTriggerEffect(1)
        return 1
    else
        exploreAfterPhase = false
    end

    -- Trigger takeovers
    if useTakeovers and not takeoverPhase then
        local takeoverTriggered = false
        local canPreventTakeover = nil
        for _, player in pairs(players) do
            local p = playerData[player]
            if p.takeoverTarget then
                broadcastToAll((Player[player].steam_name or player) .. " is attempting a takeover!", player)
                takeoverTriggered = true
                p.doTakeover = true

                -- Check if spending prestige
                local node = p.prevMiscSelectedCards
                if node.power and node.power.name == "TAKEOVER_PRESTIGE" then
                    discardPrestige(player, 1)
                end

                local card = getObjectFromGUID(p.takeoverTarget)
                local targetPlayer = tableauZoneOwner[card.getZones()[1].getGUID()]
                local otherp = playerData[targetPlayer]

                if not otherp.beingTargeted then otherp.beingTargeted = {} end

                otherp.beingTargeted[p.takeoverTarget] = true
                if Player[targetPlayer].seated then
                    broadcastToColor("You are being targeted for a takeover by " .. (Player[player].steam_name or player) .. "!", targetPlayer, "Purple")
                end
            end

            if p.powersSnapshot["PREVENT_TAKEOVER"] and p.prestigeCount > 0 then
                canPreventTakeover = player
            end
        end

        if takeoverTriggered then
            takeoverPhase = true
            drawTakeoverLines()
            if canPreventTakeover then
                wait(1)
                securityCouncilPhase = true
                sound.AssetBundle.playTriggerEffect(1)
                local activePlayer = canPreventTakeover
                broadcastToAll("Waiting for " .. (Player[activePlayer].steam_name or activePlayer) .. " to resolve \"Pan-Galactic Security Council.\"", activePlayer)
                playerData[activePlayer].securityCouncilTarget = nil
                showSecurityCouncilMenu(activePlayer)
                wait(0.5)
                transitionNextPhase = false
                for _, player in pairs(players) do
                    if player ~= activePlayer then
                        updateReadyButtons({player, true})
                    else
                        playerData[player].securityCouncil = true
                    end
                    queueUpdate(player, true)
                end
                return 1
            end
            wait(0.5)
            transitionNextPhase = false
            for _, player in pairs(players) do
                if not playerData[player].beingTargeted then
                    updateReadyButtons({player, true})
                end
            end
            return 1
        end
    else
        takeoverPhase = false
    end

    -- Trigger Rebel Sneak Attack
    if queueRebelSneakAttackPhase and not rebelSneakAttackPhase then
        queueRebelSneakAttackPhase = false
        rebelSneakAttackPhase = true
        wait(0.1)
        transitionNextPhase = false
        for _, player in pairs(players) do
            local p = playerData[player]
            if p.rebelSneakAttack then
                broadcastToAll("Waiting for " .. (Player[player].steam_name or player) .. " to resolve \"Rebel Sneak Attack.\"", player)
            end
            updateReadyButtons({player, not p.rebelSneakAttack})
            queueUpdate(player)
        end
        sound.AssetBundle.playTriggerEffect(1)
        return 1
    else
        for _, player in pairs(players) do
            local p = playerData[player]
            p.rebelSneakAttack = false
        end
        rebelSneakAttackPhase = false
    end

    -- Trigger Improved Logistics
    if queuePlaceTwoPhase and not placeTwoPhase then
        placeTwoPhase = true
        sound.AssetBundle.playTriggerEffect(1)
        wait(0.1)
        transitionNextPhase = false
        for _, player in pairs(players) do
            if playerData[player].improvedLogistics then
                broadcastToAll("Waiting for " .. (Player[player].steam_name or player) .. "'s to resolve Improved Logistics.", player)
            else
                updateReadyButtons({player, true})
            end
            queueUpdate(player)
        end
        return 1
    end

    -- Delete marked cards
    for _, player in pairs(players) do
        local p = playerData[player]
        for guid, _ in pairs(p.discardLaterFromTableau) do
            local card = getObjectFromGUID(guid)
            if card then discardCard(card) end
        end

        p.discardLaterFromTableau = {}
    end

    if gameStarted and currentPhaseIndex == -1 then
        startNewRound()
        transitionNextPhase = false
        return 1
    end

    -- delay time if needed to process moving cards or tokens
    if delayNextPhase then
        delayNextPhase = false
        local delayTime = math.max(1.5 - (os.clock() - delayNextPhaseTime), 0)
        wait(delayTime)
    end

    if currentPhaseIndex == 0 then  -- All players have selected an action
        local phases = {}
        firstRound = false

        -- flip over all selected phase cards and phase tiles
        for _, guid in pairs(selectedActionZone_GUID) do
            local zone = getObjectFromGUID(guid)
            local selectedActions = {}

            for _, obj in pairs(zone.getObjects()) do
                if obj.hasTag("Action Card") then
                    if obj.is_face_down then obj.flip() end
                    local name = split(getName(obj), " ")[1]
                    selectedActions[name] = true
                end
            end

            -- Doing some checks for double selection of phase cards for 2p advanced variant
            if selectedActions["DevelopAdv2p"] and not selectedActions["Develop"] then
                selectedActions["DevelopAdv2p"] = nil
                selectedActions["Develop"] = true
            end

            if selectedActions["SettleAdv2p"] and not selectedActions["Settle"] then
                selectedActions["SettleAdv2p"] = nil
                selectedActions["Settle"] = true
            end

            for name, value in pairs(selectedActions) do
                if value then phases[name] = true end
            end
        end

        -- Check for select last
        if triggerSelectLast and selectLastPlayer and not selectLastPhase then
            wait(0.5)
            transitionNextPhase = false
            selectLastPhase = true
            broadcastToAll((Player[selectLastPlayer].steam_name or selectLastPlayer) .. " gets to select an action card after all other players reveals theirs.", selectLastPlayer)
            for _, player in pairs(players) do
                if player ~= selectLastPlayer then
                    updateReadyButtons({player, true})
                end
            end
            return 1
        end

        for phase, _ in pairs(phases) do
            local index = phaseIndex[phase]
            local tile = getObjectFromGUID(phaseTilePlacement[index][1])
            tile.setRotationSmooth({0, 180, 0})
            selectedPhases[#selectedPhases + 1] = phaseIndex[phase]
        end

        selectedPhases[#selectedPhases + 1] = 100
        table.sort(selectedPhases)
        currentPhaseIndex = -1000

        wait(1.25)

        beginNextPhase()
    elseif currentPhaseIndex >= 1 then
        for player, data in pairs(playerData) do
            capturePowersSnapshot(player, tostring(getCurrentPhase()))
        end
        endOfPhaseGoalCheck()

        if currentPhaseIndex > #selectedPhases then
            -- round end
        else
            beginNextPhase()
        end
    end
    transitionNextPhase = false
    return 1
end

function startNewRound()
    selectLastPhase = false
    selectedPhases = {}
    resetPhaseTiles()

    if checkEndGame() and not gameDone then
        gameDone = true
        wait(1.5)
        broadcastToAll("The game has ended.", "Purple")
        sound.AssetBundle.playTriggerEffect(4)
    elseif currentPhaseIndex ~= 0 then
        broadcastToAll("Starting new round.", color(0, 1, 1))
        sound.AssetBundle.playTriggerEffect(2)
    end

    currentPhaseIndex = 0

    for player, data in pairs(playerData) do
        resetPlayerState(player)
        updateReadyButtons({player, false})
        queueUpdate(player, true)
    end

    startLuaCoroutine(self, "returnActionCardsCo")
end

function returnActionCardsCo()
     for i=1, 4 do
          local o = getObjectFromGUID(actionSelectorMenu_GUID[i])
          o.call("returnSelectedActionCard")
     end

     return 1
end

function beginNextPhase()
     -- This shouldn't happen at all, but if it did...
    if not selectedPhases or #selectedPhases <= 0  then
        broadcastToAll("Error: No phases selected.", color(1,0,0))
        startNewRound()
        return 1
    end

    local phase = getCurrentPhase()

    if currentPhaseIndex <= 0 then currentPhaseIndex = 0 end

    queuePlaceTwoPhase = false
    placeTwoPhase = false
    queueRebelSneakAttackPhase = false
    rebelSneakAttackPhase = false
    takeoverPhase = false
    securityCouncilPhase = false

    -- Apply end of phase powers here
    if phase == 5 then
        -- Count total produce
        for player, data in pairs(playerData) do
            data.produceCount["TOTAL"] = 0
            for type, value in pairs(data.produceCount) do
                data.produceCount["TOTAL"] = data.produceCount["TOTAL"] + value
            end
        end

        local tieRare = false
        local tieChromo = false
        local tieProduce = false
        local most = {["RARE"]=nil,["CHROMO_WORLDS"]=nil,["TOTAL"]=nil}
        for player, data in pairs(playerData) do
            if not most["RARE"] or data.produceCount["RARE"] > playerData[most["RARE"]].produceCount["RARE"]  then
                tieRare = false
                most["RARE"] = player
            elseif data.produceCount["RARE"] == playerData[most["RARE"]].produceCount["RARE"] then
                tieRare = true
            end

            if not most["CHROMO_WORLDS"] or data.powersSnapshot["CHROMO_WORLDS"] > playerData[most["CHROMO_WORLDS"]].powersSnapshot["CHROMO_WORLDS"] then
                tieChromo = false
                most["CHROMO_WORLDS"] = player
            elseif data.powersSnapshot["CHROMO_WORLDS"] == playerData[most["CHROMO_WORLDS"]].powersSnapshot["CHROMO_WORLDS"] then
                tieChromo = true
            end

            if not most["TOTAL"] or data.produceCount["TOTAL"] > playerData[most["TOTAL"]].produceCount["TOTAL"] then
                tieProduce = false
                most["TOTAL"] = player
            elseif data.produceCount["TOTAL"] == playerData[most["TOTAL"]].produceCount["TOTAL"] then
                tieProduce = true
            end
        end

        for player, data in pairs(playerData) do
            if data.powersSnapshot["DRAW_MOST_RARE"] then
                if tieRare or most["RARE"] ~= player then
                    broadcastToColor("Mining Conglomerate: You did not produce the most Rare goods this phase.", player, "Grey")
                elseif most["RARE"] == player then
                    broadcastToColor("Mining Conglomerate: You produced the most Rare goods this phase.", player, player)
                    dealTo(data.powersSnapshot["DRAW_MOST_RARE"], player)
                end
            end

            if data.powersSnapshot["PRESTIGE_MOST_CHROMO"] then
                if tieChromo or most["CHROMO_WORLDS"] ~= player then
                    broadcastToColor("Ravaged Uplift World: You do not have the most Chromosome worlds in your tableau.", player, "Grey")
                elseif most["CHROMO_WORLDS"] == player then
                    broadcastToColor("Ravaged Uplift World: You have the most Chromosome worlds in your tableau.", player, player)
                    getPrestigeChips(player, 1)
                end
            end

            if data.powersSnapshot["DRAW_MOST_PRODUCED"] then
                if tieProduce or most["TOTAL"] ~= player then
                    broadcastToColor("Pan-Galactic Affluence: You did not produce the most goods this phase.", player, "Grey")
                elseif most["TOTAL"] == player then
                    broadcastToColor("Pan-Galactic Affluence: You produced the most goods this phase.", player, player)
                    dealTo(data.powersSnapshot["DRAW_MOST_PRODUCED"], player)
                end
            end
        end
    end

    currentPhaseIndex = currentPhaseIndex + 1
    phase = getCurrentPhase()

    for player, data in pairs(playerData) do
        resetPlayerState(player)
        updateReadyButtons({player, false})
    end
    updatePhaseTilesHighlight()

    if currentPhaseIndex <= #selectedPhases - 1 then
        broadcastToAll(phaseText[selectedPhases[currentPhaseIndex]], "White")
        sound.AssetBundle.playTriggerEffect(0)

        if phase == 1 then
            startExplorePhase()
        elseif phase == 2 then
            startDevelopPhase()
        elseif phase == 3 then
            startSettlePhase()
        elseif phase == 4 then
            startConsumePhase()
        elseif phase == 5 then
            startProducePhase()
        end
    elseif currentPhaseIndex == #selectedPhases then
        broadcastToAll("End of round.", "White")
        wait(1)
        -- Check if any players need to discard cards
        local skipPlayers = {}
        local mustDiscard = false
        local players = getSeatedPlayersWithHands()
        for _, player in pairs(players) do
            local p = playerData[player]
            local n = countCardsInHand(player)
            local maxHandSize = p.powersSnapshot["DISCARD_TO_12"] and 12 or 10
            p.handCountSnapshot = n
            if n > maxHandSize then
                mustDiscard = true
                transitionNextPhase = false
                broadcastToAll((Player[player].steam_name or player) .. " must discard down to " .. maxHandSize .. " cards.", player)
            else
                skipPlayers[player] = true
            end
        end

        if not mustDiscard then
            startNewRound()
        else
            sound.AssetBundle.playTriggerEffect(1)
            for player, skip in pairs(skipPlayers) do
                playerData[player].canReady = true
                updateReadyButtons({player, true})
            end
        end
    else
        -- end of round
        startNewRound()
    end

    for player, data in pairs(playerData) do
        data.usedPower = true
        queueUpdate(player, true)
    end
end

function checkEndGame()
    if not gameEndMessage then
        for player, data in pairs(playerData) do
            local p = playerData[player]
            local count = 0
            for card in allCardsInTableau(player) do
                if not card.hasTag("Ignore Tableau") and not card.is_face_down and not card.hasTag("Action Card") then
                    count = count + 1
                end
            end

            local limit = 12
            if p.powersSnapshot["GAME_END_14"] then limit = 14 end
            if count >= limit then
                broadcastToAll((Player[player].steam_name or player) .. " has played " .. limit .. " cards in their tableau.", player)
                gameEndMessage = true
            end
        end
    end

    return gameEndMessage
end

function updatePhaseTilesHighlight()
    phaseTilesHighlightOff()

    local phase = selectedPhases[currentPhaseIndex]
    if phase and phase < 100 then
        -- hilight current phase tile
        local tile = getObjectFromGUID(phaseTilePlacement[phase][1])
        tile.UI.setAttribute("highlight", "active", true)
    end
end

function phaseTilesHighlightOff()
    for i=1, #phaseTilePlacement do
        local tile = getObjectFromGUID(phaseTilePlacement[i][1])
        if tile then tile.UI.setAttribute("highlight", "active", false) end
    end
end

function resetPhaseTiles()
     for i=1, #phaseTilePlacement do
          local tile = getObjectFromGUID(phaseTilePlacement[i][1])
          tile.setRotationSmooth({0, 180, 180})
     end
end

function startExplorePhase()
    local players = getSeatedPlayersWithHands()

    for _, player in pairs(players) do
        local p = playerData[player]
        capturePowersSnapshot(player, "1")

        if p.powersSnapshot["DISCARD_PRESTIGE"] then
            p.handCountSnapshot = countCardsInHand(player)
            p.beforeExplore = true
        else
            doExploreDraw(player)
        end
    end
end

function doExploreDraw(player)
    local p = playerData[player]
    p.handCountSnapshot = countCardsInHand(player) + p.powersSnapshot["DRAW"]

    for j=1, p.powersSnapshot["DRAW"] do
        local card = drawCard()
        card.deal(1, player)
        card.addTag("Explore Highlight")
    end
end

function startDevelopPhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        data.miscSelectedCards = {}
        capturePowersSnapshot(player, "2")

        if data.powersSnapshot["DRAW"] then
            dealTo(data.powersSnapshot["DRAW"], player)
        end

        if data.powersSnapshot["EXPLORE"] then
            data.handCountSnapshot = countCardsInHand(player) + data.powersSnapshot["EXPLORE"]
            dealTo(data.powersSnapshot["EXPLORE"], player)
            data.beforeDevelop = true
        end

        queueUpdate(player, true)
    end
end

function startSettlePhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        data.miscSelectedCards = {}

        queueUpdate(player, true)
    end
end

function startConsumePhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        data.miscSelectedCards = {}
        data.selectedGoods = {}

        capturePowersSnapshot(player, "4")

        -- Force first selection choice to be the consume trade card, otherwise it'll be nil
        local card = checkIfSelectedAction(player, "Consume ($)")
        if card then
            data.selectedCard = card.getGUID()
            data.selectedCardPower = "TRADE_ACTION"
        end

        queueUpdate(player, true)
    end
end

function startProducePhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        data.produceCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0}

        capturePowersSnapshot(player, "5")

        -- produce on production planets first
        for card in allCardsInTableau(player) do
            local info = card_db[card.getName()]

            if info.passivePowers["5"] and info.passivePowers["5"]["PRODUCE"] then
                tryProduceAt(player, card)
            end
        end

        -- Force first selection choice to be the consume trade card, otherwise it'll be nil
        local card = checkIfSelectedAction(player, "Produce")
        if card then
            data.selectedCard = card.getGUID()
            data.selectedCardPower = "WINDFALL_ANY"
        end

        queueUpdate(player, true)
    end
end

-- phase = (string) current phase
function capturePowersSnapshot(player, phase)
    local p = playerData[player]
    local selectedCard = getObjectFromGUID(p.selectedCard)

    if phase == "nil" and currentPhaseIndex < 0 then
        -- special case if start of game
        if currentPhaseIndex == -1 then
            local targetDiscard = 2
            
            if selectedCard and card_db[selectedCard.getName()].flags["STARTHAND_3"] then
                targetDiscard = 3
            end

            p.powersSnapshot["DISCARD"] = targetDiscard
        end
        return
    end

    local results = {}

    -- -- Default values for Explore phase
    if phase == "1" then
        results["DRAW"] = 2
        results["KEEP"] = 1
    end

    results["EXTRA_MILITARY"] = 0
    results["BONUS_MILITARY"] = 0
    results["CHROMO_WORLDS"] = 0

    local ignore2ndDevelop = false
    local ignore2ndSettle = false
    local chromoCount = 0
    local rebelMilitaryWorldCount = 0
    local militaryWorldCount = 0
    local tradeChromoBonus = false
    local perMilitary = 0
    local perChromoWorld = 0
    local takeoverDefense = false

    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]
        local phase3Ap = info.activePowers["3"]

        -- Check if have takeover powers
        if not results["TAKEOVER_POWERS"] and phase3Ap then
            for name, ap in pairs(phase3Ap) do
                if isTakeoverPower(ap) then
                    results["TAKEOVER_POWERS"] = 1
                    break
                end
            end
        end

        -- Skip the action card power or cards played this phase
        if (placeTwoPhase or rebelSneakAttackPhase) and card.hasTag("Action Card") or card.hasTag("Ignore Tableau") or p.ignoreCards[card.getGUID()] then
            goto next_card
        end

        if info.flags["DISCARD_TO_12"] then results["DISCARD_TO_12"] = 1 end
        if info.flags["GAME_END_14"] then results["GAME_END_14"] = 1 end
        if info.flags["IMPERIUM"] then results["IMPERIUM"] = 1 end
        if info.flags["TAKE_DISCARDS"] then results["TAKE_DISCARDS"] = 1 end
        if info.flags["SELECT_LAST"] then results["SELECT_LAST"] = 1 end
        if info.flags["START_SAVE"] then results["START_SAVE"] = card.getGUID() end

        if info.passivePowers[phase] then
            local powers = info.passivePowers[phase]
            for name, power in pairs(powers) do
                if not results[name] then
                    results[name] = 0
                    if name == "EXPLORE" then
                        results["MUST_DISCARD"] = 0
                    end
                end

                -- count certain powers only in specific cases
                if phase == "2" then
                    if advanced2p and card.getName() == "Develop" then
                        if ignore2ndDevelop then goto skip end
                        ignore2ndDevelop = true
                    end
                elseif phase == "3" then
                    if advanced2p and card.getName() == "Settle" then
                        if ignore2ndSettle then goto skip end
                        ignore2ndSettle = true
                    end

                    -- record specialized military for takeovers
                    if name == "BONUS_MILITARY" then
                        local appendName = ""
                        for code, v in pairs(power.codes) do    -- only need to grab the first code
                            appendName = code .. "_BONUS_MILITARY"
                            break
                        end

                        if appendName ~= "" and not results[appendName] then
                            results[appendName] = power.strength
                        elseif results[appendName] then
                            results[appendName] = results[appendName] + power.strength
                        end
                    elseif name == "TAKEOVER_DEFENSE" then
                        takeoverDefense = true
                    end

                    -- Do some manipulations for special cases
                    if selectedCard then
                        local selectedInfo = card_db[selectedCard.getName()]

                        -- Ignore powers with non matching types or improper bonus military
                        if name == "REDUCE" and next(power.codes) ~= nil and not power.codes[selectedInfo.goods or ""] or
                            name == "BONUS_MILITARY" and (power.codes["AGAINST_REBEL"] and not selectedInfo.flags["REBEL"] or 
                                not power.codes["AGAINST_REBEL"] and not power.codes[selectedInfo.goods or ""]) then
                            goto skip
                        end
                    end

                    if name == "EXTRA_MILITARY" and next(power.codes) ~= nil then
                        if power.codes["PER_MILITARY"] then
                            perMilitary = perMilitary + 1
                        end
                        if power.codes["PER_CHROMO"] then
                            perChromoWorld = perChromoWorld + 1
                        end
                        goto skip
                    end
                end

                if name ~= "BONUS_MILITARY" then
                    results[name] = results[name] + power.strength
                    if name == "EXPLORE" then
                        results["MUST_DISCARD"] = results["MUST_DISCARD"] + 1
                    end
                end

                if name == "TRADE_GENE" and power.codes["TRADE_BONUS_CHROMO"] then
                    tradeChromoBonus = true
                end

                ::skip::
            end
        end

        -- Count base military for stat display purposes
        if phase ~= "3" and info.passivePowers["3"] then            
            local mil = info.passivePowers["3"]["EXTRA_MILITARY"]
            if mil and next(mil.codes) == nil then
                results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + mil.strength
            elseif mil and mil.codes["PER_MILITARY"] then
                perMilitary = perMilitary + 1
            elseif mil and mil.codes["PER_CHROMO"] then
                perChromoWorld = perChromoWorld + 1
            end

            mil = info.passivePowers["3"]["IMPERIUM_MILITARY"]
            if mil then
                if not results["IMPERIUM_MILITARY"] then results["IMPERIUM_MILITARY"] = 0 end
                results["IMPERIUM_MILITARY"] = results["IMPERIUM_MILITARY"] + mil.strength
            end
        end

        if info.flags["CHROMO"] then
            chromoCount = chromoCount + 1
            if info.type == 1 then
                results["CHROMO_WORLDS"] = results["CHROMO_WORLDS"] + 1
            end
        end

        if info.flags["MILITARY"] then
            militaryWorldCount = militaryWorldCount + 1
            if info.flags["REBEL"] then
                rebelMilitaryWorldCount = rebelMilitaryWorldCount + 1
            end
        end

        ::next_card::
    end

    if results["IMPERIUM"] and results["IMPERIUM_MILITARY"] then
        results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + results["IMPERIUM_MILITARY"]
    end

    if tradeChromoBonus then
        results["TRADE_GENE"] = results["TRADE_GENE"] + chromoCount
    end

    if perMilitary > 0 then
        results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + militaryWorldCount * perMilitary
    end

    if perChromoWorld > 0 then
        results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + results["CHROMO_WORLDS"] * perChromoWorld
    end

    if takeoverDefense then
        results["TAKEOVER_DEFENSE"] = rebelMilitaryWorldCount * 2 + (militaryWorldCount - rebelMilitaryWorldCount)
    end

    results["REBEL_MILITARY_WORLD_COUNT"] = rebelMilitaryWorldCount
    
    -- Track special cases
    if phase then
        local list = p.miscSelectedCards
        while list and list.value do
            local card = getObjectFromGUID(list.value)
            if card then
                local info = card_db[card.getName()]

                for name, power in pairs(info.activePowers[phase]) do
                    if name == "DISCARD" and power.codes["EXTRA_MILITARY"] then
                        results["BONUS_MILITARY"] = results["BONUS_MILITARY"] + power.strength
                    end
                end
            end

            list = list.next
        end
    end

    p.powersSnapshot = results

    local statTracker = getObjectFromGUID(statTracker_GUID[p.index])
    if statTracker then
        local xtra = 0
        if placeTwoPhase or takeoverPhase then
            xtra = p.tempMilitary
        end
        statTracker.call("updateLabel", {"military", results["EXTRA_MILITARY"] + xtra})
    end
end

function updateHandState(playerColor)
    local p = playerData[playerColor]
    local phase = getCurrentPhase()

    for _, obj in pairs(Player[playerColor].getHandObjects(1)) do
        local info = card_db[obj.getName()]
        obj.clearButtons()

        if p.upgradeWorldNew == obj.getGUID() then
            highlightOn(obj, "Purple", playerColor)
        end

        if transitionNextPhase then
        else
            if not phase and currentPhaseIndex < 0 then   -- Opening hand
                if obj.hasTag("Explore Highlight") then
                    if p.selectedCard then
                        obj.highlightOff()
                        if p.selectedCard ~= obj.getGUID() then
                            highlightOn(obj, "Brown", playerColor)
                        else
                            createCancelButtonOnCard(obj)
                        end
                    else
                        createSelectButtonOnCard(obj)
                        obj.highlightOn("Orange")
                        highlightOff(obj)
                    end
                end
            elseif isUpgradingWorld(playerColor) then
                if p.upgradeWorldOld then
                    local oldInfo = card_db[getObjectFromGUID(p.upgradeWorldOld).getName()]
                    if info.type == 1 and info.goods == oldInfo.goods and not info.flags["MILITARY"] and info.cost >= oldInfo.cost and info.cost - oldInfo.cost <= 3 then
                        createSelectButtonOnCard(obj)
                    end                    
                end
            elseif
                (phase == 2 and info and info.type == 2 and not p.beforeDevelop) or    -- Make buttons on development or world cards if appropriate phase
                (phase == 3 and info and info.type == 1 and not exploreAfterPhase and p.upgradeWorldNew ~= obj.getGUID()) then

                if phase == 3 and placeTwoPhase and not p.powersSnapshot["PLACE_TWO"] or planningTakeover(playerColor) or takeoverPhase then
                    goto skip
                end

                if not p.selectedCard then
                    createSelectButtonOnCard(obj)
                elseif p.selectedCard == obj.getGUID() then
                    createCancelButtonOnCard(obj)
                end

                ::skip::
            elseif phase == 4 and p.selectedCardPower == "ANTE_CARD" and info.cost >= 1 and info.cost <= 6 and not p.anteSucceed then
                if not p.selectedAnte then
                    createSelectButtonOnCard(obj)
                elseif p.selectedAnte == obj.getGUID() then
                    createCancelButtonOnCard(obj)
                end
            elseif phase == 4 and p.anteSucceed and obj.hasTag("Gamble Reward") then
                if not p.selectedReward then
                    createSelectButtonOnCard(obj)
                elseif p.selectedReward == obj.getGUID() then
                    createCancelButtonOnCard(obj)
                end
            end

            if phase == 1 and p.powersSnapshot["DISCARD_ANY"] ~= nil and not obj.hasTag("Explore Highlight") then
                obj.addTag("Explore Highlight")
            end

            -- Explore orange highlight
            if phase == 1 and obj.hasTag("Explore Highlight") or obj.hasTag("Gamble Reward") then
                obj.highlightOn("Orange")
            elseif currentPhaseIndex == 0 or phase and (phase ~= 1) and obj.hasTag("Explore Highlight") then
                obj.highlightOff()
                obj.removeTag("Explore Highlight")
            end

            if obj.hasTag("Selected") and obj.hasTag("Gamble Reward") then
                obj.highlightOn(color(0, 1, 0))
            elseif obj.hasTag("Selected") and not p.anteSucceed then
                highlightOn(obj, "rgb(0,1,0,1)", playerColor)
            elseif obj.hasTag("Marked") then
                highlightOn(obj, "Red", playerColor)
                Wait.frames(function() displayXOn(obj, playerColor) end, 2)
            end
        end
    end

    updateHandCount(playerColor)
end

function setVisibleTo(obj, player)
    local arr = {}
    for playerColor, data in pairs(playerData) do
        if playerColor ~= player then
            arr[#arr + 1] = playerColor
        end
    end
    obj.setInvisibleTo(arr)
end

-- Make sure to call capturePowersSnapshot before calling this, otherwise may update with wrong modifiers
function updateTableauState(player)
    local p = playerData[player]
    local i = playerData[player].index
    local zone = getObjectFromGUID(tableauZone_GUID[i])
    local selectedCard = getObjectFromGUID(p.selectedCard)
    local selectedInfo = selectedCard and card_db[selectedCard.getName()] or nil
    local currentPhase = tostring(getCurrentPhase())
    local optColor = color(0.5,1,0.9)
    local windfallCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    local goodsCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    local uniques = {}
    local dontAutoPass = false
    local wildWorldCount = 0
    local wildGoodCount = 0
    local selectedUniqueGoods = {}

    p.recordedCards = {}
    p.prestigeChips = {}
    p.prestigeCount = 0

    -- Change tableau image if needed
    local tableau = getObjectFromGUID(tableau_GUID[p.index])
    local tableauInfo = tableau.getCustomObject()
    if p.powersSnapshot["GAME_END_14"] and tableauInfo.image ~= playmat14 then
        tableauInfo.image = playmat14
        tableau.setCustomObject(tableauInfo)
        tableau.reload()
    elseif not p.powersSnapshot["GAME_END_14"] and tableauInfo.image ~= playmat12 then
        tableauInfo.image = playmat12
        tableau.setCustomObject(tableauInfo)
        tableau.reload()
    end

    if currentPhase == "4" or currentPhase == "5" then
        p.canReady = true
    end

    for card in allCardsInTableau(player) do
        card.clearButtons()
        card.highlightOff()
        highlightOff(card)
    end 

    for guid, selected in pairs(p.selectedGoods) do
        if selected then
            local good = getObjectFromGUID(guid)
            local parent = getObjectFromGUID(good.getDescription())
            selectedUniqueGoods[getKind(parent)] = true
        end
    end

    local miscPowerSnapshot = {}
    local miscSelectedCardsTable = {}
    local miscSelectedCount = 0
    local miscActiveNode = nil
    local miscActiveNodePowerKey = ""
    local list = p.miscSelectedCards

    while list and list.value do
        local card = getObjectFromGUID(list.value)
        if card then
            miscSelectedCardsTable[list.value] = list

            local info = card_db[card.getName()]
            for name, power in pairs(info.activePowers[currentPhase]) do
                miscPowerSnapshot[name] = power
            end

            if not list.next then
                miscActiveNode = list
                miscActiveNodePowerKey = concatPowerName(miscActiveNode.power)
            end
            miscSelectedCount = miscSelectedCount + 1
        end

        list = list.next
    end

    -- count certain cards, highlight goods, etc
    for _, obj in pairs(zone.getObjects()) do
        obj.clearButtons()
        if obj.hasTag("Slot") then
            if currentPhase == "2" or (currentPhase == "3" and not takeoverPhase) then
                setVisibleTo(obj, player)
            else
                obj.setInvisibleTo({})
            end
        end

        if obj.type == 'Card' and not obj.is_face_down then
            local parentData = card_db[obj.getName()]
            if parentData.goods and parentData.goods == "ANY" then
                createKindTypeUI(obj)
            end

            if parentData.flags["WINDFALL"] and not getGoods(obj) then
                local kind = getKind(obj)
                windfallCount[kind] = windfallCount[kind] + 1
                windfallCount["TOTAL"] = windfallCount["TOTAL"] + 1

                if parentData.goods and parentData.goods == "ANY" then
                    wildWorldCount = wildWorldCount + 1
                end
            end
        elseif obj.type == 'Card' and obj.is_face_down and obj.getDescription() ~= "" then  -- facedown goods on tableau
            local parentCard = getObjectFromGUID(obj.getDescription())
            local parentData = card_db[parentCard.getName()]

            if #parentCard.getZones() <= 0 then
                obj.setDescription("")
            elseif parentData.goods then
                local activeCard = selectedCard
                local activeInfo = selectedInfo
                local selectedCardPower = p.selectedCardPower
                obj.highlightOn(goodsHighlightColor[getKind(parentCard)])

                if p.markedGoods[obj.getGUID()] then
                    displayXOn(obj, player)
                else
                    local kind = getKind(parentCard)
                    goodsCount[kind] = goodsCount[kind] + 1
                    uniques[kind] = 1
                    goodsCount["TOTAL"] = goodsCount["TOTAL"] + 1

                    if parentData.goods and parentData.goods == "ANY" then
                        wildGoodCount = wildGoodCount + 1
                    end

                    -- change active selections based on the misc selected cards
                    if currentPhase == "2" or currentPhase == "3" then
                        activeCard = nil
                        activeInfo = nil
                        selectedCardPower = nil
                        local node = getLastNode(p.miscSelectedCards)
                        if node.value and node.power.name:sub(1,7) == "CONSUME" and node.power.name ~= "CONSUME_PRESTIGE" then
                            activeCard = getObjectFromGUID(node.value)
                            activeInfo = card_db[activeCard.getName()]
                            selectedCardPower = node.power.name
                        end
                    end

                    -- create buttons on cards based on action
                    if activeCard then
                        local ap = activeInfo.activePowers[currentPhase]
                        if selectedCardPower == "TRADE_ACTION" and not (parentData.passivePowers["4"] and parentData.passivePowers["4"]["NO_TRADE"]) then
                            -- calculating cost to sell card
                            local power = ap[selectedCardPower]
                            local price = 0
                            local bonus = not power.codes["TRADE_NO_BONUS"]
                            local basePrice = {NOVELTY = 2, RARE = 3, GENE = 4, ALIEN = 5}

                            price = basePrice[kind] + (bonus and p.powersSnapshot["TRADE_" .. kind] or 0)
                            price = price + (bonus and p.powersSnapshot["TRADE_ANY"] or 0)

                            local parentPassive = parentData.passivePowers[currentPhase]
                            if bonus and parentPassive and parentPassive["TRADE_THIS"] then
                                price = price + parentPassive["TRADE_THIS"].strength
                            end

                            p.canReady = false
                            createGoodsButton(parentCard, "$➧" .. price, goodsHighlightColor[kind])
                            obj.memo = price
                        elseif ap then -- using normal consume powers
                            local makeButton = false
                            local power = ap[selectedCardPower]

                            if selectedCardPower == "CONSUME_ANY" or selectedCardPower == "CONSUME_ALL" or selectedCardPower == "CONSUME_" .. (kind or "") or
                                (((selectedCardPower == "CONSUME_3_DIFF" or selectedCardPower == "CONSUME_N_DIFF") and not selectedUniqueGoods[kind]) or (p.selectedGoods and p.selectedGoods[obj.getGUID()])) then
                                makeButton = true
                            end

                            -- if not makeButton and p.selectedCardPower and p.selectedCardPower:sub(1,7) == "CONSUME" then
                            --     makeButton = true
                            -- end

                            if power.codes["CONSUME_THIS"] and activeCard ~= parentCard then
                                makeButton = false
                            end

                            if makeButton then
                                dontAutoPass = true
                                p.canReady = false
                                createGoodsButton(parentCard, p.selectedGoods[obj.getGUID()] and "✔" or "", goodsHighlightColor[kind])
                            end
                        end
                    end
                end
            end
        elseif obj.hasTag("Prestige") then
            p.prestigeChips[obj.getGUID()] = obj.getGUID()
            p.prestigeCount = p.prestigeCount + math.max(1, obj.getQuantity())
        end
    end
    if p.consumedPrestige then p.prestigeCount = p.prestigeCount - p.consumedPrestige end

    local uniqueCount = tableLength(uniques)
    p.mustConsumeCount = 0

    if selectedCard and selectedCard.getName() == "Consume ($)" then
        goodsCount["TOTAL"] = goodsCount["TOTAL"] - wildGoodCount
    end

    -- Auto cancel certain cards
    if not p.incomingGood and p.usedPower and
            (currentPhase == "4" and selectedCard and selectedCard.getName() == "Consume ($)" and goodsCount["TOTAL"] <= 0
            or currentPhase == "5" and selectedCard and selectedCard.getName() == "Produce" and windfallCount["TOTAL"] <= 0) then
        selectedCard = nil
        selectedInfo = nil
        p.selectedCard = nil
        p.selectedCardPower = ""
    end

    local currentMiscSelected = nil

    -- refresh state on all cards in tableau
    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]
        p.recordedCards[card.getName()] = true

        if selectedCard == card then
            if card.hasTag("Action Card") then
                card.highlightOn(color(0,1,0))
            else
                highlightOn(card, "rgb(0,1,0)", player)
            end
        end

        if rebelSneakAttackPhase and not p.rebelSneakAttack then
            goto continue
        end

        if info.flags["START_SAVE"] then
            local hits = Physics.cast({
                origin = card.getPosition(),
                direction = {0, -1, 0},
                max_distance = 0.5
            })

            if #hits > 0 then
                local n = 0
                if hits[1].hit_object.type == 'Card' and hits[1].hit_object.getDescription() == "" then
                    n = 1
                elseif hits[1].hit_object.type == 'Deck' then
                    n = hits[1].hit_object.getQuantity()
                end
                card.createButton({
                    click_function = "none",
                    function_owner = Global,
                    label = "Saved: " .. n,
                    font_color = "White",
                    width = 0,
                    height = 0,
                    font_size = 100,
                    position = {0, 1, -0.72}
                })
            end
        end

        if not card.hasTag("Action Card") then
            local ap = info.activePowers[currentPhase]
            local miscSelected = miscSelectedCardsTable[card.getGUID()]
            local passives = info.passivePowers[currentPhase]
            local isRebelSneakAttackCard = passives and passives["DISCARD_PLACE_MILITARY"]

            if miscSelected then
                highlightOn(card, "rgb(0,1,0)", player)
            end

            if currentPhaseIndex == 0 and info.flags["START_SAVE"] and firstRound then  -- Galactic scavengers
                local used = p.cardsAlreadyUsed[card.getGUID()]
                if not used then
                    p.selectedCard = card.getGUID()
                    p.selectedCardPower = "START_SAVE"
                    createConfirmButton(card)
                end
            elseif currentPhase == "1" and p.beforeExplore then
                local powers = info.passivePowers["1"]
                if powers and powers["DISCARD_PRESTIGE"] then
                    card.highlightOn("Yellow")
                    createConfirmButton(card)
                end
            elseif currentPhase == "2" then -- develop phase
                if p.beforeDevelop then
                    local powers = info.passivePowers["2"]
                    if powers and powers["EXPLORE"] then
                        card.highlightOn("Yellow")
                        createConfirmButton(card)
                    end
                elseif ap then
                    for name, power in pairs(ap) do
                        local used = p.cardsAlreadyUsed[card.getGUID()] and p.cardsAlreadyUsed[card.getGUID()][name] and p.cardsAlreadyUsed[card.getGUID()][name].strength >= power.strength
                        if selectedCard then
                            if miscSelectedCount <= 0 and not used then
                                dontAutoPass = true
                                createUsePowerButton(card, power.index, info.activeCount[currentPhase], activePowers[currentPhase][name])
                            elseif miscSelected or (used and canCancelAfter[name]) then
                                dontAutoPass = true
                                createCancelButton(card)
                            end
                        end
                    end
                end
            elseif currentPhase == "3" and exploreAfterPhase then   -- end of settle phase
                if exploreAfterPhase and info.passivePowers[currentPhase] and info.passivePowers[currentPhase]["EXPLORE_AFTER"] and p.exploreAfterPower then
                    card.highlightOn("Yellow")
                    createConfirmButton(card)
                end
            elseif currentPhase == "3" then -- settle phase
                local rebelSneakAttack = p.rebelSneakAttack
                local isUpgradingWorld = isUpgradingWorld(player)
                local planningTakeover = planningTakeover(player)

                if takeoverPhase then
                    if p.beingTargeted and p.beingTargeted[card.getGUID()] then
                        createStrengthLabel(player, card, true)
                    elseif p.takeoverSource == card.getGUID() then
                        createStrengthLabel(player, card, false)
                    end
                elseif isUpgradingWorld then
                    if info.type == 1 and not info.flags["MILITARY"] then
                        createSelectWorldButton(card)
                    end
                end

                if card.getGUID() == p.upgradeWorldOld then
                    highlightOn(card, "Red", player)
                end

                -- Create buttons or highlights for active powers
                if securityCouncilPhase and passives and passives["PREVENT_TAKEOVER"] and p.securityCouncil then
                    card.highlightOn(color(0,1,0))
                    createConfirmButton(card)
                    createCancelButton(card)
                elseif rebelSneakAttackPhase and isRebelSneakAttackCard and p.rebelSneakAttack or
                    placeTwoPhase and passives and passives["PLACE_TWO"] then
                    card.highlightOn("Yellow")
                elseif ap and (selectedCard or miscActiveNode or p.beingTargeted) then
                    for name, power in pairs(ap) do
                        local powerName = ""
                        local fullName = miscActiveNode and concatPowerName(miscActiveNode.power) or ""
                        local used = p.cardsAlreadyUsed[card.getGUID()] and p.cardsAlreadyUsed[card.getGUID()][name] and p.cardsAlreadyUsed[card.getGUID()][name].strength >= power.strength

                        if power.codes["AGAINST_REBEL"] and selectedInfo and not selectedInfo.flags["REBEL"] or 
                            miscActiveNode and miscActiveNode.value ~= card.getGUID() and requiresConfirm[fullName] or
                            rebelSneakAttackPhase and (name == "PAY_MILITARY" or power.codes["PAY_MILITARY"]) then
                            goto skip_power
                        end

                        if not used then
                            local selectedMilitary = selectedInfo and selectedInfo.flags["MILITARY"]
                            local selectedAlien = selectedInfo and selectedInfo.goods == "ALIEN"

                            if selectedMilitary and miscPowerSnapshot["PAY_MILITARY"] then selectedMilitary = false end
                            if not selectedMilitary and (planningTakeover or miscPowerSnapshot["DISCARD_CONQUER_SETTLE"]) then selectedMilitary = true end

                            if name == "DISCARD" and power.codes["REDUCE_ZERO"] and not selectedMilitary and not selectedAlien then
                                powerName = name
                            elseif name == "DISCARD" and power.codes["EXTRA_MILITARY"] and (takeoverPhase or selectedMilitary) then
                                powerName = name
                            elseif name == "DISCARD_CONQUER_SETTLE" and not selectedMilitary or (planningTakeover and not power.codes["NO_TAKEOVER"]) then
                                powerName = name
                            elseif name == "PAY_MILITARY" and selectedMilitary and
                                    (not next(power.codes) and not selectedAlien or 
                                    power.codes["ALIEN"] and selectedAlien or 
                                    power.codes["AGAINST_CHROMO"] and selectedInfo.flags["CHROMO"])  then
                                powerName = name
                            elseif name == "MILITARY_HAND" and (takeoverPhase or selectedMilitary) then
                                powerName = name
                            elseif name == "CONSUME_PRESTIGE" and power.codes["EXTRA_MILITARY"] and selectedMilitary and p.prestigeCount > 0 then
                                powerName = name
                            elseif name == "CONSUME_GENE" and goodsCount["GENE"] > 0 and power.codes["REDUCE"] and not selectedMilitary then
                                powerName = name
                            elseif name == "CONSUME_RARE" and goodsCount["RARE"] > 0 and power.codes["EXTRA_MILITARY"] and selectedMilitary then
                                powerName = name
                            elseif name == "DISCARD_PLACE_MILITARY" then
                                powerName = name
                            end

                            if powerName ~= "" and miscSelectedCount > 0 and not miscSelectedCardsTable[card.getGUID()] and not takeoverPhase then
                                -- check for compatible chains
                                local key = concatPowerName(power)
                                if compatible[miscActiveNodePowerKey] and compatible[miscActiveNodePowerKey][key] then
                                    powerName = power.name
                                else
                                    powerName = ""
                                end
                            end
                        end

                        if powerName ~= "" and not miscSelected and not used then
                            dontAutoPass = true
                            createUsePowerButton(card, power.index, info.activeCount[currentPhase], getTooltip(currentPhase, power))
                        elseif miscSelected or (used and canCancelAfter[name]) then
                            dontAutoPass = true
                            createCancelButton(card)

                            if requiresConfirm[fullName] or takeoverPhase and requiresConfirm[name] then
                                createConfirmButton(card)
                            end
                        end

                        ::skip_power::
                    end
                elseif ap and not takeoverPhase then
                    for name, power in pairs(ap) do
                        local isTakeoverPower = isTakeoverPower(power)

                        -- check if can pay cost
                        if name == "TAKEOVER_PRESTIGE" and p.prestigeCount <= 0 or (rebelSneakAttackPhase and isTakeoverPower) then
                            goto skip
                        end

                        -- make buttons for takeover powers
                        if useTakeovers and isTakeoverPower and not miscSelected or ap["UPGRADE_WORLD"] then
                            local used = p.cardsAlreadyUsed[card.getGUID()] and p.cardsAlreadyUsed[card.getGUID()][name] and p.cardsAlreadyUsed[card.getGUID()][name].strength >= power.strength
                            dontAutoPass = true
                            if not used then
                                createUsePowerButton(card, power.index, info.activeCount[currentPhase], getTooltip(currentPhase, power))
                            elseif ap["UPGRADE_WORLD"] then
                                createCancelButton(card)
                            end
                        end

                        ::skip::
                    end
                end
            elseif currentPhase == "4" then -- consume phase
                local baseAmount = {}
                local goodslimit = {}
                local enoughGoods = false

                if info.activePowers[currentPhase] then
                    for name, power in pairs (info.activePowers[currentPhase]) do
                        baseAmount[name] = 1
                    end
                end

                if next(baseAmount) then
                    for name, power in pairs(info.activePowers[currentPhase]) do
                        if not goodslimit[name] then goodslimit[name] = 1 end

                        if requiresGoods[name] then
                            if name == "CONSUME_ANY" or name == "CONSUME_ALL" or name == "CONSUME_3_DIFF" or name == "CONSUME_N_DIFF" or name == "TRADE_ACTION" then
                                goodslimit[name] = goodsCount["TOTAL"]
                            elseif name:sub(1,7) == "CONSUME" then
                                goodslimit[name] = goodsCount[name:sub(9, name:len())]
                            end

                            if power.name ~= "DISCARD_HAND" and power.codes["CONSUME_TWO"] then
                                baseAmount[name] = 2
                            elseif name == "CONSUME_ALL" then
                                baseAmount[name] = math.max(1, goodsCount["TOTAL"])
                            elseif name == "CONSUME_3_DIFF" then
                                baseAmount[name] = (uniqueCount >= 3 and goodsCount["TOTAL"] >= 3) and 3 or 100
                            elseif name == "CONSUME_N_DIFF" then
                                baseAmount[name] = math.max(1, math.min(goodsCount["TOTAL"], uniqueCount))
                            elseif not requiresGoods[name] then
                                baseAmount[name] = 0
                            end

                            goodslimit[name] = math.min(math.max(1, power.times * baseAmount[name]), goodslimit[name])
                        elseif name == "CONSUME_PRESTIGE" then
                            baseAmount[name] = 1
                            goodslimit[name] = p.prestigeCount
                        end
                    end
                end

                if not selectedCard and ap then
                    for name, power in pairs(ap) do
                        local used = p.cardsAlreadyUsed[card.getGUID()]
                        if (not used or not used[name]) and baseAmount[name] <= goodslimit[name] then
                            dontAutoPass = true
                            if not optionalPowers[name] then p.canReady = false end
                            local prefix = (currentPhase == "4" and optionalPowers[name]) and "(Optional) " or ""
                            createUsePowerButton(card, power.index, info.activeCount[currentPhase], prefix .. activePowers[currentPhase][name], (currentPhase == "4" and optionalPowers[name]) and optColor or "White")
                        end
                    end
                elseif selectedCard == card then
                    p.canReady = false
                    dontAutoPass = true
                    if p.selectedCardPower == "ANTE_CARD" and p.anteSucceed then
                       -- Do something for when ante is successful 
                    else
                        createCancelButton(card)
                    end

                    if requiresConfirm[p.selectedCardPower] then
                        createConfirmButton(selectedCard)
                    end

                    p.mustConsumeCount = math.max(baseAmount[p.selectedCardPower], goodslimit[p.selectedCardPower])

                    if p.selectedCardPower == "DRAW_LUCKY" then
                        createGamblingWorldUi(card)
                    end
                end
            elseif currentPhase == "5" then
                if not selectedCard and ap then
                    for name, power in pairs(ap) do
                        local windfallStr = name
                        local windfallPrefix = name:sub(1,8) == "WINDFALL"
                        local targetGood = windfallPrefix and name:sub(10, name:len()) or ""

                        -- second check because windfall power might be a code
                        if not windfallPrefix then
                            for code, v in pairs(power.codes) do
                                if code:sub(1,8) == "WINDFALL" then
                                    windfallPrefix = true
                                    targetGood = code:sub(10, code:len())
                                    break
                                end
                            end
                        end
                        
                        local makeButton = true
                        local used = p.cardsAlreadyUsed[card.getGUID()]
                        local windfallCountTarget = windfallCount[targetGood]
                        local open = getGoods(card)
                        local prefix = optionalPowers[name] and "(Optional) " or ""

                        if power.codes["NOT_THIS"] and not open then
                            windfallCountTarget = windfallCountTarget - 1
                        end

                        if used and used[name] or
                            power.codes["PRODUCE"] and open or 
                            windfallPrefix and targetGood == "ANY" and windfallCount["TOTAL"] <= 0 or
                            windfallPrefix and windfallCountTarget and windfallCountTarget <= 0 then
                            goto skip
                        end

                        if not optionalPowers[name] then p.canReady = false end

                        dontAutoPass = true

                        createUsePowerButton(card, power.index, info.activeCount[currentPhase], prefix .. activePowers[currentPhase][name], optionalPowers[name] and optColor or "White")

                        ::skip::
                    end
                elseif selectedCard then
                    -- Check to create 'place goods on windfall' button
                    local power = selectedInfo.activePowers[currentPhase][p.selectedCardPower]
                    local open = not getGoods(card)
                    local paidCost = p.paidCost[selectedCard.getGUID()]
                    local kind = getKind(card)
                    paidCost = paidCost and paidCost[power.name .. power.index]

                    local makeButton = false
                    if (info.flags["WINDFALL"] and (power.codes["WINDFALL_ANY"] and kind or power.codes["WINDFALL_" .. (kind or "")])) and paidCost and open then
                        makeButton = true
                    end

                    if kind and info.flags["WINDFALL"] and open and p.selectedCardPower:sub(1,8) == "WINDFALL" and card ~= selectedCard or makeButton then
                        local targetGood = p.selectedCardPower:sub(10, p.selectedCardPower:len())
                        if targetGood == "ANY" or targetGood == kind or power.codes["WINDFALL_ANY"] or power.codes["WINDFALL_" .. kind] then
                            dontAutoPass = true
                            p.canReady = false
                            createGoodsButton(card, "▼", color(1, 1, 1, 0.9))
                        end
                    end

                    if selectedCard == card and not paidCost then
                        p.canReady = false
                        dontAutoPass = true
                        createCancelButton(selectedCard)

                        if requiresConfirm[p.selectedCardPower] then
                            createConfirmButton(selectedCard)
                        end
                    end
                end
            end
        end
        ::continue::
    end

    -- Force the player ready when they have nothing left to do
    if (p.usedPower and not p.incomingGood and (currentPhase == "4" or currentPhase == "5") and not p.forcedReady and dontAutoPass == false and not selectedCard) or
        (not p.incomingGood and not p.forcedReady and dontAutoPass == false and currentPhase == "3" and takeoverPhase and not p.beingTargeted)then
        p.forcedReady = true
        if Player[player].seated then
            updateReadyButtons({player, true})
        end
    end

    if not p.incomingGood then
        p.usedPower = false
    end
end

function markUsed(player, card, power, n)
    local p = playerData[player]

    if not p.cardsAlreadyUsed[card.getGUID()] then p.cardsAlreadyUsed[card.getGUID()] = {} end
    local data = cardAlreadyUsedInit()

    data.selectedCard = p.selectedCard
    data.strength = data.strength + (n or 1)

    p.selectedGoods = {}
    p.selectedCard = nil
    p.selectedCardPower = ""
    p.miscSelectedCards = {}
    p.usedPower = true

    p.cardsAlreadyUsed[card.getGUID()][power.name] = data

    return data
end

function markUsedMisc(player, card, power, n)
    local p = playerData[player]

    if not p.cardsAlreadyUsed[card.getGUID()] then p.cardsAlreadyUsed[card.getGUID()] = {} end
    local data = p.cardsAlreadyUsed[card.getGUID()][power.name] or cardAlreadyUsedInit()

    data.selectedCard = p.selectedCard
    data.power = power
    data.strength = data.strength + (n or 1)
    data.triggerCard = card.getGUID()

    p.selectedGoods = {}
    p.miscSelectedCards = deleteLinkedListNode(p.miscSelectedCards, card.getGUID())
    p.cardsAlreadyUsed[card.getGUID()][power.name] = data

    return data
end

function getActivePower(name, phase, powerIndex)
    local info = card_db[name]
    if info and info.activePowers[phase] then
        for _, power in pairs(info.activePowers[phase]) do
            if power.index == powerIndex then
                return power
            end
        end
    end

    return nil
end

function usePowerClick1(obj, player, button) usePowerClick(obj, player, button, 1) end
function usePowerClick2(obj, player, button) usePowerClick(obj, player, button, 2) end
function usePowerClick3(obj, player, button) usePowerClick(obj, player, button, 3) end

function usePowerClick(obj, player, rightClick, powerIndex)
    if rightClick then return end
    if getOwner(obj) ~= player then
        broadcastToColor("You cannot use cards from another player's tableau.", player, "White")
        return
    end

    local slot = obj
    if obj.hasTag("Slot") then obj = getCard(obj) end

    local p = playerData[player]
    local currentPhase = tostring(getCurrentPhase())
    local info = card_db[obj.getName()]

    p.handCountSnapshot = countCardsInHand(player, true)

    if currentPhase == "4" or currentPhase == "5" then
        p.selectedCard = obj.getGUID()
        for name, power in pairs(info.activePowers[currentPhase]) do
            if power.index == powerIndex then
                p.selectedCardPower = name

                -- Use power instantly
                if p.selectedCardPower == "DRAW" then
                    dealTo(power.strength, player)
                    markUsed(player, obj, power)
                    queueUpdate(player, true)
                    return
                elseif p.selectedCardPower == "VP" then
                    local vpMultiplier = p.powersSnapshot["DOUBLE_VP"] and 2 or 1
                    getVpChips(player, power.strength * vpMultiplier)
                    markUsed(player, obj, power)
                    queueUpdate(player, true)
                    return
                end
                break
            end
        end
    end

    -- Special produce powers
    if currentPhase == "5" then
        local usedPower = false
        local power = card_db[obj.getName()].activePowers[currentPhase][p.selectedCardPower]

        if power.name:sub(1,9) == "DRAW_EACH" then
            local targetGood = p.selectedCardPower:sub(11, power.name:len())
            dealTo(p.produceCount[targetGood] * power.strength, player)
            usedPower = true
        elseif power.name == "DRAW_WORLD_GENE" then
            local n = countTrait(player, "goods", "GENE")
            dealTo(n * power.strength, player)
            usedPower = true
        elseif power.name == "DRAW_DIFFERENT" then
            local n = 0
            for goods, count in pairs(p.produceCount) do
                if goods ~= "TOTAL" and count > 0 then
                    n = n + 1
                end
            end
            dealTo(n * power.strength, player)
            usedPower = true
        elseif power.name == "DRAW_MILITARY" then
            local n = countTrait(player, "flags", "MILITARY")
            dealTo(n * power.strength, player)
            usedPower = true
        elseif power.name == "DRAW_CHROMO" then
            local n = countTrait(player, "flags", "CHROMO")
            dealTo(n * power.strength, player)
            usedPower = true
        elseif power.name == "DRAW_REBEL" then
            local n = countTrait(player, "flags", "REBEL", 1)
            dealTo(n * power.strength, player)
            usedPower = true
        elseif power.name == "TAKE_SAVED" then
            local hits = Physics.cast({
                origin = obj.getPosition(),
                direction = {0, -1, 0},
                max_distance = 0.5
            })

            if #hits > 0 then
                local item = hits[1].hit_object
                if item.type == 'Card' and item.getDescription() == "" or item.type == 'Deck' then
                    item.deal(math.max(item.getQuantity(), 1), player)
                end

                for _, hit in pairs(hits) do
                    if hit.hit_object.hasTag("Slot") then
                        local tb = hit.hit_object
                        local pos = obj.getPosition()
                        obj.setPosition({pos.x, tb.getPosition().y + 0.02, pos.z})
                        break
                    end
                end
            end
            usedPower = true
        end

        if usedPower then
            markUsed(player, obj, power)
            queueUpdate(player, true)
            return
        end
    end

    local power = getActivePower(obj.getName(), currentPhase, powerIndex)
    local node = getLastNode(p.miscSelectedCards)

    if not p.miscSelectedCards then p.miscSelectedCards = {} end
    if not p.miscSelectedCards.value then
         p.miscSelectedCards = {value = obj.getGUID(), power=power, next = nil}
    else
         node.next = {value = obj.getGUID(), power=power, next = nil}
    end

    local takeoverName = isTakeoverPower(power)
    if currentPhase == "3" then
        if useTakeovers then
            if takeoverName ~= nil then
                p.takeoverSource = obj.getGUID()
                p.takeoverPower = power
                p.takeoverTarget = nil
                Global.UI.setAttribute("takeoverMenu_" .. player, "active", true)
                --Wait.frames(function() Global.UI.setAttribute("takeoverMenu_" .. player, "active", true) end, 1)
            end

            if power.name == "DISCARD" and power.codes["EXTRA_MILITARY"] then
                p.powersSnapshot["BONUS_MILITARY"] = p.powersSnapshot["BONUS_MILITARY"] + power.strength
            end
            refreshTakeoverMenu(player)
        end

        -- if not takeoverName then
        --     -- for name, power in pairs(info.activePowers[currentPhase]) do
        --     --     if power.index == powerIndex and name == "UPGRADE_WORLD" then
        --     --     end
        --     -- end
        -- end
    end

    queueUpdate(player, true)
end

function cancelAllMarkedCards(player, selectedCardGuid)
    local p = playerData[player]
    for guid, useData in pairs(p.cardsAlreadyUsed) do
        for power, data in pairs(useData) do
            if data.selectedCard == selectedCardGuid then
                cancelUsedCard(player, data)
                p.cardsAlreadyUsed[data.triggerCard] = nil
            end
        end
    end
end

function cancelUsedCards(player, triggerCardGuid)
    local p = playerData[player]
    if not p then return end

    for name, info in pairs(p.cardsAlreadyUsed[triggerCardGuid]) do
        if canCancelAfter[name] then
            cancelUsedCard(player, info)
            p.cardsAlreadyUsed[triggerCardGuid] = nil
        end
    end
end

function cancelUsedCard(player, info)
    local p = playerData[player]
    if canCancelAfter[info.power.name] then
        for _, guid in pairs(info.markedDiscards) do
            local card = getObjectFromGUID(guid)
            card.setTags({})
            highlightOff(card)
            displayXOff(card)
            if card.is_face_down then
                card.flip()
            end
        end

        for guid, v in pairs(info.markedGoods) do
            local card = getObjectFromGUID(guid)
            displayXOff(card)
            p.markedGoods[guid] = nil
        end

        if info.power.name == "MILITARY_HAND" or info.power.codes["EXTRA_MILITARY"] then
            p.tempMilitary = p.tempMilitary - info.strength
        end

        if info.power.name == "CONSUME_PRESTIGE" then
            p.consumedPrestige = p.consumedPrestige - 1
        end
    end
end

function cancelPowerClick(obj, player, rightClick)
    if rightClick then return end
    if getOwner(obj) ~= player then
        broadcastToColor("You cannot use cards from another player's tableau.", player, "White")
        return
    end

    if obj.hasTag("Slot") then obj = getCard(obj) end
    local p = playerData[player]
    local currentPhase = getCurrentPhase()
    local node = getLinkedListNode(p.miscSelectedCards, obj.getGUID())
    local info = card_db[obj.getName()]

    if currentPhase == 3 and (isUpgradingWorld(player) or info.activePowers["3"] and info.activePowers["3"]["UPGRADE_WORLD"]) then
        if p.upgradeWorldNew then
            local card = getObjectFromGUID(p.upgradeWorldNew)
            highlightOff(card)
        end
        p.upgradeWorldOld = nil
        p.upgradeWorldNew = nil
    elseif currentPhase == 3 and securityCouncilPhase and info.passivePowers["3"] and info.passivePowers["3"]["PREVENT_TAKEOVER"] then
        p.securityCouncil = false
        Global.UI.setAttribute("securityCouncilMenu", "active", false)
        queueUpdate(player, true)
        updateReadyButtons({player, true}, true)
        return
    end

    if node and node.value == p.miscSelectedCards.value and currentPhase == 3 then
        cancelAllMarkedCards(player, p.selectedCard)
    end

    p.handCountSnapshot = countCardsInHand(player, true)
    p.miscSelectedCards = deleteLinkedListNode(p.miscSelectedCards, obj.getGUID())

    if (currentPhase == 2 or currentPhase == 3) and p.cardsAlreadyUsed[obj.getGUID()] then
        cancelUsedCards(player, obj.getGUID())
        refreshTakeoverMenu(player)
    elseif currentPhase ~= 3 and currentPhase ~= 2 then
        p.selectedAnte = nil
        p.selectedCard = nil
        p.selectedCardPower = nil
        p.selectedGoods = {}
    elseif useTakeovers and currentPhase == 3 then
        if not p.miscSelectedCards.value then
            Global.UI.setAttribute("takeoverMenu_" .. player, "active", false)
            p.takeoverSource = nil
            p.takeoverTarget = nil
        end

        -- temporarily set this value for now to refresh takeover menu
        capturePowersSnapshot(player, "3")
        Wait.frames(function() refreshTakeoverMenu(player) end, 1)
    end

    for _, obj in pairs(Player[player].getHandObjects(1)) do
        if obj.is_face_down then
            obj.flip()
            obj.removeTag("Discard")
        end
    end

    queueUpdate(player, true)
end

function confirmPowerClick(obj, player, rightClick)
    if rightClick then return end
    if getOwner(obj) ~= player then
        broadcastToColor("You cannot use cards from another player's tableau.", player, "White")
        return
    end

    if obj.hasTag("Slot") then obj = getCard(obj) end

    local p = playerData[player]
    local currentPhase = tostring(getCurrentPhase())
    local info = card_db[obj.getName()]
    local power = info.activePowers[currentPhase] and info.activePowers[currentPhase][p.selectedCardPower] or nil
    local oldHandCount = p.handCountSnapshot
    local paidCost = false
    local times = 1

    p.handCountSnapshot = countCardsInHand(player)

    if currentPhaseIndex == 0 and firstRound and p.selectedCardPower == "START_SAVE" then
        local discard = getDiscardInHand(player, false)

        if #discard < 1 then
            broadcastToColor("Please flip a card facedown in your hand before clicking confirm.", player, "White")
            return
        end

        local data = cardAlreadyUsedInit()
        data.selectedCard = p.selectedCard
        p.cardsAlreadyUsed[p.selectedCard] = data
        p.selectedCard = nil
        p.selectedCardPower = nil
        storeCard(obj, discard[1])
        return
    elseif currentPhase == "1" and p.beforeExplore then
        -- Discarding cards for prestige from hand before explore
        local marked = #discardMarkedCards(player)
        getPrestigeChips(player, marked)
        p.beforeExplore = false
        Wait.frames(function()
            doExploreDraw(player)
            queueUpdate(player, true)
        end, 1)
        return
    elseif currentPhase == "2" or currentPhase == "3" then
        if p.beforeDevelop or p.exploreAfterPower then
            local cardsInHand = countCardsInHand(player, false)
            local discarded = oldHandCount - cardsInHand
            local discardTarget = 1
            if currentPhase == "2" then
                discardTarget = p.powersSnapshot["MUST_DISCARD"]
            end
            if discarded >= discardTarget then
                p.beforeDevelop = false
                p.exploreAfterPower = false
                discardMarkedCards(player)
                queueUpdate(player, true)
                if currentPhase == "3" then
                    sound.AssetBundle.playTriggerEffect(3)
                    updateReadyButtons({player, true}, true)
                end
            else
                broadcastToColor("Please discard the required number of cards.", player, "White")
            end
            return
        elseif p.securityCouncil and info.passivePowers["3"] and info.passivePowers["3"]["PREVENT_TAKEOVER"] then
            if p.securityCouncilTarget and p.prestigeCount > 0 then
                discardPrestige(player, 1)
                p.securityCouncil = false

                preventTakeoverAttempt(p.securityCouncilTarget)
                drawTakeoverLines()

                p.securityCouncilTarget = nil
                Global.UI.setAttribute("securityCouncilMenu", "active", false)
                updateReadyButtons({player, true}, true)
                queueUpdate(player, true)
            elseif p.securityCouncilTarget and p.prestigeCount <= 0 then
                broadcastToColor("Prestige required to prevent takeover attempt.", player, "White")
            else
                broadcastToColor("Please select a player to stop their takeover attempt.", player, "White")
            end
            return
        end

        local marked = {}
        local node = getLinkedListNode(p.miscSelectedCards, obj.getGUID())
        local n = 0
        power = node.power
        if power.name == "MILITARY_HAND" then
            marked = discardMarkedCards(player, not takeoverPhase)
            local usedAmount = 0
            if p.cardsAlreadyUsed[obj.getGUID()] and p.cardsAlreadyUsed[obj.getGUID()][power.name] then
                usedAmount = p.cardsAlreadyUsed[obj.getGUID()][power.name].strength
            end
            n = #marked
            p.tempMilitary = p.tempMilitary + math.min(n, power.strength - usedAmount)
            refreshTakeoverMenu(player)
        elseif power.name == "DISCARD" then
            n = 1
            paidCost = true
            discardCard(obj)
        elseif power.name == "CONSUME_PRESTIGE" then
            n = power.strength
            paidCost = true
            p.consumedPrestige = p.consumedPrestige + 1
        elseif power.name == "UPGRADE_WORLD" then
            if not p.upgradeWorldOld or not p.upgradeWorldNew then
                broadcastToColor("Please select a world on your tableau and a new world to replace it.", player, "White")
                return
            else
                n = power.strength
            end
        end

        if n == 0 then return end

        local data = markUsedMisc(player, obj, power, n)
        if #marked > 0 then
            data.markedDiscards = appendList(data.markedDiscards, marked)
        end

        if paidCost and power.codes["EXTRA_MILITARY"] then
            p.tempMilitary = p.tempMilitary + power.strength
        end

        queueUpdate(player, true)
        return
    elseif currentPhase == "4" then
        if p.selectedCardPower == "CONSUME_PRESTIGE" then
            discardPrestige(player, power.times)
            paidCost = true
        elseif p.selectedCardPower == "DRAW_LUCKY" then
            local newCard = drawCard()
            local newCardInfo = card_db[newCard.getName()]
            local n = obj.getVar("number") or 1
            broadcastToAll("Gambling World: " .. (Player[player].steam_name or player) .. " guessed " .. n .. " and drew \"" .. newCard.getName() .. "\" (cost: " .. newCardInfo.cost .. ").", player)
            if n == newCardInfo.cost then
                newCard.deal(1, player)
            else
                discardCard(newCard)
            end
        elseif p.selectedCardPower == "DISCARD_HAND" then
            if enforceRules and not p.canConfirm then
                broadcastToColor("Please discard the required number of cards.", player, "White")
                return
            end
    
            times = math.min(power.times, #discardMarkedCards(player))
            if times == 0 then return end
            paidCost = true
        elseif p.selectedCardPower == "ANTE_CARD" then
            local prefix =  "Gambling World: " .. (Player[player].steam_name or player)
            if p.anteSucceed then
                if p.selectedReward then
                    local card = getObjectFromGUID(p.selectedReward)
                    broadcastToAll(prefix .. " kept \"" .. card.getName() .. ".\"", player)

                    for _, obj in pairs(Player[player].getHandObjects(1)) do
                        obj.highlightOff()
                        if obj.getGUID() ~= p.selectedReward and obj.hasTag("Gamble Reward") then
                            obj.setTags({})
                            discardCard(obj)
                        else
                            obj.setTags({})
                        end
                    end
                    p.selectedReward = nil
                elseif enforceRules then
                    broadcastToColor("Please select a reward to keep.", player, "White")
                    return
                end
            elseif p.selectedAnte then
                local drawnCards = {}
                local anteCard = getObjectFromGUID(p.selectedAnte)
                local anteInfo = card_db[anteCard.getName()]

                broadcastToAll(prefix .. " anted \"" .. anteCard.getName() .. "\" (cost:" .. anteInfo.cost .. ").", player)

                for i=1, anteInfo.cost do
                    local newCard = drawCard()
                    local newInfo = card_db[newCard.getName()]
                    drawnCards[#drawnCards+1] = newCard

                    printToAll(prefix .. ' drew "' .. newCard.getName() .. '" (cost: ' .. newInfo.cost .. ').', "Grey")

                    if newInfo.cost > anteInfo.cost then
                        p.anteSucceed = true
                    end
                end

                p.selectedAnte = nil
                highlightOff(anteCard)

                if p.anteSucceed then
                    for _, card in pairs(drawnCards) do
                        card.deal(1, player)
                        card.addTag("Gamble Reward")
                    end

                    queueUpdate(player, true)
                    return
                else
                    discardCard(anteCard)
                    broadcastToAll(prefix .. " was unlucky and lost the ante.", player)
                end
            else
                broadcastToColor("Please select a card to ante.", player, "White")
                return
            end
        end
    elseif currentPhase == "5" then
        if p.selectedCardPower == "DISCARD_HAND" then
            local n = #discardMarkedCards(player)
            if enforceRules and n <= 0 then
                broadcastToColor("Please discard the required number of cards.", player, "White")
                return
            end

            local windfallCode = false
            for code, v in pairs(power.codes) do
                if code:sub(1,8) == "WINDFALL" then
                    windfallCode = true
                    break
                end
            end

            if windfallCode then
                if not p.paidCost[obj.getGUID()] then p.paidCost[obj.getGUID()] = {} end
                p.paidCost[obj.getGUID()][power.name .. power.index] = true
                queueUpdate(player, true)
                return
            elseif power.codes["PRODUCE"] then
                tryProduceAt(player, obj)
            end
        end
    end

    if paidCost and power then
        local vpMultiplier = p.powersSnapshot["DOUBLE_VP"] and 2 or 1

        if power.codes["GET_VP"] then
            getVpChips(player, power.strength * vpMultiplier)
        end
        if power.codes["GET_3_CARD"] then
            dealTo(3, player)
        end
        if power.codes["GET_CARD"] then
            dealTo(power.strength, player)
        end
        if power.codes["GET_PRESTIGE"] then
            getPrestigeChips(player, power.strength)
        end
    end

    markUsed(player, obj, power)
    queueUpdate(player, true)
end

function goodSelectClick(slot, player, rightClick)
    if rightClick then return end
    if getOwner(slot) ~= player then
        broadcastToColor("You cannot use cards from another player's tableau.", player, "White")
        return
    end

    local parentCard = getCard(slot)
    local currentPhase = tostring(getCurrentPhase())
    local p = playerData[player]
    local guid = p.selectedCard
    local powerName = p.selectedCardPower
    local node = getLastNode(p.miscSelectedCards)

    if currentPhase == "2" or currentPhase == "3" then
        guid = node.value
        powerName = node.power.name
    end

    local selectedCard = getObjectFromGUID(guid)
    local selectedInfo = card_db[selectedCard.getName()]

    local powers = selectedInfo.activePowers[currentPhase]
    local power = powers[powerName]
    local powerUsed = false

    if (currentPhase == "2" or currentPhase == "3") and node then
        local good = getGoods(parentCard)
        if good == nil then broadcastToColor("Invalid goods selected.", player, color(1,0,0)) end

        p.markedGoods[good.getGUID()] = node
        displayXOn(good, player)
        local data = markUsedMisc(player, selectedCard, power, power.strength)
        data.markedGoods[good.getGUID()] = true
        queueUpdate(player, true)
        return
    elseif currentPhase == "4" then    -- consume the goods card
        local good = getGoods(parentCard)
        if good == nil then broadcastToColor("Error: Invalid goods selected.", player, color(1,0,0)) end

        -- Toggle selection of goods
        p.selectedGoods[good.getGUID()] = not p.selectedGoods[good.getGUID()]

        local selectedGoodsCount = 0
        for guid, selected in pairs(p.selectedGoods) do
            if selected then selectedGoodsCount = selectedGoodsCount + 1 end
        end

        if selectedGoodsCount >= p.mustConsumeCount then
            local vpMultiplier = p.powersSnapshot["DOUBLE_VP"] and 2 or 1
            local times = 1

            if p.selectedCardPower == "TRADE_ACTION" then
                times = 0
                local price = good.memo
                dealTo(price, player)
            elseif p.selectedCardPower == "CONSUME_ALL" then
                times = selectedGoodsCount - 1
            elseif selectedGoodsCount <= power.times or p.selectedCardPower == "CONSUME_N_DIFF" then
                times = selectedGoodsCount
            end

            for i=1, times do
                if power.codes["GET_VP"] then getVpChips(player, power.strength * vpMultiplier) end
                if power.codes["GET_CARD"] then dealTo(power.strength, player) end
                if power.codes["GET_2_CARD"] then dealTo(power.strength * 2, player) end
                if power.codes["GET_3_CARD"] then dealTo(power.strength * 3, player) end
                if power.codes["GET_PRESTIGE"] then getPrestigeChips(player, power.strength) end
            end

            for guid, selected in pairs(p.selectedGoods) do
                discardCard(getObjectFromGUID(guid))
            end

            powerUsed = true
        end
    elseif currentPhase == "5" then     -- produce the goods card
        local windfallCode = p.selectedCardPower:sub(1,8) == "WINDFALL"
        if not windfallCode then
            for code, v in pairs(power.codes) do
                if code:sub(1,8) == "WINDFALL" then
                    windfallCode = true
                    break
                end
            end
        end

        if windfallCode then
            tryProduceAt(player, parentCard)
        end

        powerUsed = true
    end

    if powerUsed then
        markUsed(player, selectedCard, power)
    end

    queueUpdate(player, true)
end

function cardSelectClick(object, player, rightClick)
    if rightClick then return end

    if object.hasTag("Slot") then object = getCard(object) end

    local p = playerData[player]

    if enforceRules and p.recordedCards[object.getName()] then
        broadcastToColor("You cannot play a card you already have in your tableau.", player, "White")
        return
    end

    if isUpgradingWorld(player) then
        if p.upgradeWorldOld then
            -- local node = p.miscSelectedCards
            -- markUsedMisc(player, getObjectFromGUID(node.value), node.power, 1)
            -- p.miscSelectedCards = {}
            p.upgradeWorldNew = object.getGUID()
        end
    elseif p.selectedCardPower == "ANTE_CARD" then
        if p.anteSucceed then
            p.selectedReward = object.getGUID()
        else
            p.selectedAnte = object.getGUID()
        end
        object.addTag("Selected")
    else
        p.selectedCard = object.getGUID()
        p.handCountSnapshot = countCardsInHand(player, true)
        p.selectedGoods = {}
        object.addTag("Selected")
    end

    updateReadyButtons({player, false})
    queueUpdate(player, true)
end

function cardCancelClick(object, player, rightClick)
    if rightClick then return end

    if object.hasTag("Slot") then
        object = getCard(object)
    end

    local p = playerData[player]

    if p.selectedCardPower == "ANTE_CARD" then
        p.selectedAnte = nil
        p.selectedReward = nil
    else
        cancelAllMarkedCards(player, p.selectedCard)

        p.selectedCard = nil
        p.selectedCardPower = ""
        p.miscSelectedCards = {}
    end

    object.removeTag("Selected")
    highlightOff(object)

    for _, obj in pairs(Player[player].getHandObjects(1)) do
        if obj.is_face_down then
            obj.flip()
        end
    end

    updateReadyButtons({player, false})
    queueUpdate(player, true)
end

function worldSelectClick(object, player, rightClick)
    if rightClick then return end

    if object.hasTag("Slot") then
        object = getCard(object)
    end

    local p = playerData[player]
    p.upgradeWorldOld = object.getGUID()
    p.updateWorldNew = nil
    queueUpdate(player, true)
end

function endOfPhaseGoalCheck()
    local firstGoals = getObjectsWithTag("First Goal")

    for _, goal in pairs(firstGoals) do
        goal.call("endPhaseCheck", {getCurrentPhase(), playerData})
    end

    local mostGoals = getObjectsWithTag("Most Goal")

    for _, goal in pairs(mostGoals) do
        goal.call("endPhaseCheck", {getCurrentPhase(), playerData})
    end
end

-- [1] = goal tile, [2] = player
function moveGoalToPlayer(params)
    local tile = params[1]
    local player = params[2]
    local i = playerData[player].index
    local tableau = getObjectFromGUID(tableau_GUID[i])
    local sp = tableau.getSnapPoints()
    local spIndexOffset = 5

    -- find first empty spot
    local spot = sp[#sp-spIndexOffset]
    for i=#sp-spIndexOffset, #sp do
        local pos = tableau.positionToWorld(sp[i].position)
        local hits = Physics.cast({
            origin = add(pos, {0, 1, 0}),
            direction = {0,-1,0},
            max_direction = 3,
        })

        if #hits > 0 and hits[1].hit_object == tableau then
            tile.setPosition(add(pos, {0, 0.3, 0}))
            tile.setRotation(tableau.getRotation())
            break
        end
    end
end

function getStartWorldNumber(player)
    local p = playerData[player]
    local tableau = getObjectFromGUID(tableau_GUID[p.index])
    local sp = tableau.getSnapPoints()[1]
    local hits = Physics.cast({
        origin = add(tableau.positionToWorld(sp.position), {0,1,0}),
        direction = {0,-1,0},
        max_distance = 2
    })

    for _, hit in pairs(hits) do
        local obj = hit.hit_object
        if obj.type == 'Card' and not obj.is_face_down and not obj.hasTag("Ignore Tableau") and startWorlds[obj.getName()] then
            return startWorlds[obj.getName()]
        else
            broadcastToAll("Error: No start world detected for " .. (Player[player].steam_name or player), color(1, 0, 0))
        end
    end

    return 1000
end

function resolveTakeovers()
    local takeoverSuccess = false
    local players = playerOrder
    local firstIndex = playerData[firstPlayer].index
    local taken = {}

    local i = firstIndex
    while i <= #players do
        local player = players[i]
        local p = playerData[player]

        if p.takeoverSource and p.takeoverTarget then
            local sourceCard = getObjectFromGUID(p.takeoverSource)
            local sourceInfo = card_db[sourceCard.getName()]
            local targetCard = getObjectFromGUID(p.takeoverTarget)
            local targetInfo = card_db[sourceCard.getName()]

            local sourceStr = calcStrength(player, targetCard, false)
            local targetStr = calcStrength(getOwner(targetCard), targetCard, true)

            -- Discard one time use takeover cards
            if p.takeoverPower.name == "DISCARD" then
                discardCard(sourceCard)
                wait(0.05)
            end

            -- Takeover successfull
            if not taken[targetCard.getGUID()] and sourceStr >= targetStr then
                local destroy = false
                taken[targetCard.getGUID()] = true

                -- Process rewards
                local node = p.prevMiscSelectedCards
                while node and node.value do
                    if node.power.name == "TAKEOVER_PRESTIGE" or node.power.codes["DESTROY"] then
                        getPrestigeChips(player, node.power.strength)
                        if node.power.codes["DESTROY"] then destroy = true end
                    elseif node.power.codes["PRESTIGE"] then
                        getPrestigeChips(player, 2)
                    end
                    node = node.next
                end

                -- Take control of the target card
                if destroy then
                    discardCard(targetCard)
                    broadcastToAll((Player[player].steam_name or player) .. ' successfully destroyed "' .. targetCard.getName() ..'."', player)
                else
                    attemptPlayCard(targetCard, player)
                    broadcastToAll((Player[player].steam_name or player) .. '\'s takeover of "' .. targetCard.getName() ..'" was successful!', player)
                end
                takeoverSuccess = true
            else
                broadcastToAll((Player[player].steam_name or player) .. " failed to takeover \"" .. targetCard.getName() .. '."', player)
            end

            finalizeUsedResources(player)

            p.takeoverSource = nil
            p.takeoverPower = nil
            p.takeoverTarget  = nil
        end

        i = i + 1
        if i > #players then i = 1 end
        if i == firstIndex then break end
    end

    return takeoverSuccess
end

function gamblingWorldChangeValue(obj, player, rightClick)
    local n = obj.getVar("number")
    if not n then
        n = 1
    end

    if rightClick then
        if n > 1 then
            n = n - 1
        end
    elseif n < 7 then
        n = n + 1
    end

    obj.editButton({
        index = 0,
        label = n
    })
    obj.setVar("number", n)
end

function preventTakeoverAttempt(player)
    local p = playerData[player]
    local card = getObjectFromGUID(p.takeoverSource)
    local info = card_db[card.getName()]
    local powers = info.activePowers["3"]

    broacastToAll((Player[player].steam_name or player) .. "'s takeover attempt has been defeated by \"Pan-Galactic Security Council.\"", "Purple")

    -- Remove takeover cards if using them requires discard
    if powers["DISCARD"] then
        discardCard(card)
    elseif powers["TAKEOVER_PRESTIGE"] then
        discardPrestige(player, 1)
    end

    -- Refund spent cards for extra military because takeover attempt pointless
    for guid, data in pairs(p.alreadyUsedCards) do
    end
    --cancelAllMarkedCards(player)

    p.takeoverTarget = nil
end