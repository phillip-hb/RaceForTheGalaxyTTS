require("util")
require("cardtxt")
require("gameUi")

---1: starting hand, 0: select action. 100: end of round. Otherwise, index of selectedPhases
currentPhaseIndex = -1
gameStarted = false
advanced2p = false
placeTwoTriggered = false
selectedPhases = {}
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
        miscSelectedCard = nil,
        miscSelectedCards = {},
        mustConsumeCount = 0,
        produceCount = {},
        paidCost = {},
        tempMilitary = 0,
        incomingGood = false,
        forcedReady = false,
        lastPlayedCard = nil,
        roundEndDiscardCount = 0
    }
end

playerData = {Yellow=player(1),Red=player(2),Blue=player(3),Green=player(4)}
queueUpdateState = {Yellow=false, Red=false, Blue=false, Green=false}
updateTimeSnapshot = {Yellow=0, Red=0, Blue=0, Green=0}

gameEndMessage = false

requiresConfirm = {["DISCARD_HAND"]=1}
requiresGoods = {["TRADE_ACTION"]=1,["CONSUME_ANY"]=1,["CONSUME_NOVELTY"]=1,["CONSUME_RARE"]=1,["CONSUME_GENE"]=1,["CONSUME_ALIEN"]=1,
    ["CONSUME_3_DIFF"]=1,["CONSUME_N_DIFF"]=1,["CONSUME_ALL"]=1}
goodsHighlightColor = {
     ["NOVELTY"] = color(0.345, 0.709, 0.974),
     ["RARE"] = color(0.709, 0.407, 0.129),
     ["GENE"] = color(0.278, 0.760, 0.141),
     ["ALIEN"] = color(0.933, 0.909, 0.105),
}

-- Determines which settle powers can chain with other settle powers. If separated with '|', the first word is the key, the second a matching code
compatible = {
    ["DISCARD|REDUCE_ZERO"] = {"PAY_MILITARY"},
    ["DISCARD|EXTRA_MILITARY"] = {"MILITARY_HAND", "DISCARD_CONQUER_SETTLE"},
    ["MILITARY_HAND"] = {"DISCARD|EXTRA_MILITARY", "DISCARD_CONQUER_SETTLE"},
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

disableInteract_GUID = {presentedPhaseCardTile_GUID, tableau_GUID, readyTokens_GUID, smallReadyTokens_GUID, helpDisplay_GUID, statTracker_GUID}

vpPoolBag_GUID = "c2e459"
vpInfBag_GUID = "5719f7"
drawZone_GUID = "32297e"
discardZone_GUID = "fe5c37"

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
phaseCardNames = {"Explore (+5)", "Explore (+1,+1)", "Develop", "Settle", "Consume ($)", "Consume (x2)", "Produce"}
phaseCardNamesAdv2p = {"Explore (+5)", "Explore (+1,+1)", "Develop", "DevelopAdv2p", "Settle", "SettleAdv2p", "Consume ($)", "Consume (x2)", "Produce"}
twoPlayerAdvancedMode = false

goodsSnapPointOffset = {-0.6, 0.1, 0.4}
drawDeck_GUID = ""
discardPile = nil
vpBag = nil

-- GUIDS of cards that may have possible actions to perform
possibleTableauActions = {["Yellow"] = {}, ["Red"] = {}, ["Blue"] = {}, ["Green"] = {}}

function onSave()
    local saved_data = {}
    saved_data.gameStarted = gameStarted
    saved_data.currentPhaseIndex = currentPhaseIndex
    saved_data.selectedPhases = selectedPhases
    saved_data.drawDeck_GUID = drawDeck_GUID
    saved_data.advanced2p = advanced2p
    saved_data.playerData = playerData
    saved_data.placeTwoTriggered = placeTwoTriggered
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
        placeTwoTriggered = data.placeTwoTriggered or false
    end

    card_db = loadData(0)

    trySetAdvanced2pMode()

    for i=1, #disableInteract_GUID do
        for j=1, #disableInteract_GUID[i] do
            local obj = getObjectFromGUID(disableInteract_GUID[i][j])
            --if obj then obj.interactable = false end
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
end

-- ======================
-- Game specific helper functions
-- ======================
function getName(obj)
     return obj.getName() .. (obj.hasTag("Adv2p") and "Adv2p" or "")
end

-- converts the raw phase value into corresponding actual phase. Use selectedPhases[currentPhaseIndex] to get the raw value instead.
function getCurrentPhase()
    local phase = selectedPhases[currentPhaseIndex]
    if advanced2p and phase then
        if phase == 3 then
            phase = 2
        elseif phase == 4 or phase == 5 then
            phase = 3
        elseif phase >= 6 then
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

function updateHandCount(playerColor)
     local i = playerData[playerColor].index
     local statTracker = getObjectFromGUID(statTracker_GUID[i])
     if statTracker then
          statTracker.call("updateLabel", {"hand", #Player[playerColor].getHandObjects()})
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

            if trait == "goods" and info[trait] == name or
                trait ~= "goods" and info[trait][name] then
                count = count + 1
            end

            ::skip::
        end
    end

    return count
end

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

        -- no goods, produce on planet
        p.produceCount[info.goods] = p.produceCount[info.goods] + 1
        card.memo = placeGoodsAt(card.positionToWorld(goodsSnapPointOffset), card.getRotation()[2], player)

        if powers and powers["DRAW_IF"] then dealTo(powers["DRAW_IF"].strength, player) end

        return true
    end

    return false
end

function getVpChips(player, n)
     if not vpBag then
          vpBag = getObjectFromGUID(vpPoolBag_GUID)
     end

     local tableau = getObjectFromGUID(tableau_GUID[playerData[player].index])

     for i=1, n do
          if vpBag.type == "Bag" and #vpBag.getObjects() <= 0 then
               vpBag = getObjectFromGUID(vpInfBag_GUID)
          end

          vpBag.takeObject({
               position = tableau.positionToWorld({-1.4, 2, -0.8}),
               rotation = tableau.getRotation()
          })
     end
end

function getCardActions(phase, card)
     local data = cardData[card.getName()]

     if not data.powers[phase] then
          return nil
     end

     local results = {}

     for i, data in pairs(data.powers[phase]) do
          if phase == "3" and settleActions[data.name] or
             phase == "4" and consumeActions[data.name] or
             phase == "5" and produceActions[data.name] then
               results[i] = {name = data.name, data = data}
          end
     end

     return results
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
               if not obj.hasTag("Discard") and not obj.hasTag("Action Card") then
                    n = n + 1
               end
          end

          return n
     end
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

-- returns number of cards discarded from hand
function discardMarkedCards(player)
     local count = 0
     for _, obj in pairs(Player[player].getHandObjects(1)) do
          if obj.type == 'Card' and (obj.hasTag("Discard") or obj.is_face_down) then
               discardCard(obj)
               count = count + 1
          end
     end

     return count
end

-- check zone for any 'Selected' cards and attempt to play them
function attemptPlayCard(card, player)
     if type(card) == "table" then
          player = card[2]
          card = card[1]
     end

     local tableau = getObjectFromGUID(tableau_GUID[playerData[player].index])
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
                    local phase = getCurrentPhase()
                    local powers = playerData[player].powersSnapshot
                    if powers["DRAW_AFTER"] then
                         dealTo(powers["DRAW_AFTER"], player)
                    end
               end

               local pos = tableau.positionToWorld(sp[i].position)
               local rot = tableau.getRotation()
               card.setPosition(add(pos, {0, 0.02, 0}))
               card.setRotation({rot[1], rot[2], 0})
               card.removeTag("Selected")
               highlightOff(card)
                playerData[player].lastPlayedCard = card.getGUID()

               -- if windfall, place a goods on top
               if card_db[card.getName()].flags["WINDFALL"] then
                    placeGoodsAt(card.positionToWorld(goodsSnapPointOffset), rot[2], player)
               end

               return
          end
     end
end

function placeGoodsAt(position, yRotation, player)
     local card = drawCard()

     if card then
          card.setPositionSmooth(add(position, {0, 1.5, 0}))
          card.setRotationSmooth({0, yRotation, 180})
          playerData[player].incomingGood = true
     else
          -- shouldn't ever happen, but just in case
          broadcastToAll("No cards detected in draw or discard pile", "Red")
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
     card.memo = ''
     card.setDescription('')
     card.setTags({""})
     card.highlightOff()
     card.setScale({1,1,1})

     if not discardPile or discardPile.isDestroyed() then
          discardPile = getDeckOrCardInZone(discardZone)
     end

     if discardPile then
          discardPile = discardPile.putObject(card)
          return
     end

     discardPile = card
     card.setPosition(discardZone.getPosition())
     card.setRotation({0, 0, 180})
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

function resetPlayerState(player)
    local data = playerData[player]
    data.powersSnapshot = {}
    data.selectedCard = nil
    data.selectedCardPower = ""
    data.miscSelectedCards = {}
    data.miscSelectedCard = nil
    data.lastPlayedCard = nil
    data.paidCost = {}
    data.forcedReady = false
    data.incomingGood = false
    data.selectedGoods = {}
    data.roundEndDiscardCount = 0
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

function onObjectRotate(object, spin, flip, player_color, old_spin, old_flip)
    if object.hasTag("Action Card") then
        return
    end

    local inHandZone = false

    local zones = object.getZones()
    for i=1, #zones do
        if handZoneMap[zones[i].getGUID()] then
            inHandZone = true
            break
        end
    end

    if inHandZone and (flip == 180 or flip == 0) and not object.hasTag("Selected") then
        if flip == 180 then
            object.addTag("Discard")
        elseif flip == 0 then
            object.removeTag("Discard")
        end

        updateHelpText(player_color)
    end

    -- check to see if the object is in the player's hand zone to prevent mark for deletion
    if object.hasTag("Selected") and inHandZone and flip == 180 then
        local rot = object.getRotation()
        object.setRotation({rot[1], rot[2], 0})
        return
    end
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
                        object.highlightOn(goodsHighlightColor[data.goods])
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
                p.miscSelectedCard = nil
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
     gameStarted = true
     currentPhaseIndex = -1
     advanced2p = params.advanced2p

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

function playerReadyClicked(playerColor)
    local i = playerData[playerColor]
    local count = getSelectedActionsCount(playerColor)

    if currentPhaseIndex == 0 and (advanced2p and count < 2 or not advanced2p and count < 1) then
        if advanced2p then
            broadcastToColor("You must select 2 action cards!", playerColor, "White")
        else
            broadcastToColor("You must select an action card!", playerColor, "White")
        end

        updateReadyButtons({playerColor, false})
        return
    end

    startLuaCoroutine(Global, "checkAllReadyCo")
end

-- Makes all the ready buttons belonging to player the same toggle state
-- [1] = owner, [2] = state
function updateReadyButtons(params)
    local player = params[1]
    local state = params[2]
    local i = playerData[player].index
    local token = getObjectFromGUID(readyTokens_GUID[i])
    if token then token.call("setToggleState", state) end
    token = getObjectFromGUID(smallReadyTokens_GUID[i])
    if token then token.call("setToggleState", state) end

    if params[2] then
        playerReadyClicked(player)
    end
end

function checkAllReadyCo()
    -- Check if all players are ready to move on to next step of game
    local players = getSeatedPlayersWithHands()

    for _, player in pairs(players) do
        local readyToken = getObjectFromGUID(readyTokens_GUID[playerData[player].index])
        if not readyToken.getVar("isReady") then return 1 end
    end

    -- remove misc selected cards if they have discard power
    local discardHappened = false
    local phase = getCurrentPhase()

    for _, player in pairs(players) do
        local p = playerData[player]
        local node = p.miscSelectedCards
        while node and node.value do
            local card = getObjectFromGUID(node.value)
            local info = card_db[card.getName()]
            local powers = info.activePowers[tostring(phase)]
            if powers and (powers["DISCARD"] or powers["DISCARD_REDUCE"] or powers["DISCARD_CONQUER_SETTLE"]) then
                discardCard(card)
                discardHappened = true
            end
            node = node.next
        end

        p.miscSelectedCards = {}
    end

    if discardHappened then wait(0.1) end

    -- play selected cards in hand
    local skipPlaceTwo = placeTwoTriggered
    placeTwoTriggered = false
    local placeTwo = {false,false,false,false}

    for _, player in pairs(players) do
        for _, obj in pairs(Player[player].getHandObjects(1)) do
            if obj.type == 'Card' and obj.hasTag("Selected") then
                attemptPlayCard(obj, player)
            elseif not phase and obj.hasTag("Explore Highlight") then
                -- discard not selected starting homeworld
                discardCard(obj)
            end
        end

        local p = playerData[player]
        if not skipPlaceTwo and getCurrentPhase() == 3 and p.powersSnapshot["PLACE_TWO"] and p.lastPlayedCard then
            placeTwo[p.index] = true
            placeTwoTriggered = true
        end

        -- discard all face down cards in hand
        local n = discardMarkedCards(player)
        if currentPhaseIndex == #selectedPhases then
            p.roundEndDiscardCount = n
        end
        p.selectedCard = nil
    end

    wait(0.1)

    for _, player in pairs(players) do
        updateReadyButtons({player, false})
    end

    for _, player in pairs(players) do
        if placeTwoTriggered then
            if placeTwo[playerData[player].index] then
                broadcastToAll("Waiting for " .. Player[player].steam_name .. "'s use of Improved Logistics.", player)
                queueUpdate(player, true)
            else
                updateReadyButtons({player, true})
            end
        end
    end

    -- Trigger Improved Logistics
    if placeTwoTriggered then
        return 1
    end

    if gameStarted and currentPhaseIndex == -1 then
        currentPhaseIndex = 0
        startNewRound()
        return 1
    end

    if currentPhaseIndex == 0 then  -- All players have selected an action
        local phases = {}

        -- flip over all selected phase cards and phase tiles
        for _, guid in pairs(selectedActionZone_GUID) do
            local zone = getObjectFromGUID(guid)
            local selectedActions = {}

            for _, obj in pairs(zone.getObjects()) do
                if obj.hasTag("Action Card") and obj.is_face_down then
                    obj.flip()
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

        for phase, _ in pairs(phases) do
            local index = phaseIndex[phase]
            local tile = getObjectFromGUID(phaseTilePlacement[index][1])
            tile.setRotationSmooth({0, 180, 0})
            selectedPhases[#selectedPhases + 1] = phaseIndex[phase]
        end

        selectedPhases[#selectedPhases + 1] = 100

        table.sort(selectedPhases)

        currentPhaseIndex = -1000

        wait(1.2)

        beginNextPhase()
    elseif currentPhaseIndex >= 1 then
        for player, data in pairs(playerData) do
            capturePowersSnapshot(player)
        end
        endOfPhaseGoalCheck()

        if currentPhaseIndex > #selectedPhases then
            -- round end check
        else
            beginNextPhase()
        end
    end
    return 1
end

function startNewRound()
    currentPhaseIndex = 0
    selectedPhases = {}
    resetPhaseTiles()

    broadcastToAll("Starting new round.", "White")

    for player, data in pairs(playerData) do
        resetPlayerState(player)
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
        broadcastToAll("Error: No phases selected.", "Red")
        startNewRound()
        return 1
    end

    if currentPhaseIndex <= 0 then currentPhaseIndex = 0 end

    -- Apply end of phase powers here
    if getCurrentPhase() == 5 then
        local tie = false
        local most = {["RARE"]=nil}
        for player, data in pairs(playerData) do
            if not most["RARE"] or data.produceCount["RARE"] > playerData[most["RARE"]].produceCount["RARE"]  then
                tie = false
                most["RARE"] = player
            elseif data.produceCount["RARE"] == playerData[most["RARE"]].produceCount["RARE"] then
                tie = true
            end
        end

        for player, data in pairs(playerData) do
            if data.powersSnapshot["DRAW_MOST_RARE"] then
                if tie or most["RARE"] ~= player then
                    broadcastToColor("Mining Conglomerate: Did not produce most Rare goods this phase.", player, "Grey")
                elseif most["RARE"] == player then
                    broadcastToColor("Mining Conglomerate: Produced most Rare goods this phase.", player, player)
                    dealTo(data.powersSnapshot["DRAW_MOST_RARE"], player)
                end
            end
        end
    end

    currentPhaseIndex = currentPhaseIndex + 1
    for player, data in pairs(playerData) do
        resetPlayerState(player)
    end
    updatePhaseTilesHighlight()

    if currentPhaseIndex <= #selectedPhases - 1 then
        local phase = getCurrentPhase()
        broadcastToAll(phaseText[selectedPhases[currentPhaseIndex]], "White")

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
        broadcastToAll("Round End", "White")
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
                broadcastToAll((Player[player].steam_name or player) .. " must discard down to " .. maxHandSize .. " cards.", player)
            else
                skipPlayers[player] = true
            end
        end

        if not mustDiscard then
            startNewRound()
        else
            for player, skip in pairs(skipPlayers) do
                updateReadyButtons({player, true})
            end
        end
    else
        -- end of round
        startNewRound()
    end

    for player, data in pairs(playerData) do
        queueUpdate(player, true)
    end
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

        p.handCountSnapshot = countCardsInHand(player) + p.powersSnapshot["DRAW"]

        for j=1, p.powersSnapshot["DRAW"] do
            local card = drawCard()
            card.deal(1, player)
            card.addTag("Explore Highlight")
        end
    end
end

function startDevelopPhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        capturePowersSnapshot(player, "2")

        if data.powersSnapshot["DRAW"] then
            dealTo(data.powersSnapshot["DRAW"], player)
        end

        updateHandState(player)
        updateHelpText(player)
    end
end

function startSettlePhase()
    for player, data in pairs(playerData) do
        data.cardsAlreadyUsed = {}
        data.miscSelectedCards = {}

        capturePowersSnapshot(player, "3")

        updateHandState(player)
        updateHelpText(player)
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

    -- -- Default values for certain phases
    if phase == "1" then
        results["DRAW"] = 2
        results["KEEP"] = 1
    end

    results["EXTRA_MILITARY"] = 0
    results["BONUS_MILITARY"] = 0
    results["TEMP_MILITARY"] = 0

    local ignore2ndDevelop = false
    local ignore2ndSettle = false
    local chromoCount = 0
    local militaryWorldCount = 0
    local tradeChromoBonus = false
    local perMilitary = false

    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]

        -- Place two triggered, skip the action card power and the last played card's powers
        if placeTwoTriggered and (card.hasTag("Action Card") or card.getGUID() == p.lastPlayedCard) then
            goto next_card
        end

        if info.flags["DISCARD_TO_12"] then
            results["DISCARD_TO_12"] = 1
        end

        if info.passivePowers[phase] then
            local powers = info.passivePowers[phase]
            for name, power in pairs(powers) do
                if not results[name] then
                    results[name] = 0
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

                    -- Do some manipulations for special cases
                    if selectedCard then
                        local selectedInfo = card_db[selectedCard.getName()]

                        -- Reduce powers with non matching types or improper bonus military
                        if name == "REDUCE" and next(power.codes) ~= nil and not power.codes[selectedInfo.goods or ""] or
                            name == "BONUS_MILITARY" and (power.codes["AGAINST_REBEL"] and not selectedInfo.flags["REBEL"] or 
                                                      not power.codes["AGAINST_REBEL"] and not power.codes[selectedInfo.goods or ""]) then
                            goto skip
                        end
                    end

                    if name == "EXTRA_MILITARY" and next(power.codes) ~= nil then
                        if power.codes["PER_MILITARY"] then
                            perMilitary = true
                        end
                        goto skip
                    end
                end

                results[name] = results[name] + power.strength

                if name == "TRADE_GENE" and power.codes["TRADE_BONUS_CHROMO"] then
                    tradeChromoBonus = true
                end

                ::skip::
            end
        -- Count base military for stat display purposes
        elseif phase ~= "3" and info.passivePowers["3"] then               
            local mil = info.passivePowers["3"]["EXTRA_MILITARY"]
            if mil and next(mil.codes) == nil then
                results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + mil.strength
            end
        end

        if info.flags["CHROMO"] then
            chromoCount = chromoCount + 1
        end

        if info.flags["MILITARY"] then
            militaryWorldCount = militaryWorldCount + 1
        end

        ::next_card::
    end

    if tradeChromoBonus then
        results["TRADE_GENE"] = results["TRADE_GENE"] + chromoCount
    end

    if perMilitary then
        results["EXTRA_MILITARY"] = results["EXTRA_MILITARY"] + militaryWorldCount
    end
    
    -- Track special cases
    if phase then
        local list = p.miscSelectedCards
        while list and list.value do
            local card = getObjectFromGUID(list.value)
            local info = card_db[card.getName()]

            for name, power in pairs(info.activePowers[phase]) do
                if name == "DISCARD" and power.codes["EXTRA_MILITARY"] then
                    results["BONUS_MILITARY"] = results["BONUS_MILITARY"] + power.strength
                end
            end

            list = list.next
        end
    end

    p.powersSnapshot = results

    local statTracker = getObjectFromGUID(statTracker_GUID[p.index])
    if statTracker then
        statTracker.call("updateLabel", {"military", results["EXTRA_MILITARY"]})
    end
end

function updateHandState(playerColor)
    local p = playerData[playerColor]
    local phase = getCurrentPhase()

    for _, obj in pairs(Player[playerColor].getHandObjects(1)) do
        local info = card_db[obj.getName()]

        obj.clearButtons()

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
        elseif (phase == 2 and info and info.type == 2) or    -- Make buttons on development or world cards if appropriate phase
            (phase == 3 and info and info.type == 1) then
            if phase == 3 and placeTwoTriggered and not p.powersSnapshot["PLACE_TWO"] then
                goto skip
            end

            if not p.selectedCard then
                createSelectButtonOnCard(obj)
            elseif p.selectedCard == obj.getGUID() then
                createCancelButtonOnCard(obj)
            end

            ::skip::
        end

        if phase == 1 and p.powersSnapshot["DISCARD_ANY"] ~= nil and not obj.hasTag("Explore Highlight") then
            obj.addTag("Explore Highlight")
        end

        -- Explore orange highlight
        if phase == 1 and obj.hasTag("Explore Highlight") then
            obj.highlightOn("Orange")
        elseif currentPhaseIndex == 0 or phase and phase ~= 1 and obj.hasTag("Explore Highlight") then
            obj.highlightOff()
            obj.removeTag("Explore Highlight")
        end

        if obj.hasTag("Selected") then
            highlightOn(obj, "rgb(0,1,0,1)", playerColor)
        end
    end

    updateHandCount(playerColor)
end

-- Make sure to call capturePowersSnapshot before calling this, otherwise may update with wrong modifiers
function updateTableauState(player)
    local p = playerData[player]
    local i = playerData[player].index
    local zone = getObjectFromGUID(tableauZone_GUID[i])
    local powersSnapshot = p.powersSnapshot
    local selectedCard = getObjectFromGUID(p.selectedCard)
    local selectedInfo = selectedCard and card_db[selectedCard.getName()] or nil
    local currentPhase = tostring(getCurrentPhase())

    local windfallCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    local goodsCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    local uniques = {}

    local selectedUniqueGoods = {}

    for card in allCardsInTableau(player) do
        card.clearButtons()
        card.highlightOff()
        highlightOff(card)
    end

    for guid, selected in pairs(p.selectedGoods) do
        if selected then
            local good = getObjectFromGUID(guid)
            local parent = getObjectFromGUID(good.getDescription())

            selectedUniqueGoods[card_db[parent.getName()].goods] = true
        end
    end

    local miscPowerSnapshot = {}
    local miscSelectedCardsTable = {}
    local miscSelectedCount = 0
    local list = p.miscSelectedCards

    while list and list.value do
        local card = getObjectFromGUID(list.value)
        miscSelectedCardsTable[list.value] = card

        local info = card_db[card.getName()]
        for name, power in pairs(info.activePowers[currentPhase]) do
            miscPowerSnapshot[name] = power
        end

        list = list.next
        miscSelectedCount = miscSelectedCount + 1
    end

    -- count certain cards, highlight goods, etc
    for _, obj in pairs(zone.getObjects()) do
        if obj.hasTag("Slot") then obj.clearButtons() end

        if obj.type == 'Card' and not obj.is_face_down then
            local parentData = card_db[obj.getName()]
            if parentData.flags["WINDFALL"] and not getGoods(obj) then
                windfallCount[parentData.goods] = windfallCount[parentData.goods] + 1
                windfallCount["TOTAL"] = windfallCount["TOTAL"] + 1
            end
        elseif obj.type == 'Card' and obj.is_face_down and obj.getDescription() ~= "" then  -- facedown goods on tableau
            local parentCard = getObjectFromGUID(obj.getDescription())
            local parentData = card_db[parentCard.getName()]

            if #parentCard.getZones() <= 0 then
                obj.setDescription("")
            elseif parentData.goods then
                obj.highlightOn(goodsHighlightColor[parentData.goods])

                goodsCount[parentData.goods] = goodsCount[parentData.goods] + 1
                uniques[parentData.goods] = 1
                goodsCount["TOTAL"] = goodsCount["TOTAL"] + 1

                -- create buttons on cards based on action
                if currentPhase == "4" and selectedCard then
                    local ap = selectedInfo.activePowers[currentPhase]
                    if p.selectedCardPower == "TRADE_ACTION" then
                        -- calculating cost to sell card
                        local power = ap[p.selectedCardPower]
                        local price = 0
                        local bonus = not power.codes["TRADE_NO_BONUS"]
                        local basePrice = {NOVELTY = 2, RARE = 3, GENE = 4, ALIEN = 5}

                        price = basePrice[parentData.goods] + (bonus and p.powersSnapshot["TRADE_" .. parentData.goods] or 0)
                        price = price + (bonus and p.powersSnapshot["TRADE_ANY"] or 0)

                        local parentPassive = parentData.passivePowers[currentPhase]
                        if bonus and parentPassive and parentPassive["TRADE_THIS"] then
                            price = price + parentPassive["TRADE_THIS"].strength
                        end

                        createGoodsButton(parentCard, "$➧" .. price, goodsHighlightColor[parentData.goods])
                        obj.memo = price
                    elseif ap then -- using normal consume powers
                        local makeButton = false
                        local power = ap[p.selectedCardPower]

                        if p.selectedCardPower == "CONSUME_ANY" or p.selectedCardPower == "CONSUME_ALL" or p.selectedCardPower == "CONSUME_" .. (parentData.goods or "") or
                            (((p.selectedCardPower == "CONSUME_3_DIFF" or p.selectedCardPower == "CONSUME_N_DIFF") and not selectedUniqueGoods[parentData.goods]) or (p.selectedGoods and p.selectedGoods[obj.getGUID()])) then
                            makeButton = true
                        end

                        if power.codes["CONSUME_THIS"] and selectedCard ~= parentCard then
                            makeButton = false
                        end

                        if makeButton then
                            createGoodsButton(parentCard, p.selectedGoods[obj.getGUID()] and "✔" or "", goodsHighlightColor[parentData.goods])
                        end
                    end
                end
            end
        end
    end

    local uniqueCount = tableLength(uniques)
    p.mustConsumeCount = 0
     -- possibleTableauActions[player] = {}

    -- Auto cancel certain cards
    if currentPhase == "4" and selectedCard and selectedCard.getName() == "Consume ($)" and goodsCount["TOTAL"] <= 0 and not p.incomingGood
        or currentPhase == "5" and selectedCard and selectedCard.getName() == "Produce" and windfallCount["TOTAL"] <= 0 then
        selectedCard = nil
        selectedInfo = nil
        p.selectedCard = nil
        p.selectedCardPower = ""
    end

    local createdButton = false

    -- refresh state on all cards in tableau
    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]

        if p.selectedCard == card.getGUID() then
            highlightOn(card, "rgb(0,1,0)", player)
        end

        if not card.hasTag("Action Card") then
            local ap = info.activePowers[currentPhase]
            local miscSelected = miscSelectedCardsTable[card.getGUID()]

            if miscSelected or placeTwoTriggered and info.passivePowers["3"] and info.passivePowers["3"]["PLACE_TWO"] then
                highlightOn(card, "rgb(0,1,0)", player)
            end

            if currentPhase == "2" and ap then
                for name, power in pairs(ap) do
                    if selectedCard then
                        if miscSelectedCount <= 0 then
                            createdButton = true
                            createUsePowerButton(card, power.index, info.activeCount[currentPhase], activePowers[currentPhase][name])
                        else
                            createCancelButton(card)
                        end
                    end
                end
            elseif currentPhase == "3" and ap then
                -- Create buttons for active powers
                if selectedCard then
                    for name, power in pairs(ap) do
                        local powerName = ""

                        if power.codes["AGAINST_REBEL"] and not selectedInfo.flags["REBEL"] then
                            goto skip_power
                        end

                        if miscSelectedCount <= 0 then
                            if name == "DISCARD" and power.codes["REDUCE_ZERO"] and selectedInfo.goods ~= "ALIEN" and not selectedInfo.flags["MILITARY"] then
                                powerName = name
                            elseif name == "DISCARD" and power.codes["EXTRA_MILITARY"] and selectedInfo.flags["MILITARY"] then
                                powerName = name
                            elseif name == "DISCARD_CONQUER_SETTLE" and not selectedInfo.flags["MILITARY"] then
                                powerName = name
                            elseif ap["PAY_MILITARY"] and selectedInfo.goods ~= "ALIEN" and selectedInfo.flags["MILITARY"] then
                                powerName = name
                            elseif ap["MILITARY_HAND"] and selectedInfo.flags["MILITARY"] then
                                powerName = name
                            end
                        elseif not miscSelectedCardsTable[card.getGUID()] then
                            -- check for compatible chains
                            local key = name
                            if name == "DISCARD" then
                                for code, _ in pairs(power.codes) do
                                    key = key .. "|" .. code
                                end
                            end

                            if compatible[key] then
                                for _, str in pairs(compatible[key]) do
                                    local tokens = split(str, "|")
                                    if (#tokens == 1 and miscPowerSnapshot[tokens[1]]) or (miscPowerSnapshot[tokens[1]] and miscPowerSnapshot[tokens[1]][tokens[2]]) then
                                        powerName = name
                                        break
                                    end
                                end
                            end
                        end

                        if powerName ~= "" and not miscSelected then
                            createdButton = true
                            createUsePowerButton(card, power.index, info.activeCount[currentPhase], activePowers[currentPhase][powerName])
                        elseif miscSelected then
                            createCancelButton(card)

                            if requiresConfirm[name] then
                                createConfirmButton(miscSelected)
                            end
                        end

                        ::skip_power::
                    end
                end
            elseif currentPhase == "4" and ap then
                local baseAmount = {}
                local goodslimit = 1
                local enoughGoods = false

                for i=1, info.activeCount[currentPhase] do
                    baseAmount[#baseAmount + 1] = 1
                end

                if #baseAmount > 0 then
                    for name, power in pairs(info.activePowers[currentPhase]) do
                        if name == "CONSUME_ANY" or name == "CONSUME_ALL" or name == "CONSUME_3_DIFF" or name == "CONSUME_N_DIFF" or name == "TRADE_ACTION" then
                            goodslimit = goodsCount["TOTAL"]
                        elseif name:sub(1,7) == "CONSUME" then
                            goodslimit = goodsCount[name:sub(9, name:len())]
                        end

                        if power.codes["CONSUME_TWO"] then
                            baseAmount[power.index] = 2
                        elseif name == "CONSUME_ALL" then
                            baseAmount[power.index] = goodsCount["TOTAL"]
                        elseif name == "CONSUME_3_DIFF" then
                            baseAmount[power.index] = uniqueCount < 3 and 100 or 3
                        elseif name == "CONSUME_N_DIFF" then
                            baseAmount[power.index] = math.max(1, uniqueCount)
                        elseif not requiresGoods[name] then
                            baseAmount[power.index] = 0
                        end

                        goodslimit = math.min(math.max(1, power.times * baseAmount[power.index]), goodslimit)
                    end
                end

                if not selectedCard then
                    for name, power in pairs(ap) do
                        local used = p.cardsAlreadyUsed[card.getGUID()]
                        if (not used or not used[name .. power.index]) and baseAmount[power.index] <= goodslimit then
                            createdButton = true
                            createUsePowerButton(card, power.index, info.activeCount[currentPhase], activePowers[currentPhase][name])
                        end
                    end
                elseif selectedCard == card then
                    createCancelButton(card)
                    local powerIndex = info.activePowers[currentPhase][p.selectedCardPower].index

                    if requiresConfirm[p.selectedCardPower] then
                        createConfirmButton(selectedCard)
                    end

                    p.mustConsumeCount = math.max(baseAmount[powerIndex], goodslimit)
                end
            elseif currentPhase == "5" then
                if not selectedCard and ap then
                    for name, power in pairs(ap) do
                        local makeButton = true
                        local windfallPrefix = name:sub(1,8) == "WINDFALL"
                        local targetGood = windfallPrefix and name:sub(10, name:len()) or ""
                        local used = p.cardsAlreadyUsed[card.getGUID()]
                        local windfallCountTarget = windfallCount[targetGood]
                        local open = getGoods(card)

                        if power.codes["NOT_THIS"] and not open then
                            windfallCountTarget = windfallCountTarget - 1
                        end

                        if used and used[name .. power.index] or
                            power.codes["WINDFALL_ANY"] and windfallCount["TOTAL"] <= 0 or
                            power.codes["PRODUCE"] and open or 
                            windfallPrefix and targetGood == "ANY" and windfallCount["TOTAL"] <= 0 or
                            windfallPrefix and windfallCountTarget and windfallCountTarget <= 0 then
                            goto skip
                        end

                        createdButton = true
                        createUsePowerButton(card, power.index, info.activeCount[currentPhase], activePowers[currentPhase][name])

                        ::skip::
                    end
                elseif selectedCard then
                    local power = selectedInfo.activePowers[currentPhase][p.selectedCardPower]
                    local open = not getGoods(card)
                    local paidCost = p.paidCost[selectedCard.getGUID()]
                    paidCost = paidCost and paidCost[power.name .. power.index]

                    local makeButton = false
                    if power.codes["WINDFALL_ANY"] and paidCost and open and info.goods then
                        makeButton = true
                    end

                    if info.goods and info.flags["WINDFALL"] and open and p.selectedCardPower:sub(1,8) == "WINDFALL" and card ~= selectedCard or makeButton then
                        local targetGood = p.selectedCardPower:sub(10, p.selectedCardPower:len())
                        if targetGood == "ANY" or targetGood == info.goods or power.codes["WINDFALL_ANY"] then
                            createGoodsButton(card, "▼", color(1, 1, 1, 0.9))
                        end
                    end

                    if selectedCard == card and not paidCost then
                        createCancelButton(selectedCard)

                        if requiresConfirm[p.selectedCardPower] then
                            createConfirmButton(selectedCard)
                        end
                    end
                end
            end
        end
    end

    -- Force the player ready when they have nothing left to do
    if (currentPhase == "4" or currentPhase == "5") and not p.forcedReady and createdButton == false and not selectedCard and not p.incomingGood then
        p.forcedReady = true
        if Player[player].seated then
            updateReadyButtons({player, true})
        end
    end
end

function markUsed(player, card, power)
    local p = playerData[player]

    if not p.cardsAlreadyUsed[card.getGUID()] then p.cardsAlreadyUsed[card.getGUID()] = {} end

    p.selectedGoods = {}
    p.cardsAlreadyUsed[card.getGUID()][p.selectedCardPower .. power.index] = true
    p.selectedCard = nil
    p.selectedCardPower = ""
    p.miscSelectedCards = {}

    queueUpdate(player, true)
end

function usePowerClick1(obj, player, button) usePowerClick(obj, player, button, 1) end
function usePowerClick2(obj, player, button) usePowerClick(obj, player, button, 2) end
function usePowerClick3(obj, player, button) usePowerClick(obj, player, button, 3) end

function usePowerClick(obj, player, rightClick, powerIndex)
    if rightClick then return end
    if obj.hasTag("Slot") then obj = getCard(obj) end

    local p = playerData[player]
    local currentPhase = tostring(getCurrentPhase())

    if currentPhase == "4" or currentPhase == "5" then
        p.selectedCard = obj.getGUID()
        local info = card_db[obj.getName()]
        for name, power in pairs(info.activePowers[currentPhase]) do
            if power.index == powerIndex then
                p.selectedCardPower = name

                -- Use power instantly
                if p.selectedCardPower == "DRAW" then
                    dealTo(power.strength, player)
                    markUsed(player, obj, power)
                    return
                elseif p.selectedCardPower == "VP" then
                    local vpMultiplier = p.powersSnapshot["DOUBLE_VP"] and 2 or 1
                    getVpChips(player, power.strength * vpMultiplier)
                    markUsed(player, obj, power)
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
        end

        if usedPower then
            markUsed(player, obj, power)
            queueUpdate(player, true)
            return
        end
    end

    local selectedCard = getObjectFromGUID(p.selectedCard)
    local selectedInfo = card_db[selectedCard.getName()]
    local node = p.miscSelectedCards

    while node and node.next do
         node = node.next
    end

    if not p.miscSelectedCards then p.miscSelectedCards = {} end

    if not p.miscSelectedCards.value then
         p.miscSelectedCards = {value = obj.getGUID(), next = nil}
         p.miscSelectedCard = obj.getGUID()
    else
         node.next = {value = obj.getGUID(), next = nil}
    end

    queueUpdate(player, true)
end

function cancelPowerClick(obj, player, rightClick)
    if rightClick then return end
    if obj.hasTag("Slot") then obj = getCard(obj) end

    local p = playerData[player]

    p.miscSelectedCards = deleteLinkedListNode(p.miscSelectedCards, obj.getGUID())

    if getCurrentPhase() ~= 3 and getCurrentPhase() ~= 2 then
        p.selectedCard = nil
        p.selectedCardPower = ""
        p.selectedGoods = {}
    end

    queueUpdate(player, true)
end

function confirmPowerClick(obj, player, rightClick)
    if rightClick then return end
    if obj.hasTag("Slot") then obj = getCard(obj) end

    local p = playerData[player]
    local currentPhase = tostring(getCurrentPhase())
    local power = card_db[obj.getName()].activePowers[currentPhase][p.selectedCardPower]

    if currentPhase == "5" then
        if p.selectedCardPower == "DISCARD_HAND" then
            discardMarkedCards(player)
            if power.codes["WINDFALL_ANY"] then
                if not p.paidCost[obj.getGUID()] then p.paidCost[obj.getGUID()] = {} end
                p.paidCost[obj.getGUID()][power.name .. power.index] = true
                queueUpdate(player, true)
                return
            elseif power.codes["PRODUCE"] then
                tryProduceAt(player, obj)
            end
        end
    elseif p.selectedCardPower == "DISCARD_HAND" then
        local times = math.min(power.times, discardMarkedCards(player))
        if power.codes["GET_VP"] then
            getVpChips(player, times)
        end
    end

    markUsed(player, obj, power)
end

function goodSelectClick(parentCard, player, rightClick)
    if rightClick then return end

    local p = playerData[player]
    local selectedCard = getObjectFromGUID(p.selectedCard)
    local selectedInfo = card_db[selectedCard.getName()]
    local currentPhase = tostring(getCurrentPhase())
    local powers = selectedInfo.activePowers[currentPhase]
    local power = powers[p.selectedCardPower]
    local powerUsed = false

    if currentPhase == "4" then    -- consume the goods card
        local good = getGoods(parentCard)

        if good == nil then
            broadcastToColor("Invalid goods selected.", player, "Red")
        end

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
            end

            for guid, selected in pairs(p.selectedGoods) do
                discardCard(getObjectFromGUID(guid))
            end

            powerUsed = true
        end
    elseif currentPhase == "5" then     -- produce the goods card
        if p.selectedCardPower:sub(1,8) == "WINDFALL" or power.codes["WINDFALL_ANY"] then
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

    p.selectedCard = object.getGUID()
    p.handCountSnapshot = countCardsInHand(player, true)
    p.selectedGoods = {}
    object.addTag("Selected")

    queueUpdate(player, true)
end

function cardCancelClick(object, player, rightClick)
     if rightClick then return end

     if object.hasTag("Slot") then
          object = getCard(object)
     end

     local p = playerData[player]

     p.selectedCard = nil
     p.selectedCardPower = ""
     p.miscSelectedCards = {}
     object.removeTag("Selected")
     highlightOff(object)

     queueUpdate(player, true)
end

function setHelpText(player, text)
    local i = playerData[player].index
    local obj = getObjectFromGUID(helpDisplay_GUID[i])
    obj.UI.setValue("label", text)
end

function updateHelpText(playerColor)
    local p = playerData[playerColor]
    local i = p.index
    local powers = p.powersSnapshot
    local handCount = p.handCountSnapshot
    local cardsInHand = countCardsInHand(playerColor, currentPhaseIndex == #selectedPhases)
    local currentPhase = getCurrentPhase()

    -- opening hand
    if gameStarted and currentPhaseIndex == -1 then
        if p.selectedCard then
            local discardTarget = powers["DISCARD"]
            local discarded = handCount - cardsInHand

            setHelpText(playerColor, "Determine starting hand. (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "▼ Select your start world.")
        end
    -- end of round
    elseif currentPhaseIndex > #selectedPhases then
    -- start of round
    elseif currentPhaseIndex == 0 then
        setHelpText(playerColor, "▲ Select an action.")
    -- explore
    elseif currentPhase == 1 then
        local discardTarget = math.max(0, powers["DRAW"] - powers["KEEP"])
        local discarded = handCount - cardsInHand

        setHelpText(playerColor, "Explore: draw " .. powers["DRAW"] .. ", keep " .. powers["KEEP"] .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
    elseif currentPhase == 2 then
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]
            local discardTarget = math.max(0, info.cost - (powers["REDUCE"] or 0))
            local discarded = handCount - cardsInHand
            local node = p.miscSelectedCards

            while node and node.value do
                local miscCard = getObjectFromGUID(node.value)
                local miscPowers = card_db[miscCard.getName()].activePowers["2"]

                if miscPowers then
                    if miscPowers["DISCARD_REDUCE"] then
                        discardTarget = math.max(0, discardTarget - 3)
                    end
                end

                node = node.next
            end

            setHelpText(playerColor, "Develop: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "▼ Develop: may play a development.")
        end
    elseif currentPhase == 3 then
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]

            -- Check for special settle power modifiers
            local reduceZero = false
            local reduceZeroName = ""
            local doMilitary = info.flags["MILITARY"]
            local payMilitary = false
            local payMilitaryStr = 0
            local militaryDiscount = 0
            local node = p.miscSelectedCards
            local militaryHandBonus = 0

            while node and node.value do
                local miscCard = getObjectFromGUID(node.value)
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
                        militaryHandBonus = math.min(miscPowers["MILITARY_HAND"].strength, discardCount)
                    elseif miscPowers["DISCARD_CONQUER_SETTLE"] then
                        doMilitary = true
                        militaryDiscount = miscPowers["DISCARD_CONQUER_SETTLE"].strength
                    end
                end
                node = node.next
            end

            if doMilitary and not payMilitary then
                setHelpText(playerColor, "Settle: " .. info.cost - militaryDiscount .. " defense. (Military " ..p.powersSnapshot["EXTRA_MILITARY"] +
                    p.powersSnapshot["TEMP_MILITARY"] + p.powersSnapshot["BONUS_MILITARY"] + militaryHandBonus .. "/" .. info.cost - militaryDiscount .. ")")
            else
                if reduceZero then
                    setHelpText(playerColor, "Settle: paid w/ " .. reduceZeroName .. ".")
                else
                    local payDiscount = 0
                    if payMilitary then
                        payDiscount = payMilitaryStr + (p.powersSnapshot["PAY_DISCOUNT"] or 0)
                    end
                    local discardTarget = math.max(0, info.cost - (powers["REDUCE"] or 0) - payDiscount)
                    local discarded = handCount - cardsInHand
                    setHelpText(playerColor, "Settle: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
                end
            end
        else
            if placeTwoTriggered then
                if not p.powersSnapshot["PLACE_TWO"] then
                    setHelpText(playerColor, "Please wait for other players.")
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
                setHelpText(playerColor, "▼ Consume: discard cards for VP.")
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

            if p.selectedCardPower:sub(1,8) == "WINDFALL" or (p.selectedCardPower == "DISCARD_HAND" and power["DISCARD_HAND"].codes["WINDFALL_ANY"] and paidCost) then
                setHelpText(playerColor, "▲ Produce: produce on windfall world.")
            elseif p.selectedCardPower == "DISCARD_HAND" then
                setHelpText(playerColor, "▼ Produce: discard card to use power.")
            end
        else
            setHelpText(playerColor, "▲ Produce: use powers.")
        end
    elseif currentPhase == 100 then
        local maxHandSize = p.powersSnapshot["DISCARD_TO_12"] and 12 or 10
        local discardTarget = cardsInHand - maxHandSize
        local discarded = cardsInHand - countCardsInHand(playerColor, false)

        if cardsInHand > maxHandSize then
            setHelpText(playerColor, "Enforce hand size. (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "Please wait for other players.")
        end
    end
end

function updateVp(player)
    local p = playerData[player]
    local i = p.index
    local zone = getObjectFromGUID(tableauZone_GUID[i])

    local vpChipCount = 0
    local flatVp = 0
    local devVp = 0
    local goodsCount = 0
    local uniqueWorldsCount = 0
    local uniqueWorlds = {}
    local baseMilitary = p.powersSnapshot["EXTRA_MILITARY"]
    local sixCostDevs = {}
    local cardNames = {}

    -- first pass to count certain items
    for _, obj in pairs(zone.getObjects()) do
        if obj.hasTag("Ignore Tableau") then goto skip end

        if obj.hasTag("VP") then
            if obj.hasTag("VP Chip") then
                vpChipCount = vpChipCount + math.max(1, obj.getQuantity())
            elseif obj.hasTag("Most Goal") then
                flatVp = flatVp + 5
            elseif obj.hasTag("First Goal") or obj.hasTag("Tied Chip")then
                flatVp = flatVp + 3
            end
        elseif obj.type == "Card" and not obj.hasTag("Action Card") then
            if obj.is_face_down and obj.getDescription() ~= "" then -- the card is a good
                goodsCount = goodsCount + 1
            else
                local info = card_db[obj.getName()]

                cardNames[obj.getName()] = true
                flatVp = flatVp + info.vp

                if info.goods and not uniqueWorlds[info.goods] then
                    uniqueWorldsCount = uniqueWorldsCount + 1
                    uniqueWorlds[info.goods] = true
                end

                if info.vpFlags then
                    sixCostDevs[#sixCostDevs + 1] = {obj, info}
                end
            end
        end

        ::skip::
    end

    local goodsPrefix = {"NOVELTY", "RARE", "GENE", "ALIEN"}

    -- Calculate score for all 6-cost devs in tableau
    for _, item in pairs(sixCostDevs) do
        local vp = 0
        local dev = item[2]

        for card in allCardsInTableau(player) do
            local info = card_db[card.getName()]
            local otherAlien = true
            local otherUplift = true

            -- world types
            local otherWorld = true
            for _, prefix in pairs(goodsPrefix) do
                if dev.vpFlags[prefix .. "_PRODUCTION"] and info.goods == prefix and not info.flags["WINDFALL"] then
                    otherWorld = false
                    vp = vp + dev.vpFlags[prefix .. "_PRODUCTION"]
                    if prefix == "ALIEN" then
                        otherAlien = false
                    end
                end
                if dev.vpFlags[prefix .. "_WINDFALL"] and info.goods == prefix and info.flags["WINDFALL"] then
                    otherWorld = false
                    vp = vp + dev.vpFlags[prefix .. "_WINDFALL"]
                    if prefix == "ALIEN" then
                        otherAlien = false
                    end
                end
            end

            if dev.vpFlags["WORLD_TRADE"] and info.type == 1 and info.passiveCount["4"] > 0 then
                vp = vp + dev.vpFlags["WORLD_TRADE"]
            end
            if dev.vpFlags["WORLD_CONSUME"] and info.type == 1 and info.activeCount["4"] > 0 then
                vp = vp + dev.vpFlags["WORLD_CONSUME"]
            end
            if dev.vpFlags["WORLD_EXPLORE"] and info.type == 1 and info.passiveCount["1"] > 0 then
                otherWorld = false
                vp = vp + dev.vpFlags["WORLD_EXPLORE"]
            end
            if dev.vpFlags["REBEL_MILITARY"] and info.type == 1 and info.flags["REBEL"] then
                otherWorld = false
                vp = vp + dev.vpFlags["REBEL_MILITARY"]
            end
            if dev.vpFlags["TERRAFORMING_FLAG"] and info.flags["TERRAFORMING"] then
                vp = vp + dev.vpFlags["TERRAFORMING_FLAG"]
            end
            if dev.vpFlags["IMPERIUM_FLAG"] and info.flags["IMPERIUM"] then
                vp = vp + dev.vpFlags["IMPERIUM_FLAG"]
            end
            if dev.vpFlags["CHROMO_FLAG"] and info.flags["CHROMO"] then
                otherUplift = false
                vp = vp + dev.vpFlags["CHROMO_FLAG"]
            end
            if otherWorld and dev.vpFlags["MILITARY"] and info.type == 1 and info.flags["MILITARY"] then
                vp = vp + dev.vpFlags["MILITARY"]
            end
            if otherWorld and dev.vpFlags["WORLD"] and info.type == 1 then
                vp = vp + dev.vpFlags["WORLD"]
            end
            if otherUplift and dev.vpFlags["UPLIFT_FLAG"] and info.flags["UPLIFT"] then
                vp = vp + dev.vpFlags["UPLIFT_FLAG"]
            end

            -- development types
            local otherDev = true

            if dev.vpFlags["SIX_DEVEL"] and info.type == 2 and info.cost == 6 then
                otherDev = false
                vp = vp + dev.vpFlags["SIX_DEVEL"]
            end
            if dev.vpFlags["DEVEL_TRADE"] and info.type == 2 and info.passiveCount["4"] > 0 then
                vp = vp + dev.vpFlags["DEVEL_TRADE"]
            end
            if dev.vpFlags["DEVEL_CONSUME"] and info.type == 2 and info.activeCount["4"] > 0 then
                vp = vp + dev.vpFlags["DEVEL_CONSUME"]
            end
            if dev.vpFlags["DEVEL_EXPLORE"] and info.type == 2 and info.passiveCount["1"] > 0 then
                vp = vp + dev.vpFlags["DEVEL_EXPLORE"]
            end

            if otherDev and dev.vpFlags["DEVEL"] and info.type == 2 then
                vp = vp + dev.vpFlags["DEVEL"]
            end

            -- other card tag checks
            if otherAlien and dev.vpFlags["ALIEN_FLAG"] and info.flags["ALIEN"] then
                vp = vp + dev.vpFlags["ALIEN_FLAG"]
            end
        end

        -- name checks
        if dev.vpFlags["NAME"] then
            for _, entry in pairs(dev.vpFlags["NAME"]) do
                vp = vp + (cardNames[entry.name] and entry.vp or 0)
            end
        end

        -- other
        if dev.vpFlags["GOODS_REMAINING"] then
            vp = vp + goodsCount * dev.vpFlags["GOODS_REMAINING"]
        end
        if dev.vpFlags["THREE_VP"] then
            vp = vp + math.floor(vpChipCount / 3) * dev.vpFlags["THREE_VP"]
        end
        if dev.vpFlags["TOTAL_MILITARY"] then
            vp = vp + baseMilitary * dev.vpFlags["TOTAL_MILITARY"]
        end
        if dev.vpFlags["KIND_GOOD"] and uniqueWorldsCount > 0 then
            local amt = {1,3,6,10}
            vp = amt[uniqueWorldsCount]
        end

        displayVpHexOn(item[1], vp)

        devVp = devVp + vp
    end

    local statTracker = getObjectFromGUID(statTracker_GUID[i])
    if statTracker then
         statTracker.call("updateLabel", {"vp", flatVp + vpChipCount + devVp})
    end
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