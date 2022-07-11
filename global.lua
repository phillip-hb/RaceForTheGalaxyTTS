require("util")
require("cardtxt")
require("gameUi")

---1: starting hand, 0: select action. Otherwise, index of selectedPhases
currentPhaseIndex = -1
gameStarted = false
advanced2p = false
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
        miscSelectedCards = {},
        produceCount = {},
        paidCost = {},
        tempMilitary = 0,
        incomingGood = false,
        forcedReady = false
    }
end

playerData = {Yellow=player(1),Red=player(2),Blue=player(3),Green=player(4)}
queueUpdateState = {Yellow=false, Red=false, Blue=false, Green=false}
updateTimeSnapshot = {Yellow=0, Red=0, Blue=0, Green=0}

gameEndMessage = false

tradePowers = {["TRADE_ANY"]=1,["TRADE_THIS"]=1,["TRADE_NOVELTY"]=1,["TRADE_RARE"]=1,["TRADE_GENE"]=1,["TRADE_ALIEN"]=1}
settleActions = {
     ["DISCARD"]="Discard from hand.",
     ["PAY_MILITARY"]="Place military world as normal world.",
     ["MILITARY_HAND"]="Discard from hand.",
     ["REDUCE_ZERO"]="Reduce settle cost."
}
consumeActions = {
     ["TRADE_ACTION"]="Sell good.",
     ["CONSUME_ANY"]="Consume any good.",
     ["CONSUME_NOVELTY"]="Consume Novelty good.",
     ["CONSUME_RARE"]="Consume Rare good.",
     ["CONSUME_GENE"]="Consume Genes good.",
     ["CONSUME_ALIEN"]="Consume Alien good.",
     ["CONSUME_3_DIFF"]="Consume 3 different goods.",
     ["CONSUME_ALL"]="Consume all goods.",
     ["DISCARD_HAND"]="Discard from hand.",
     ["DRAW"]="Draw card(s).",
     ["ANTE_CARD"]="Gamble draw.",
     ["DRAW_LUCKY"]="Gamble draw."
}
produceActions = {
     ["DRAW"]="Draw card(s)",
     ["WINDFALL_ANY"]="Produce good on any windfall world.",
     ["WINDFALL_NOVELTY"]="Produce good on Novelty windfall world.",
     ["WINDFALL_RARE"]="Produce good on Rare windfall world.",
     ["WINDFALL_GENE"]="Produce good on Genes windfall world.",
     ["WINDFALL_ALIEN"]="Produce good on Alien windfall world.",
     ["DRAW_WORLD_GENE"]="Draw 1 card for each Genes world in tableau.",
     ["DRAW_EACH_NOVELTY"]="Draw 1 card for each Novelty good you produced.",
     ["DRAW_EACH_ALIEN"]="Draw 1 card for each Alien good you produced.",
     ["DRAW_DIFFERENT"]="Draw 1 card for each kind of good you produced.",
     ["DISCARD"]="Discard from hand.",
}
requiresGoods = {["TRADE_ACTION"]=1,["CONSUME_ANY"]=1,["CONSUME_NOVELTY"]=1,["CONSUME_RARE"]=1,["CONSUME_GENE"]=1,["CONSUME_ALIEN"]=1,["CONSUME_3_DIFF"]=1,["CONSUME_ALL"]=1}
goodsHighlightColor = {
     ["NOVELTY"] = color(0.345, 0.709, 0.974),
     ["RARE"] = color(0.709, 0.407, 0.129),
     ["GENE"] = color(0.278, 0.760, 0.141),
     ["ALIEN"] = color(0.933, 0.909, 0.105),
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
mustConsumeGoodsCount = {0,0,0,0}

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
    end

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
        -- updateHandState(color)
        -- savePowersSnapshot(color, tostring(getCurrentPhase()))
        -- updateTableauState(color)
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

function countTrait(player, trait, name)
     local count = 0
     for card in allCardsInTableau(player) do
          if card.hasTag("Action Card") == false then
               local info = cardData[card.getName()]
               if trait == "goods" and info[trait] == name or
                    trait ~= "goods" and info[trait][name] then
                    count = count + 1
               end
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
     local info = cardData[card.getName()]
     local powers = info.powers["5"]
     --local produce = getPower(powers, "PRODUCE")

     --if produce then
          local goods = getGoods(card)
          if not goods then
               -- no goods, produce on planet
               playerData[player].produceCount[info.goods] = playerData[player].produceCount[info.goods] + 1
               card.memo = placeGoodsAt(card.positionToWorld(goodsSnapPointOffset), card.getRotation()[2], player)

               local drawIf = getPower(powers, "DRAW_IF")
               if drawIf then
                    dealTo(drawIf.strength, player)
               end

               return true
          end
     --end

     return false
end

function getVpChips(player, n)
     if not vpBag then
          vpBag = getObjectFromGUID(vpPoolBag_GUID)
     end

     local ind = playerColorIndex[player]
     local tableau = getObjectFromGUID(tableau_GUID[ind])

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
     local i = playerColorIndex[player]
     local zone = getObjectFromGUID(selectedActionZone_GUID[i])

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

     --           playerData[player].miscSelectedCards = deleteLinkedListNode(playerData[player].miscSelectedCards, leave_object.getGUID())
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
          -- for _, zone in pairs(container.getZones()) do
          --      local owner = tableauZoneOwner[zone.getGUID()]
          --      if owner then
          --           updateTableauState(owner)
          --           return
          --      end
          -- end
     end
end

function onObjectLeaveContainer(container, leave_object)
     if container.hasTag("VP") then
          -- for _, zone in pairs(container.getZones()) do
          --      local owner = tableauZoneOwner[zone.getGUID()]
          --      if owner then
          --           updateTableauState(owner)
          --           return
          --      end
          -- end
     end
end

function onUpdate()
     for player, willUpdate in pairs(queueUpdateState) do
          if willUpdate and os.clock() > updateTimeSnapshot[player] + 0.2 then
               queueUpdateState[player] = false
               capturePowersSnapshot(player, tostring(getCurrentPhase()))
               updateHandState(player)
               updateTableauState(player)
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
-- UI
-- ======================

-- function uiSetVisibilityToPlayer(id, playerColor, visible)
--      local attr = UI.getAttribute(id, "visibility")
--      if visible then
--           attr = attr .. "|" .. playerColor
--      else
--           local newAttr = ""
--           tokens = split(attr, "|")
--
--           for i=1, #tokens do
--                if tokens[i] ~= playerColor then
--                     newAttr = newAttr .. tokens[i] .. "|"
--                end
--           end
--
--           if newAttr == "" then
--                attr = "Brown"
--           else
--                attr = newAttr:sub(1, newAttr:len() - 1)
--           end
--      end
--
--      UI.setAttribute(id, "visibility", attr)
-- end
--
-- function closeHelpClick(player, button)
--      if button == "-1" then
--           uiSetVisibilityToPlayer("helpWindow", player.color, false)
--      end
-- end
--
-- function showHelpClick(player, button)
--      if button == "-1" then
--           uiSetVisibilityToPlayer("helpWindow", player.color, true)
--      end
-- end

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
     local i = playerData[params[1]].index
     getObjectFromGUID(readyTokens_GUID[i]).call("setToggleState", params[2])
     getObjectFromGUID(smallReadyTokens_GUID[i]).call("setToggleState", params[2])
end

function checkAllReadyCo()
    -- Check if all players are ready to move on to next step of game
    local players = getSeatedPlayersWithHands()

    for _, player in pairs(players) do
        local readyToken = getObjectFromGUID(readyTokens_GUID[playerData[player].index])
        if not readyToken.getVar("isReady") then return 1 end
        setHelpText(player, "")
    end

    -- remove misc selected cards if they have discard power
    local discardHappened = false
    local phase = getCurrentPhase()

    --  for i=1, #players do
    --       local node = playerData[players[i]].miscSelectedCards
    --       while node and node.value do
    --            local card = getObjectFromGUID(node.value)
    --            if phase == 3 then
    --                 local actions = getCardActions("3", card)
    --                 local power = getPower(actions, "DISCARD")
    --                 if power then
    --                      discardCard(card)
    --                      discardHappened = true
    --                 end
    --            end

    --            node = node.next
    --       end

    --       playerData[players[i]].miscSelectedCards = {}
    --  end

    --  if discardHappened then wait(0.05) end

     -- play selected cards in hand
    for _, player in pairs(players) do
        for _, obj in pairs(Player[player].getHandObjects(1)) do
            if obj.type == 'Card' and obj.hasTag("Selected") then
                attemptPlayCard(obj, player)
            elseif not phase and obj.hasTag("Explore Highlight") then
                -- discard not selected starting homeworld
                discardCard(obj)
            end
        end

        -- discard all face down cards in hand
        discardMarkedCards(player)
        playerData[player].selectedCard = nil
    end

    wait(0.1)

    for _, player in pairs(players) do
        updateReadyButtons({player, false})
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
    --            if playerSelectedPhases["DevelopAdv2p"] and not playerSelectedPhases["Develop"] then
    --                 playerSelectedPhases["DevelopAdv2p"] = nil
    --                 playerSelectedPhases["Develop"] = true
    --            end

    --            if playerSelectedPhases["SettleAdv2p"] and not playerSelectedPhases["Settle"] then
    --                 playerSelectedPhases["SettleAdv2p"] = nil
    --                 playerSelectedPhases["Settle"] = true
    --            end

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

        table.sort(selectedPhases)

        currentPhaseIndex = -1000

        wait(1.2)

        startLuaCoroutine(self, "beginNextPhase")
    elseif currentPhaseIndex >= 1 then
        if currentPhaseIndex > #selectedPhases then
            -- round end check
        else
            startLuaCoroutine(self, "beginNextPhase")
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
        data.phasePowersSnapshot = {}
        data.selectedCard = nil
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
    -- if getCurrentPhase() == 5 then
    --     local tie = false
    --     local most = {["RARE"]=nil}
    --     for player, i in pairs(playerColorIndex) do
    --         if not most["RARE"] or playerData[player].produceCount["RARE"] > playerData[most["RARE"]].produceCount["RARE"]  then
    --             tie = false
    --             most["RARE"] = player
    --         elseif playerData[player].produceCount["RARE"] == playerData[most["RARE"]].produceCount["RARE"] then
    --             tie = true
    --         end
    --     end

    --     for player, data in pairs(playerData) do
    --         if data.phasePowersSnapshot["DRAW_MOST_RARE"] then
    --             if tie or most["RARE"] ~= player then
    --                     broadcastToColor("Mining Conglomerate: Did not produce most Rare goods this phase.", player, "Black")
    --             elseif most["RARE"] == player then
    --                     broadcastToColor("Mining Conglomerate: Produced most Rare goods this phase.", player, player)
    --                     dealTo(data.phasePowersSnapshot["DRAW_MOST_RARE"], player)
    --             end
    --         end
    --     end
    -- end

    currentPhaseIndex = currentPhaseIndex + 1
    
    -- Init player data at start of phase
    for player, data in pairs(playerData) do
        data.miscSelectedCards = {}
        data.paidCost = {}
        data.forcedReady = false
        data.incomingGood = false
    end

     updatePhaseTilesHighlight()

    if currentPhaseIndex <= #selectedPhases then
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
    else
        -- end of round
        startNewRound()
    end

    for player, data in pairs(playerData) do
        queueUpdate(player, true)
    end

    return 1
end

function updatePhaseTilesHighlight()
    phaseTilesHighlightOff()

    local phase = selectedPhases[currentPhaseIndex]
    if phase then
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
        --data.cardsAlreadyUsed = {}
        --data.miscSelectedCards = {}

        capturePowersSnapshot(player, "3")

        updateHandState(player)
        updateHelpText(player)
    end
end

function startConsumePhase()
     -- for player, data in pairs(playerData) do
     --      data.cardsAlreadyUsed = {}
     --      savePowersSnapshot(player, "4")

     --      -- Force first selection choice to be the consume trade card, otherwise it'll be nil
     --      local card = checkIfSelectedAction(player, "Consume ($)")
     --      if card then
     --           data.selectedCard = card.getGUID()
     --      end

     --      updateTableauState(player)
     --      updateHandState(player)
     -- end
end

function startProducePhase()
     -- for player, data in pairs(playerData) do
     --      data.cardsAlreadyUsed = {}
     --      data.produceCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0}
     --      savePowersSnapshot(player, "5")

     --      -- produce on production planets first
     --      for card in allCardsInTableau(player) do
     --           local info = cardData[card.getName()]

     --           if info.powers["5"] then
     --                local produce = getPower(info.powers["5"], "PRODUCE")
     --                if produce then
     --                     tryProduceAt(player, card)
     --                end
     --           end
     --      end

     --      -- Force first selection choice to be the consume trade card, otherwise it'll be nil
     --      local card = checkIfSelectedAction(player, "Produce")
     --      if card then
     --           data.selectedCard = card.getGUID()
     --           data.selectedCardPowerIndex = 1
     --      end

     --      updateTableauState(player)
     --      updateHandState(player)
     -- end
end

-- phase = (string) current phase
function capturePowersSnapshot(player, phase)
    local p = playerData[player]
    local selectedCard = getObjectFromGUID(p.selectedCard)

    if phase == "nil" then
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
    elseif phase == "3" then
        results["EXTRA_MILITARY"] = 0
    end

    local ignore2ndDevelop = false
    local ignore2ndSettle = false
    local chromoCount = 0
    local tradeChromoBonus = false

    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]

        if info.passivePowers[phase] then
            local powers = info.passivePowers[phase]
            for i, power in pairs(powers) do
                if not results[power.name] then
                    results[power.name] = 0
                end

                -- count certain powers only in specific cases
                if phase == "2" then
                    if advanced2p and card.getName() == "Develop" then
                        if ignore2ndDevelop then goto skip_add end
                        ignore2ndDevelop = true
                    end
--                     elseif phase == "3" then
--                          if advanced2p and card.getName() == "Settle" then
--                               if ignore2ndSettle then
--                                    goto skip_add
--                               end
--                               ignore2ndSettle = true
--                          end

--                          if power.name == "EXTRA_MILITARY" then
--                               local powerCodes = power.codes

--                               if powerCodes["AGAINST_REBEL"] and (selected and cardData[selected.getName()].flags["REBEL"]) or
--                                  selected and powerCodes[cardData[selected.getName()].goods or ""] then
--                                    -- match
--                               elseif tableLength(powerCodes) > 0 then
--                                    goto skip_add
--                               end
--                          elseif power.name == "REDUCE" then
--                               local powerCodes = power.codes

--                               if selected and powerCodes[cardData[selected.getName()].goods or ""] then
--                                    -- match
--                               elseif tableLength(powerCodes) > 0 then
--                                    goto skip_add
--                               end
--                          end
                end

                results[power.name] = results[power.name] + power.strength

                if power.name == "TRADE_GENE" and power.codes["TRADE_BONUS_CHROMO"] then
                    tradeChromoBonus = true
                end

                ::skip_add::
            end
        end

        if info.flags["CHROMO"] then
            chromoCount = chromoCount + 1
        end
    end

    if tradeChromoBonus then
        results["TRADE_GENE"] = results["TRADE_GENE"] + chromoCount
    end

    playerData[player].powersSnapshot = results
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
            if not p.selectedCard then
                createSelectButtonOnCard(obj)
            elseif p.selectedCard == obj.getGUID() then
                createCancelButtonOnCard(obj)
            end
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
    -- local selectedGoods = playerData[player].selectedGoods
    -- local selectedPowerIndex = playerData[player].selectedCardPowerIndex
    -- local cardsAlreadyUsed = playerData[player].cardsAlreadyUsed

    -- local windfallCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    -- local goodsCount = {["NOVELTY"]=0,["RARE"]=0,["GENE"]=0,["ALIEN"]=0,["TOTAL"]=0}
    -- local uniques = {}

     -- local selectedUniqueGoods = {}

    for card in allCardsInTableau(player) do
        card.clearButtons()
        card.highlightOff()
        highlightOff(card)
    end

     -- for guid, selected in pairs(selectedGoods) do
     --      if selected then
     --           local good = getObjectFromGUID(guid)
     --           local parent = getObjectFromGUID(good.getDescription())

     --           selectedUniqueGoods[cardData[parent.getName()].goods] = true
     --      end
     -- end

     -- local miscPowerSnapshot = {}
     -- local miscCodeSnapshot = {}
     -- local miscSelectedCardsTable = {}
     -- local list = playerData[player].miscSelectedCards

     -- while list and list.value do
     --      miscSelectedCardsTable[list.value] = true
     --      local card = getObjectFromGUID(list.value)
     --      local info = cardData[card.getName()]
     --      for name, powerInfo in pairs(info.powers[tostring(getCurrentPhase())]) do
     --           miscPowerSnapshot[name] = true
     --           for codeName, _ in pairs(powerInfo.codes) do
     --                miscCodeSnapshot[codeName] = true
     --           end
     --      end

     --      list = list.next
     -- end

    -- count certain cards, highlight goods, etc
    for _, obj in pairs(zone.getObjects()) do
        if obj.hasTag("Slot") then obj.clearButtons() end

        if obj.type == 'Card' and not obj.is_face_down then
            local parentData = card_db[obj.getName()]

            -- if parentData.flags["WINDFALL"] and not getGoods(obj) then
            --     windfallCount[parentData.goods] = windfallCount[parentData.goods] + 1
            --     windfallCount["TOTAL"] = windfallCount["TOTAL"] + 1
            -- end
        elseif obj.type == 'Card' and obj.is_face_down and obj.getDescription() ~= "" then  -- facedown goods on tableau
            local parentCard = getObjectFromGUID(obj.getDescription())
            local parentData = card_db[parentCard.getName()]

            if #parentCard.getZones() <= 0 then
                obj.setDescription("")
            elseif parentData.goods then
                obj.highlightOn(goodsHighlightColor[parentData.goods])

                -- goodsCount[parentData.goods] = goodsCount[parentData.goods] + 1
                -- uniques[parentData.goods] = 1
                -- goodsCount["TOTAL"] = goodsCount["TOTAL"] + 1

    --                -- create buttons on cards based on action
    --                if getCurrentPhase() == 4 and selectedCard and selectedInfo.powers["4"] then
    --                     if selectedInfo.powers["4"][selectedPowerIndex].name == "TRADE_ACTION" then
    --                          -- calculating cost to sell card
    --                          local price = 0
    --                          local bonus = true

    --                          if selectedInfo.powers["4"][selectedPowerIndex].codes["TRADE_NO_BONUS"] then
    --                               bonus = false
    --                          end

    --                          if parentData.goods == "NOVELTY" then
    --                               price = 2 + (bonus and phasePowersSnapshot["TRADE_NOVELTY"] or 0)
    --                          elseif parentData.goods == "RARE" then
    --                               price = 3 + (bonus and phasePowersSnapshot["TRADE_RARE"] or 0)
    --                          elseif parentData.goods == "GENE" then
    --                               price = 4 + (bonus and phasePowersSnapshot["TRADE_GENE"] or 0)
    --                          elseif parentData.goods == "ALIEN" then
    --                               price = 5 + (bonus and phasePowersSnapshot["TRADE_ALIEN"] or 0)
    --                          end

    --                          if bonus and parentData.powers["4"] and parentData.powers["4"]["TRADE_THIS"] then
    --                               price = price + parentData.powers["4"]["TRADE_THIS"].strength
    --                          end

    --                          price = price + (bonus and phasePowersSnapshot["TRADE_ANY"] or 0)
    --                          createGoodsButton(parentCard, "$➧" .. price)

    --                          obj.memo = price
    --                     else -- using normal consume powers
    --                          local makeButton = false
    --                          local power = selectedInfo.powers["4"][selectedPowerIndex]

    --                          if power.name == "CONSUME_ANY" or power.name == "CONSUME_ALL" or "CONSUME_" .. parentData.goods == power.name or
    --                             ((power.name == "CONSUME_3_DIFF" and not selectedUniqueGoods[parentData.goods]) or (selectedGoods[i] and selectedGoods[i][obj.getGUID()])) then
    --                               makeButton = true
    --                          end

    --                          if power.codes["CONSUME_THIS"] and selectedCard ~= parentCard then
    --                               makeButton = false
    --                          end

    --                          if makeButton then
    --                               local check = "✔"
    --                               if not selectedGoods[obj.getGUID()] then
    --                                    check = ""
    --                               end

    --                               createGoodsButton(parentCard, check)
    --                          end
    --                     end
    --                end
            end
        end
    end

     -- local uniqueCount = tableLength(uniques)
     -- mustConsumeGoodsCount[i] = 0
     -- possibleTableauActions[player] = {}

     -- -- Auto cancel certain cards
     -- if getCurrentPhase() == 4 and selectedCard and selectedCard.getName() == "Consume ($)" and goodsCount["TOTAL"] == 0 and incomingGood[i] == false
     --      or getCurrentPhase() == 5 and selectedCard and selectedCard.getName() == "Produce" and windfallCount["TOTAL"] <= 0 then
     --      selectedCard = nil
     --      selectedInfo = nil
     --      playerData[player].selectedCard = nil
     -- end

    local baseMilitary = 0
     -- local createdButton = false

    -- refresh state on all cards in tableau
    for card in allCardsInTableau(player) do
        local info = card_db[card.getName()]
        if not card.hasTag("Action Card") then
            if info.passivePowers["3"] then
                local mil = info.passivePowers["3"]["EXTRA_MILITARY"]
                if mil and not mil.codes["NOVELTY"] and next(mil.codes) == nil then
                    baseMilitary = baseMilitary + mil.strength
                end
            end

     --           if getCurrentPhase() == 3 then
     --                if miscSelectedCardsTable[card.getGUID()] then
     --                     highlightOn(card, "rgb(0,1,0)", player)
     --                end

     --                local actions = getCardActions("3", card)
     --                if actions and selectedCard then
     --                     for _, action in pairs(actions) do
     --                          if miscSelectedCardsTable[card.getGUID()] then
     --                               createCardTopButton(card, "Cancel", "cancelSettlePowerClick", "Cancel power.")
     --                               if action.name == "MILITARY_HAND" then
     --                                    createCardBottomButton(card, "Confirm", "confirmSettlePowerClick")
     --                               end
     --                               break
     --                          elseif action.data.codes["REDUCE_ZERO"] and not selectedInfo.flags["ALIEN"] and (not selectedInfo.flags["MILITARY"] or miscPowerSnapshot["PAY_MILITARY"])    -- colony ship
     --                               or action.data.codes["EXTRA_MILITARY"] and selectedInfo.flags["MILITARY"] and not miscPowerSnapshot["PAY_MILITARY"]     -- new military tactics
     --                               or action.name == "PAY_MILITARY" and selectedInfo.flags["MILITARY"] and not selectedInfo.flags["ALIEN"] and not miscCodeSnapshot["EXTRA_MILITARY"]
     --                               or action.name == "MILITARY_HAND" and selectedInfo.flags["MILITARY"] -- space mercenaries
     --                               then
     --                               createCardTopButton(card, "Use Power", "useSettlePowerClick", settleActions[action.name] or "")
     --                               createdButton = true
     --                               break
     --                          end
     --                     end
     --                end
     --           elseif getCurrentPhase() == 4 and info.powers["4"] then
     --                local baseAmount = 1
     --                local goodslimit = 1
     --                local enoughGoods = false

     --                if selectedCard then
     --                     selectedCard.highlightOn(color(0,1,0))
     --                end

     --                -- Based on powers, set certain flags or variables
     --                local actions = getCardActions("4", card)
     --                if actions then
     --                     for _, action in pairs(actions) do
     --                          if action.data.times > 0 then
     --                               if action.name == "CONSUME_ANY" or action.name == "CONSUME_ALL" or action.name == "CONSUME_3_DIFF" then
     --                                    goodslimit = goodsCount["TOTAL"]
     --                               elseif action.name == "CONSUME_NOVELTY" then
     --                                    goodslimit = goodsCount["NOVELTY"]
     --                               elseif action.name == "CONSUME_RARE" then
     --                                    goodslimit = goodsCount["RARE"]
     --                               elseif action.name == "CONSUME_GENE" then
     --                                    goodslimit = goodsCount["GENE"]
     --                               elseif action.name == "CONSUME_ALIEN" then
     --                                    goodslimit = goodsCount["ALIEN"]
     --                               end

     --                               if action.data.codes["CONSUME_TWO"] then
     --                                    baseAmount = 2
     --                               elseif action.name == "CONSUME_ALL" then
     --                                    baseAmount = goodsCount["TOTAL"]
     --                               elseif action.name == "CONSUME_3_DIFF" then
     --                                    baseAmount = 3
     --                               end

     --                               goodslimit = math.min(action.data.times * baseAmount, goodslimit)

     --                               -- set base amount to high value so button doesn't get created for this specific power
     --                               if action.name == "CONSUME_3_DIFF" and uniqueCount < 3 then
     --                                    baseAmount = 100
     --                               end
     --                               break
     --                          else
     --                               if action.name == "TRADE_ACTION" then
     --                                    goodslimit = goodsCount["TOTAL"]
     --                                    break
     --                               end

     --                               goodslimit = math.min(baseAmount, goodslimit)
     --                          end
     --                     end
     --                end

     --                if not selectedCard then
     --                     -- create buttons for cards with consume powers
     --                     local powerCount = 0
     --                     local actualIndex = {}
     --                     for i, action in pairs(actions) do
     --                          if consumeActions[action.name] then
     --                               powerCount = powerCount + 1
     --                               actualIndex[#actualIndex + 1] = i
     --                          end
     --                     end

     --                     if actions and powerCount == 1 then
     --                          local action = actions[actualIndex[1]]
     --                          if (not playerData[player].cardsAlreadyUsed[card.getGUID()] or not playerData[player].cardsAlreadyUsed[card.getGUID()][actualIndex[1]]) and
     --                             (not requiresGoods[action.name] or baseAmount <= goodslimit) then
     --                               createCardTopButton(card, "Use Power", "cardSelectClick" .. actualIndex[1], consumeActions[action.name])
     --                               createdButton = true
     --                          end
     --                     elseif actions and powerCount == 2 then
     --                          local func = {"cardSelectClick" .. actualIndex[1], "cardSelectClick" .. actualIndex[2]}
     --                          for i=1, #actions do
     --                               if playerData[player].cardsAlreadyUsed[card.getGUID()] and playerData[player].cardsAlreadyUsed[card.getGUID()][actualIndex[2]] then
     --                                    func[i] = "none"
     --                               end
     --                          end
     --                          createCardTop2Buttons(card, "Pow", func, {consumeActions[actions[1].name], consumeActions[actions[2].name]})
     --                     end
     --                elseif selectedCard == card then
     --                     createCardTopButton(selectedCard, "Cancel", "cancelPowerClick", "Cancel power.")

     --                     if actions[selectedPowerIndex].name == "DISCARD_HAND" then
     --                          createCardBottomButton(selectedCard, "Confirm", "confirmConsumePowerClick")
     --                     end

     --                     mustConsumeGoodsCount[i] = math.max(baseAmount, goodslimit)
     --                end
     --           elseif getCurrentPhase() == 5 then
     --                local actions = getCardActions("5", card)

     --                if selectedCard then
     --                     selectedCard.highlightOn(color(0,1,0))
     --                end

     --                if not selectedCard and actions then
     --                     local needsSpace = false

     --                     for _, action in pairs(actions) do
     --                          if 
     --                          (action.name == "DISCARD" and 
     --                               ((action.data.codes["WINDFALL_ANY"] and windfallCount["TOTAL"] <= 0) or
     --                                (action.data.codes["PRODUCE"] and getGoods(card)))) or
     --                          (action.name == "WINDFALL_ANY" and windfallCount["TOTAL"] <= 0) or
     --                          (action.name == "WINDFALL_NOVELTY" and windfallCount["NOVELTY"] <= 0) or
     --                          (action.name == "WINDFALL_RARE" and windfallCount["RARE"] <= 0) or
     --                          (action.name == "WINDFALL_GENE" and windfallCount["GENE"] <= 0) or
     --                          (action.name == "WINDFALL_ALIEN" and windfallCount["ALIEN"] <= 0) then
     --                               needsSpace = true
     --                               break
     --                          end
     --                     end

     --                     if actions and #actions == 1 then
     --                          if (not playerData[player].cardsAlreadyUsed[card.getGUID()] or not playerData[player].cardsAlreadyUsed[card.getGUID()][1]) and needsSpace == false then
     --                               createCardTopButton(card, "Use Power", "cardSelectClick1", produceActions[actions[1].name])
     --                               createdButton = true
     --                          end
     --                     elseif actions and #actions == 2 then

     --                     end
     --                elseif selectedCard == card then
     --                     local paidCost = playerData[player].paidCost[card.getGUID()]
     --                     if paidCost and paidCost[playerData[player].selectedCardPowerIndex] then
                              
     --                     else
     --                          createCardTopButton(card, "Cancel", "cancelPowerClick")

     --                          if actions[selectedPowerIndex].name == "DISCARD" then
     --                               createCardBottomButton(selectedCard, "Confirm", "confirmProducePowerClick")
     --                          end
     --                     end
     --                end

     --                -- create produce here button for windfall planets
     --                if selectedCard then
     --                     local selectedAction = getCardActions("5", selectedCard)[playerData[player].selectedCardPowerIndex]
     --                     local action = selectedAction.name

     --                     -- doing some special stuff here if needed
     --                     if selectedAction and selectedAction.name == "DISCARD" and selectedAction.data.codes["WINDFALL_ANY"] and 
     --                          playerData[player].paidCost[selectedCard.getGUID()] and playerData[player].paidCost[selectedCard.getGUID()][playerData[player].selectedCardPowerIndex] then
     --                          action = "WINDFALL_ANY"
     --                     end

     --                     if selectedAction and info.goods and info.flags["WINDFALL"] and not getGoods(card) and
     --                     (action == "WINDFALL_ANY" or
     --                     action == "WINDFALL_NOVELTY" and info.goods == "NOVELTY" or
     --                     action == "WINDFALL_RARE" and info.goods == "RARE" or
     --                     action == "WINDFALL_GENE" and info.goods == "GENE" or
     --                     action == "WINDFALL_ALIEN" and info.goods == "ALIEN")
     --                     then
     --                          createGoodsButton(card, "▼", color(1, 1, 1, 0.9))
     --                     end
     --                end
     --           end
        end
    end

     -- -- Force the player ready when they have nothing left to do
     -- if (getCurrentPhase() == 4 or getCurrentPhase() == 5) and forcedReady[i] == false and createdButton == false and not selectedCard and incomingGood[i] == false then
     --      forcedReady[i] = true
     --      local token = getObjectFromGUID(readyTokens_GUID[i])
     --      if token then
     --           token.call("setToggleState", true)
     --           playerReadyClicked(player)
     --      end
     --      token = getObjectFromGUID(smallReadyTokens_GUID[i])
     --      if token then
     --           token.call("setToggleState", true)
     --      end
     -- end

    local statTracker = getObjectFromGUID(statTracker_GUID[i])
    if statTracker then
        statTracker.call("updateLabel", {"military", baseMilitary})
    end

     -- calculateVp(player)
end

function cancelPowerClick(card, player, rightClick)
     -- if rightClick then return end

     -- playerData[player].selectedCard = nil
     -- updateTableauState(player)
end

function confirmSettlePowerClick(card, player, rightClick)
     -- if rightClick then return end

     -- local pd = playerData[player]

     -- if card.hasTag("Slot") then card = getCard(card) end

     -- local actions = getCardActions("3", card)
     -- local action = actions[pd.selectedCardPowerIndex]

     -- log(pd.selectedCardPowerIndex)
     -- if action.name == "MILITARY_HAND" then
     --      local times = math.min(action.data.strength, discardMarkedCards(player))

     -- end

     -- if not pd.cardsAlreadyUsed[pd.selectedCard] then
     --      local emptyArr = {}
     --      for i=1, #actions do
     --           emptyArr[i] = false
     --      end
     --      pd.cardsAlreadyUsed[pd.selectedCard] = emptyArr
     -- end

     -- pd.cardsAlreadyUsed[pd.selectedCard][pd.selectedCardPowerIndex] = true
     -- pd.selectedCard = nil
     -- card.clearButtons()

     -- updateTableauState(player)
end

function confirmConsumePowerClick(card, player, rightClick)
     -- if rightClick then return end

     -- local pd = playerData[player]

     -- if card.hasTag("Slot") then card = getCard(card) end

     -- local actions = getCardActions("4", card)
     -- local action = actions[pd.selectedCardPowerIndex]

     -- if action.name == "DISCARD_HAND" then
     --      local times = math.min(action.data.times, discardMarkedCards(player))
     --      if action.data.codes["GET_VP"] then
     --           getVpChips(player, times)
     --      end
     -- end

     -- if not pd.cardsAlreadyUsed[pd.selectedCard] then
     --      local emptyArr = {}
     --      for i=1, #actions do
     --           emptyArr[i] = false
     --      end
     --      pd.cardsAlreadyUsed[pd.selectedCard] = emptyArr
     -- end

     -- pd.cardsAlreadyUsed[pd.selectedCard][pd.selectedCardPowerIndex] = true
     -- pd.selectedCard = nil
     -- card.clearButtons()

     -- updateTableauState(player)
end

function confirmProducePowerClick(card, player, rightClick)
     -- if rightClick then return end

     -- local pd = playerData[player]

     -- if card.hasTag("Slot") then card = getCard(card) end

     -- local actions = getCardActions("5", card)
     -- local action = actions[pd.selectedCardPowerIndex]

     -- if action.name == "DISCARD" then
     --      discardMarkedCards(player)
     --      if action.data.codes["WINDFALL_ANY"] then
     --           if not pd.paidCost[card.getGUID()] then
     --                pd.paidCost[card.getGUID()] = {false,false}
     --           end

     --           pd.paidCost[card.getGUID()][pd.selectedCardPowerIndex] = true
     --           updateTableauState(player)
     --           return
     --      elseif action.data.codes["PRODUCE"] then
     --           tryProduceAt(player, card)
     --      end
     -- end

     -- if not pd.cardsAlreadyUsed[pd.selectedCard] then
     --      local emptyArr = {}
     --      for i=1, #actions do
     --           emptyArr[i] = false
     --      end
     --      pd.cardsAlreadyUsed[pd.selectedCard] = emptyArr
     -- end

     -- pd.cardsAlreadyUsed[pd.selectedCard][pd.selectedCardPowerIndex] = true
     -- pd.selectedCard = nil
     -- card.clearButtons()

     -- updateTableauState(player)
end

function selectGoodsClick(parentCard, player, rightClick)
     -- if rightClick then return end

     -- local i = playerColorIndex[player]
     -- local info = cardData[parentCard.getName()]
     -- local pd = playerData[player]
     -- local selectedCard = getObjectFromGUID(pd.selectedCard)
     -- local powerIndex = pd.selectedCardPowerIndex

     -- if getCurrentPhase() == 4 then    -- consume the goods card
     --      local card = getGoods(parentCard)
     --      local selectedGoods = pd.selectedGoods
     --      local actions = getCardActions("4", selectedCard)
     --      local action = actions[powerIndex]

     --      if card == nil then
     --           broadcastToColor("Invalid goods selected.", player, "Red")
     --      end

     --      selectedGoods[card.getGUID()] = not selectedGoods[card.getGUID()]

     --      local selectedGoodsCount = 0
     --      for _, v in pairs(selectedGoods) do
     --           if v then
     --                selectedGoodsCount = selectedGoodsCount + 1
     --           end
     --      end

     --      if selectedGoodsCount >= mustConsumeGoodsCount[i] then
     --           local vpMultiplier = 1
     --           if playerData[player].phasePowersSnapshot["DOUBLE_VP"] ~= nil then
     --                vpMultiplier = 2
     --           end

     --           local times = 1

     --           if action.name == "TRADE_ACTION" then
     --                times = 0
     --                local price = card.memo
     --                dealTo(price, player)
     --           elseif action.name == "CONSUME_ALL" then
     --                times = selectedGoodsCount - 1
     --           elseif selectedGoodsCount <= action.data.times then
     --                times = selectedGoodsCount
     --           end

     --           for a=1, times do
     --                if action.data.codes["GET_VP"] then
     --                     getVpChips(player, action.data.strength * vpMultiplier)
     --                end
     --                if action.data.codes["GET_CARD"] then
     --                     dealTo(action.data.strength, player)
     --                end
     --                if action.data.codes["GET_2_CARD"] then
     --                     dealTo(action.data.strength * 2, player)
     --                end
     --                if action.data.codes["GET_3_CARD"] then
     --                     dealTo(action.data.strength * 3, player)
     --                end
     --           end

     --           for guid, v in pairs(selectedGoods) do
     --                local goodsCard = getObjectFromGUID(guid)
     --                discardCard(goodsCard)
     --           end

     --           -- some initializations if needed
     --           local cardsUsed = pd.cardsAlreadyUsed
     --           if not cardsUsed[selectedCard.getGUID()] then
     --                cardsUsed[selectedCard.getGUID()] = {}
     --                for i=1, #actions do
     --                     cardsUsed[selectedCard.getGUID()][i] = false
     --                end
     --           end

     --           pd.selectedGoods = {}
     --           pd.cardsAlreadyUsed[selectedCard.getGUID()][powerIndex] = true
     --           pd.selectedCard = nil
     --      end
     -- elseif getCurrentPhase() == 5 then     -- produce the goods card
     --      local actions = getCardActions("5", selectedCard)
     --      local action = actions[powerIndex]
     --      -- local card = placeGoodsAt(parentCard.positionToWorld(goodsSnapPointOffset), parentCard.getRotation()[2], player)

     --      -- pd.produceCount[info.goods] = pd.produceCount[info.goods] + 1
     --      -- parentCard.memo = card.getGUID()

     --      -- if action.name == "DRAW_IF" then
     --      --      dealTo(action.data.strength, player)
     --      -- end
     --      tryProduceAt(player, parentCard)

     --      local cardsUsed = pd.cardsAlreadyUsed
     --      if not cardsUsed[selectedCard.getGUID()] then
     --           cardsUsed[selectedCard.getGUID()] = {}
     --           for i=1, #actions do
     --                cardsUsed[selectedCard.getGUID()][i] = false
     --           end
     --      end

     --      pd.cardsAlreadyUsed[selectedCard.getGUID()][powerIndex] = true
     --      pd.selectedCard = nil
     -- end

     -- updateTableauState(player)
end

function useSettlePowerClick(card, player, button)
     -- if button then
     --      return
     -- end

     -- if card.hasTag("Slot") then
     --      card = getCard(card)
     -- end

     -- local selectedCard = getObjectFromGUID(playerData[player].selectedCard)
     -- local selectedInfo = cardData[selectedCard.getName()]
     -- local node = playerData[player].miscSelectedCards

     -- while node and node.next do
     --      node = node.next
     -- end

     -- if not playerData[player].miscSelectedCards.value then
     --      playerData[player].miscSelectedCards = {value = card.getGUID(), next = nil}
     -- else
     --      node.next = {value = card.getGUID(), next = nil}
     -- end

     -- updateTableauState(player)
end

function cancelSettlePowerClick(card, player, btn)
     -- if btn then
     --      return
     -- end

     -- if card.hasTag("Slot") then
     --      card = getCard(card)
     -- end

     -- playerData[player].miscSelectedCards = deleteLinkedListNode(playerData[player].miscSelectedCards, card.getGUID())

     -- updateTableauState(player)
end

function cardSelectClick(object, player, rightClick, powerIndex)
     if rightClick then return end

     if object.hasTag("Slot") then
          object = getCard(object)
     end

     local p = playerData[player]
     local i = p.index
     local skip = false

     if not getCurrentPhase() then
          
     -- elseif getCurrentPhase() == 4 then
     --      local powers = cardData[object.getName()].powers["4"]
     --      -- check for instant effects
     --      local draw = getPower(powers, "DRAW")
     --      if draw then
     --           dealTo(draw.strength, player)
     --           skip = true
     --      end
     -- elseif getCurrentPhase() == 5 then
     --      local powers = cardData[object.getName()].powers["5"]
     --      for _, power in pairs(powers) do
     --           -- check for instant effects
     --           if power.name == "DRAW" then
     --                dealTo(power.strength, player)
     --                skip = true
     --           elseif power.name == "DRAW_WORLD_GENE" then
     --                local n = countTrait(player, "goods", "GENE")
     --                dealTo(n * power.strength, player)
     --                skip = true
     --           elseif power.name == "DRAW_EACH_NOVELTY" then
     --                dealTo(pd.produceCount["NOVELTY"] * power.strength, player)
     --                skip = true
     --           elseif power.name == "DRAW_EACH_ALIEN" then
     --                dealTo(pd.produceCount["ALIEN"] * power.strength, player)
     --                skip = true
     --           elseif power.name == "DRAW_DIFFERENT" then
     --                -- count different
     --                local n = 0
     --                for goods, count in pairs(pd.produceCount) do
     --                     if goods ~= "TOTAL" and count > 0 then
     --                          n = n + 1
     --                     end
     --                end
     --                dealTo(n * power.strength, player)
     --                skip = true
     --           end
     --      end
     end

     if skip == false then
          p.selectedCard = object.getGUID()
          --p.selectedCardPower = ""
          p.handCountSnapshot = countCardsInHand(player, true)
          p.selectedGoods = {}
          object.addTag("Selected")
     else
          -- local powers = cardData[object.getName()].powers[tostring(getCurrentPhase())]
          -- if not pd.cardsAlreadyUsed[object.getGUID()] then
          --      local arr = {}
          --      for i=1, #powers do
          --           arr[i] = false
          --      end
          --      pd.cardsAlreadyUsed[object.getGUID()] = arr
          -- end
          -- pd.cardsAlreadyUsed[object.getGUID()][pd.selectedCardPowerIndex] = true
     end

     queueUpdate(player, true)
end

function cardCancelClick(object, player, rightClick)
     if rightClick then return end

     if object.hasTag("Slot") then
          object = getCard(object)
     end

     local p = playerData[player]

     p.selectedCard = nil
     --p.miscSelectedCards = {}
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
    local cardsInHand = countCardsInHand(playerColor, false)
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
            setHelpText(playerColor, "Develop: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
        else
            setHelpText(playerColor, "▼ Develop: may select a development.")
        end
    elseif currentPhase == 3 then
        if p.selectedCard then
            local card = getObjectFromGUID(p.selectedCard)
            local info = card_db[card.getName()]

            -- Check for special settle power modifiers
            local reduceZero = false
            local reduceZeroName = ""
            local bonusMilitary = 0
            local payMilitary = false
            local node = p.miscSelectedCards

     --           while node and node.value do
     --                local miscCard = getObjectFromGUID(node.value)
     --                local actions = getCardActions("3", miscCard)
     --                if actions then
     --                     for _, action in pairs(actions) do
     --                          if action.data.codes["REDUCE_ZERO"] then
     --                               reduceZero = true
     --                               reduceZeroName = miscCard.getName()
     --                          elseif action.data.codes["EXTRA_MILITARY"] then
     --                               bonusMilitary = bonusMilitary + action.data.strength
     --                          elseif action.name == "PAY_MILITARY" then
     --                               payMilitary = true
     --                          end
     --                     end
     --                end

     --                node = node.next
     --           end

     --           if info.flags["MILITARY"] and not payMilitary then
     --                setHelpText(player, "Settle: " .. info.cost .. " defense. (Military " .. playerData[player].phasePowersSnapshot["EXTRA_MILITARY"] + bonusMilitary .. "/" .. info.cost .. ")")
     --           else
     --                if reduceZero then
     --                     setHelpText(player, "Settle: paid w/ " .. reduceZeroName .. ".")
     --                else
     --                     local discardTarget = math.max(0, info.cost - (values["REDUCE"] or 0) - (payMilitary and 1 or 0))
     --                     local discarded = handCount - cardsInHand
     --                     setHelpText(player, "Settle: cost " .. discardTarget .. ". (discard " .. discarded .. "/" .. discardTarget .. ")")
     --                end
     --           end
        else
            setHelpText(playerColor, "▼ Settle: may select a world.")
        end
     -- elseif currentPhase == 4 then
     --      if playerData[player].selectedCard then
     --           local card = getObjectFromGUID(playerData[player].selectedCard)
     --           local info = cardData[card.getName()]
     --           local power = info.powers["4"][playerData[player].selectedCardPowerIndex]

     --           if power.name == "TRADE_ACTION" then
     --                setHelpText(player, "▲ Consume: select a good to sell.")
     --           elseif power.name == "DISCARD_HAND" then
     --                setHelpText(player, "▼ Consume: discard cards for VP.")
     --           else
     --                setHelpText(player, "▲ Consume: select goods to consume.")
     --           end
     --      else
     --           setHelpText(player, "▲ Consume: use powers.")
     --      end
     -- elseif currentPhase == 5 then
     --      if playerData[player].selectedCard then
     --           local card = getObjectFromGUID(playerData[player].selectedCard)
     --           local info = cardData[card.getName()]
     --           local power = info.powers["5"][playerData[player].selectedCardPowerIndex]
     --           local paidCost = playerData[player].paidCost[card.getGUID()]
     --           if power.name == "WINDFALL_ANY" or
     --              (power.name == "DISCARD" and power.codes["WINDFALL_ANY"] and paidCost and paidCost[playerData[player].selectedCardPowerIndex]) then
     --                setHelpText(player, "▲ Produce: produce on windfall world.")
     --           elseif power.name == "DISCARD" then
     --                setHelpText(player, "▼ Produce: discard card to use power.")
     --           end
     --      else
     --           setHelpText(player, "▲ Produce: use powers.")
     --      end
     end
end

function calculateVp(player)
     -- local i = playerColorIndex[player]
     -- local zone = getObjectFromGUID(tableauZone_GUID[i])

     -- local vpChipCount = 0
     -- local flatVp = 0
     -- local devVp = 0
     -- local goodsCount = 0
     -- local baseMilitary = 0
     -- local sixCostDevs = {}
     -- local cardNames = {}

     -- -- first pass to count certain items
     -- for _, obj in pairs(zone.getObjects()) do
     --      if obj.hasTag("Ignore Tableau") then goto skip end

     --      if obj.hasTag("VP") then
     --           if obj.hasTag("VP Chip") then
     --                vpChipCount = vpChipCount + math.max(1, obj.getQuantity())
     --           end
     --      elseif obj.type == "Card" and obj.hasTag("Action Card") == false then
     --           if obj.is_face_down and obj.getDescription() ~= "" then
     --                goodsCount = goodsCount + 1
     --           else
     --                local info = cardData[obj.getName()]

     --                cardNames[obj.getName()] = true
     --                flatVp = flatVp + info.vp

     --                if info.powers["3"] and info.powers["3"]["EXTRA_MILITARY"] and tableLength(info.powers["3"]["EXTRA_MILITARY"].codes) <= 0 then
     --                     baseMilitary = baseMilitary + info.powers["3"]["EXTRA_MILITARY"].strength
     --                end

     --                if info.vpFlags then
     --                     sixCostDevs[#sixCostDevs + 1] = {obj, info}
     --                end
     --           end
     --      end

     --      ::skip::
     -- end

     -- local goodsPrefix = {"NOVELTY", "RARE", "GENE", "ALIEN"}

     -- for _, item in pairs(sixCostDevs) do
     --      local vp = 0
     --      local dev = item[2]

     --      for card in allCardsInTableau(player) do
     --           local info = cardData[card.getName()]
     --           local otherAlien = true

     --           -- world types
     --           local otherWorld = true
     --           for _, prefix in pairs(goodsPrefix) do
     --                if dev.vpFlags[prefix .. "_PRODUCTION"] and info.goods == prefix and not info.flags["WINDFALL"] then
     --                     otherWorld = false
     --                     vp = vp + dev.vpFlags[prefix .. "_PRODUCTION"]
     --                     if prefix == "ALIEN" then
     --                          otherAlien = false
     --                     end
     --                end
     --                if dev.vpFlags[prefix .. "_WINDFALL"] and info.goods == prefix and info.flags["WINDFALL"] then
     --                     otherWorld = false
     --                     vp = vp + dev.vpFlags[prefix .. "_WINDFALL"]
     --                     if prefix == "ALIEN" then
     --                          otherAlien = false
     --                     end
     --                end
     --           end

     --           if dev.vpFlags["WORLD_TRADE"] and info.type == 1 and getCardActions("5", card) then
     --                vp = vp + dev.vpFlags["WORLD_TRADE"]
     --           end
     --           if dev.vpFlags["WORLD_CONSUME"] and info.type == 1 and getCardActions("4", card) then
     --                vp = vp + dev.vpFlags["WORLD_CONSUME"]
     --           end
     --           if dev.vpFlags["WORLD_EXPLORE"] and info.type == 1 and info.powers["1"] then
     --                otherWorld = false
     --                vp = vp + dev.vpFlags["WORLD_EXPLORE"]
     --           end
     --           if dev.vpFlags["REBEL_MILITARY"] and info.type == 1 and info.flags["REBEL"] then
     --                otherWorld = false
     --                vp = vp + dev.vpFlags["REBEL_MILITARY"]
     --           end

     --           if otherWorld and dev.vpFlags["MILITARY"] and info.type == 1 and info.flags["MILITARY"] then
     --                vp = vp + dev.vpFlags["MILITARY"]
     --           end
     --           if otherWorld and dev.vpFlags["WORLD"] and info.type == 1 then
     --                vp = vp + dev.vpFlags["WORLD"]
     --           end

     --           -- development types
     --           local otherDev = true

     --           if dev.vpFlags["SIX_DEVEL"] and info.type == 2 and info.cost == 6 then
     --                otherDev = false
     --                vp = vp + dev.vpFlags["SIX_DEVEL"]
     --           end
     --           if dev.vpFlags["DEVEL_TRADE"] and info.type == 2 and getCardActions("5", card) then
     --                vp = vp + dev.vpFlags["DEVEL_TRADE"]
     --           end
     --           if dev.vpFlags["DEVEL_CONSUME"] and info.type == 2 and getCardActions("4", card) then
     --                vp = vp + dev.vpFlags["DEVEL_CONSUME"]
     --           end
     --           if dev.vpFlags["DEVEL_EXPLORE"] and info.type == 2 and info.powers["1"] then
     --                vp = vp + dev.vpFlags["DEVEL_EXPLORE"]
     --           end

     --           if otherDev and dev.vpFlags["DEVEL"] and info.type == 2 then
     --                vp = vp + dev.vpFlags["DEVEL"]
     --           end

     --           -- other card tag checks
     --           if otherAlien and dev.vpFlags["ALIEN_FLAG"] and info.flags["ALIEN"] then
     --                vp = vp + dev.vpFlags["ALIEN_FLAG"]
     --           end
     --      end

     --      -- name checks
     --      if dev.vpFlags["NAME"] then
     --           for _, entry in pairs(dev.vpFlags["NAME"]) do
     --                vp = vp + (cardNames[entry.name] and entry.vp or 0)
     --           end
     --      end

     --      -- other
     --      if dev.vpFlags["GOODS_REMAINING"] then
     --           vp = vp + goodsCount * dev.vpFlags["GOODS_REMAINING"]
     --      end
     --      if dev.vpFlags["THREE_VP"] then
     --           vp = vp + math.floor(vpChipCount / 3) * dev.vpFlags["THREE_VP"]
     --      end
     --      if dev.vpFlags["TOTAL_MILITARY"] then
     --           vp = vp + baseMilitary * dev.vpFlags["TOTAL_MILITARY"]
     --      end

     --      displayVpHexOn(item[1], vp)

     --      devVp = devVp + vp
     -- end

     -- local statTracker = getObjectFromGUID(statTracker_GUID[i])
     -- if statTracker then
     --      statTracker.call("updateLabel", {"vp", flatVp + vpChipCount + devVp})
     -- end
end