require("util")

function createSelectButtonOnCard(card)
    card.clearButtons()
    card.createButton({
         click_function = "cardSelectClick",
         function_owner = self,
         position = {0, 0.5, 0},
         width = 600,
         height = 1000,
         font_size = 150,
         color = color(0, 1, 1, 0.5),
         tooltip = 'Select "' .. card.getName() .. '"'
    })
end

function createCancelButtonOnCard(card)
    card.clearButtons()
    card.createButton({
         click_function = "cardCancelClick",
         function_owner = self,
         position = {0, 0.5, 0},
         width = 600,
         height = 1000,
         font_size = 150,
         color = color(1, 0.5, 0.5, 0.5),
         tooltip = 'Cancel "' .. card.getName() .. '"'
    })
end

function createSelectWorldButton(card)
    local slot = getCardSlot(card)
    slot.createButton({
        click_function = "worldSelectClick",
        function_owner = self,
        position = slot.positionToLocal(card.positionToWorld({0.3, 1, -1.15})),
        width = 560,
        height = 350,
        font_size = 150,
        color = color(0, 1, 1, 0.5),
        scale = {0.5, 1, 0.3},
        tooltip = 'Select "' .. card.getName() .. '"'
    })
end

function createConfirmButton(card)
    local slot = getCardSlot(card)
    if not slot then return end

    slot.createButton({
        click_function = "confirmPowerClick",
        function_owner = Global,
        label = "Confirm",
        font_size = 150,
        width = 900,
        height = 220,
        position = {0, 0, .63},
        scale = {0.5, 1, 0.4},
        tooltip = "Confirm power / selection.",
    })
end

function createUsePowerButton(card, powerIndex, powersCount, tooltip, color)
    local slot = getCardSlot(card)

    if not slot then return end

    local w = 900 / powersCount
    local xW = 1
    local offx = xW / powersCount

    slot.createButton({
        click_function = "usePowerClick" .. powerIndex,
        function_owner = Global,
        label = powersCount == 1 and "Use Power" or "Pow " .. powerIndex,
        font_size = 150,
        height = 220,
        width = w,
        scale = {0.5, 1, 0.4},
        position = {-offx / 2 * (powersCount - 1) + (powerIndex-1) * offx, 0, -0.63},
        tooltip = tooltip,
        color = color or "White"
    })
end

function createCancelButton(card)
    local slot = getCardSlot(card)
    if not slot then return end

    slot.createButton({
        click_function = "cancelPowerClick",
        function_owner = Global,
        label = "Cancel",
        font_size = 150,
        width = 900,
        height = 220,
        position = {0, 0, -.63},
        scale = {0.5, 1, 0.4},
        tooltip = "Cancel power.",
    })
end

function createGoodsButton(card, label, color)
    local goodsSnapPointOffset = {0.6, 1, 0.4}
    local slot = getCardSlot(card)
    local pos = slot.positionToLocal(card.positionToWorld(goodsSnapPointOffset))

    slot.createButton({
            click_function = "goodSelectClick",
            function_owner = Global,
            label = label or "",
            font_size = 175,
            color = color or "White",
            width = 500,
            height = 750,
            position = pos,
            scale = {0.5, 1, 0.35}
    })
end

function createStrengthLabel(player, card, addDefense)
    local calcCard = card
    if playerData[player].takeoverTarget then
        calcCard = getObjectFromGUID(playerData[player].takeoverTarget)
    end

    card.createButton({
        click_function = "none",
        function_owner = Global,
        width = 0,
        height = 0,
        position = {-1.2, 1, 0},
        rotation = {0, -90, 0},
        font_size = 150,
        label = "Military +" .. calcStrength(player, calcCard, addDefense),
        font_color = "White",
    })
end

function highlightOn(o, color, player)
    if o.UI.getXml() == '' then
        o.UI.setXml('<Panel id="highlight" color="' .. color .. '" width="220" height="314" visibility="Black|' .. player .. '"/>' ..
[[
<Text id="x" fontSize="200" color="Red" position="0 0 100" rotation="180 0 0" active="false">✘</Text>
<Panel id="hex" width="100" height="100" position="45 -113 -30" scale="0.3" rotation="0 0 180" active="false">
    <Image image="hex" preserveAspect="true"/>
    <Text id="vp" fontSize="65" fontStyle="Bold"></Text>
</Panel>
]])
    else
        o.UI.setAttributes("highlight",{
            active = true,
            visibility = "Black|" .. player,
            color = color
        })
    end
end

function highlightOff(o)
    if o.UI.getXml() ~= '' then
        o.UI.setAttribute("highlight", "active", false)
    end
end

function displayVpHexOn(o, value)
    if o.UI.getXml() == '' then
        o.UI.setXml('<Panel id="highlight" width="220" height="314" active="false"/>' ..
         '<Text id="x" fontSize="200" color="Red" position="0 0 100" rotation="180 0 0" active="false">✘</Text>' ..
         '<Panel id="hex" width="100" height="100" position="45 -113 -30" scale="0.3" rotation="0 0 180"><Image image="hex" preserveAspect="true"/>'..
         '<Text id="vp" fontSize="65" fontStyle="Bold">' .. value .. '</Text></Panel>')
    else
        o.UI.setAttribute("hex", "active", true)
        o.UI.setValue("vp", value)
    end
end

function displayVpHexOff(o)
    if o.UI.getXml() ~= '' then
        o.UI.setAttribute("hex", "active", false)
    end
end

function displayXOn(o, player)
    displayBackTextOn(o, "✘", {color="Red", fontSize=200}, player)
end

function displayPrestigeSearchActionText(o, text, player)
    displayBackTextOn(o, text, {color="White", fontSize=30, fontStyle="Bold"}, player)
end

function displayBackTextOn(o, text, attributes, player)
    if o.UI.getXml() == '' then
        local fontSz = attributes.fontSize or 200
        local color = attributes.color or "White"
        local style = attributes.fontStyle or ""
        o.UI.setXml('<Text id="x" fontStyle="' .. style .. '" fontSize="' .. fontSz .. '" color="' .. color ..'" position="0 0 100" rotation="180 0 0" visibility="Black|' .. player .. '">' .. text .. '</Text>' ..
[[
<Panel id="highlight" width="220" height="314" active="false"/>
<Panel id="hex" width="100" height="100" position="45 -113 -30" scale="0.3" rotation="0 0 180" active="false">
    <Image image="hex" preserveAspect="true"/>
    <Text id="vp" fontSize="65" fontStyle="Bold"></Text>
</Panel>
]])
    else
        attributes.active = true
        attributes.visibility = "Black|" .. player
        attributes.fontStyle = attributes.fontStyle or ""
        o.UI.setAttributes("x", attributes)
        o.UI.setValue("x", text)
    end
end

function displayBackTextOff(o)
    if o.UI.getXml() ~= '' then
        o.UI.setAttribute("x", "active", false)
    end
end

function refreshTakeoverMenu(owner)
    local players = {"Yellow", "Red", "Blue", "Green"}
    local op = playerData[owner]

    if not op.takeoverPower then return end

    -- The main index value is to determine which of the UI windows to edit, and the player index determines column based on player seating.
    local indexValues = {
        Yellow = {main=3,Red=1,Blue=2,Green=3},
        Red = {main=4,Blue=1,Green=2,Yellow=3},
        Blue = {main=5,Green=1,Yellow=2,Red=3},
        Green = {main=6,Yellow=1,Red=2,Blue=3}
    }

    local largestCount = 0
    local op = playerData[owner]
    local node = op.miscSelectedCards
    local takeoverPower = isTakeoverPower(op.takeoverPower)
    local conquerSettle = false
    local reselected = false

    op.takeoverMenuMap = {}

    while node and node.value do
        if node.power.name == "DISCARD_CONQUER_SETTLE" then
            conquerSettle = true
            break
        end
        node = node.next
    end

    for _, player in pairs(players) do
        local btnCount = 0
        if player ~= owner then
            local nameId = "name" .. player .. "_" .. owner
            local p = playerData[player]

            Global.UI.setValue(nameId, Player[player].steam_name or player)

            if takeoverPower == "TAKEOVER_MILITARY" and p.powersSnapshot["EXTRA_MILITARY"] <= 0 or 
                takeoverPower == "TAKEOVER_IMPERIUM" and not p.powersSnapshot["IMPERIUM"] then
                goto skip_player
            end

            for card in allCardsInTableau(player) do
                local info = card_db[card.getName()]
                local btnId = "btn" .. indexValues[owner][player] .. btnCount + 1 .. "_" .. owner
                
                if takeoverPower == "TAKEOVER_REBEL" and not info.flags["REBEL"] then
                    goto skip_card
                end
        
                if info.type == 1 and (not conquerSettle and info.flags["MILITARY"] or conquerSettle and not info.flags["MILITARY"]) then
                    local yourStrength = calcStrength(owner, card, false, owner)
                    local theirDefense = calcStrength(player, card, true, owner)
                    local class = ""
                    local canTake = yourStrength >= theirDefense
                    local reselect = canTake and op.takeoverTarget == card.getGUID()
                    local txt = card.getName() .. " - [" .. yourStrength .. "]vs[" .. theirDefense .. "]"
        
                    -- Disable previously selected target if can no longer take it
                    if not canTake and op.takeoverTarget == card.getGUID() then
                        op.takeoverTarget = nil
                    elseif canTake and op.takeoverTarget == card.getGUID() then
                        reselected = true
                    end

                    if reselect then
                        class = "selected"
                    elseif canTake then
                        class = ""
                    else
                        class = "disabled"
                    end

                    Global.UI.setAttributes(btnId, {
                        active=true,
                        interactable=canTake,
                        class=class,
                        onValueChanged="menuValueChanged",
                        isOn=reselect,
                        text=txt,
                    })
                    
                    if class == "" then
                        Global.UI.setAttribute(btnId, "color", "White")
                    end

                    op.takeoverMenuMap[btnId] = card.getGUID()

                    btnCount = btnCount + 1
                end

                ::skip_card::
            end

            ::skip_player::

            -- disable the rest of the buttons
            for i=btnCount+1, 12 do
                local btnId = "btn" .. indexValues[owner][player] .. i .. "_" .. owner
                Global.UI.setAttribute(btnId, "active", false)
            end
        end

        if btnCount > largestCount then
            largestCount = btnCount
        end
    end

    if not reselected then
        op.takeoverTarget = nil
    end

    -- need to readjust height of the toggle group to fit all the buttons
    Global.UI.setAttribute("group_" .. owner, "preferredHeight", 48 * largestCount)
end

function calcStrength(player, card, addDefense, activePlayer)
    local p = playerData[player]
    local info = card_db[card.getName()]

    local value = p.powersSnapshot["EXTRA_MILITARY"]
    if activePlayer == player or activePlayer == nil then
        value = value + p.powersSnapshot["BONUS_MILITARY"] + p.tempMilitary
    end

    -- Check for bonus military
    if info.goods then
        local key = info.goods .. "_BONUS_MILITARY"
        if p.powersSnapshot[key] then
            value = value + p.powersSnapshot[key]
        end
    end

    if info.flags["REBEL"] then
        local key = "AGAINST_REBEL_BONUS_MILITARY"
        if p.powersSnapshot[key] then
            value = value + p.powersSnapshot[key]
        end
    end

    if addDefense then
        value = value + info.cost + (p.powersSnapshot["TAKEOVER_DEFENSE"] or 0)
        if activePlayer == nil then
            value = value + p.powersSnapshot["BONUS_MILITARY"] + p.tempMilitary
        end
    elseif p.takeoverPower and p.takeoverPower.name == "TAKEOVER_IMPERIUM" then
        value = value + p.powersSnapshot["REBEL_MILITARY_WORLD_COUNT"] * p.takeoverPower.strength
    end

    return value
end

function menuValueChanged(player, value, id, ok)
    local p = playerData[player.color]
    if value == "True" then
        Global.UI.setAttribute(id, "color", "rgb(0.4,0.8,1)")
        p.takeoverTarget = p.takeoverMenuMap[id]
    else
        Global.UI.setAttribute(id, "color", "White")
        p.takeoverTarget = nil
    end
end

function drawTakeoverLines()
    local lines = getDefaultVectorLines()
    for player, data in pairs(playerData) do
        if data.takeoverSource and data.takeoverTarget then
            local source = getObjectFromGUID(data.takeoverSource)
            local target = getObjectFromGUID(data.takeoverTarget)

            local line = {
                points = {source.getPosition(), target.getPosition()},
                color = player,
                thickness = 0.5,
                rotation = {0, 0, 0}
            }

            lines[#lines + 1] = line
        end
    end

    Global.setVectorLines(lines)
end

function createGamblingWorldUi(card)
    local n = card.getVar("number") or 1
    card.createButton({
        click_function = "gamblingWorldChangeValue",
        function_owner = Global,
        width = 400,
        height = 400,
        label = n,
        font_size = 300,
        position = {0, 1, -0.3},
    })
end

-- The default vector lines are the colored square around each player action selection box
function getDefaultVectorLines()
    return {{
        points={{-2.79, 1.49, -8.14},{2.77, 1.49, -8.14},{2.77, 1.49, -11.46},{-2.79, 1.49, -11.46}},
        color="Yellow", thickness=0.1, loop=true
    },
    {
        points={{8.11, 1.49, -2.79},{8.11, 1.49, 2.78},{11.50, 1.49, 2.78},{11.50, 1.49, -2.79}},
        color="Green", thickness=0.1, loop=true
    },
    {
        points={{2.83, 1.49, 8.07},{-2.78, 1.49, 8.07},{-2.78, 1.49, 11.50},{2.83, 1.49, 11.50},},
        color="Blue", thickness=0.1, loop=true
    },
    {
        points={{-8.11, 1.49, 2.78},{-8.11, 1.49, -2.78},{-11.47, 1.49, -2.78},{-11.47, 1.49, 2.78}},
        color="Red", thickness=0.1, loop=true
    }}
end

function updateHandCount(playerColor)
    local i = playerData[playerColor].index
    local statTracker = getObjectFromGUID(statTracker_GUID[i])
    if statTracker then
        statTracker.call("updateLabel", {"hand", #Player[playerColor].getHandObjects()})
    end
end

function showSecurityCouncilMenu(targetPlayer)
    local p = playerData[targetPlayer]
    local targetText = "Target: "
    if p.securityCouncilTarget then 
        targetText = targetText .. Player[p.securityCouncilTarget].steam_name or p.securityCouncilTarget
    else
        targetText = targetText .. "None"
    end
    Global.UI.setValue("securityTarget", targetText)
    for player, data in pairs(playerData) do
        local id = "security" .. player
        Global.UI.setAttribute(id, "text", Player[player].steam_name or player)
        if data.takeoverTarget then
            Global.UI.setAttribute(id, "interactable", true)
        else
            Global.UI.setAttribute(id, "interactable", false)
        end
    end
    Global.UI.setAttributes("securityCouncilMenu", {active=true, visibility=targetPlayer})
end

function securitySelectTarget(player, button, id)
    local p = playerData[player.color]
    p.securityCouncilTarget = id:sub(9, id:len())
    Global.UI.setValue("securityTarget", "Target: " .. (player.steam_name or player.color))
end

function createKindTypeUI(card)
    local choiceLocked = card.getVar("choiceLocked")
    if not choiceLocked and enforceRules or not enforceRules then
        card.createButton({
            click_function = "selectKindNoveltyClick",
            function_owner = Global,
            tooltip = "Select Novelty",
            width = 100,
            height = 100,
            color = goodsHighlightColor["NOVELTY"],
            position = {-1.4, 0.5, -1.3},
        })

        card.createButton({
            click_function = "selectKindRareClick",
            function_owner = Global,
            tooltip = "Select Rare",
            width = 100,
            height = 100,
            color = goodsHighlightColor["RARE"],
            position = {-1.2, 0.5, -1.3},
        })

        card.createButton({
            click_function = "selectKindGeneClick",
            function_owner = Global,
            tooltip = "Select Genes",
            width = 100,
            height = 100,
            color = goodsHighlightColor["GENE"],
            position = {-1.4, 0.5, -1.1},
        })

        card.createButton({
            click_function = "selectKindAlienClick",
            function_owner = Global,
            tooltip = "Select Alien",
            width = 100,
            height = 100,
            color = goodsHighlightColor["ALIEN"],
            position = {-1.2, 0.5, -1.1},
        })
    end

    card.createButton({
        click_function = "none",
        function_owner = Global,
        label = card.getVar("kind"),
        width = 500,
        height = 120,
        font_size = 100,
        font_color = goodsHighlightColor[card.getVar("kind")],
        color=color(0,0,0),
        position = {0, 0.5, -0.72},
        tooltip = "Kind"
    })
end

function selectKindNoveltyClick(obj, player, rightClick)
    if rightClick then return end
    obj.setVar("kind", "NOVELTY")
    queueUpdate(player, true)
end

function selectKindRareClick(obj, player, rightClick)
    if rightClick then return end
    obj.setVar("kind", "RARE")
    queueUpdate(player, true)
end

function selectKindGeneClick(obj, player, rightClick)
    if rightClick then return end
    obj.setVar("kind", "GENE")
    queueUpdate(player, true)
end

function selectKindAlienClick(obj, player, rightClick)
    if rightClick then return end
    obj.setVar("kind", "ALIEN")
    queueUpdate(player, true)
end

function getPrestigeSearchActionCard(player)
    local p = playerData[player]
    local zone = getObjectFromGUID(selectedActionZone_GUID[p.index])
    local objs = zone.getObjects()

    for _, obj in pairs(objs) do
         if obj.hasTag("PrestigeSearch") then
            return obj
         end
    end
end

function prestigeExplore5Click(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Explore (+5)")
    broadcastToColor("Selected Prestige Explore (+5).", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeExplore11Click(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Explore (+1,+1)")
    broadcastToColor("Selected Prestige Explore (+1,+1).", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeDevelopClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Develop")
    broadcastToColor("Selected Prestige Develop.", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeSettleClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Settle")
    broadcastToColor("Selected Prestige Settle.", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeConsumeTradeClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Consume ($)")
    broadcastToColor("Selected Prestige Consume ($).", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeConsumex2Click(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Consume (x2)")
    broadcastToColor("Selected Prestige Consume (x2).", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function prestigeProduceClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Prestige Produce")
    broadcastToColor("Selected Prestige Produce.", player.color, player.color)
    updatePrestigeSearchTextBack(card, player.color)
end

function searchDevMilitaryClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for military developments.", player.color, player.color)
    playerData[player.color].searchAction = "MilitaryDev"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchMilitaryWindfallClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for military windfall worlds.", player.color, player.color)
    playerData[player.color].searchAction = "MilitaryWindfall"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchWindfallClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for windfall worlds.", player.color, player.color)
    playerData[player.color].searchAction = "Windfall"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchChromoWorldClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for Chromosome worlds.", player.color, player.color)
    playerData[player.color].searchAction = "ChromoWorld"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchAlienWorldClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for Aliens worlds.", player.color, player.color)
    playerData[player.color].searchAction = "AlienWorld"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchConsumePowerClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for multi-consume powers.", player.color, player.color)
    playerData[player.color].searchAction = "MultiConsume"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchMilitary5WorldClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for defense 5+ military worlds.", player.color, player.color)
    playerData[player.color].searchAction = "Military5World"
    updatePrestigeSearchTextBack(card, player.color)
end

function search6CostDevClick(player, button)
    if button ~= "-1" then return end
    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for 6-cost developments.", player.color, player.color)
    playerData[player.color].searchAction = "6Dev"
    updatePrestigeSearchTextBack(card, player.color)
end

function searchTakeoverPowerClick(player, button)
    if button ~= "-1" then return end

    if enforceRules and not useTakeovers then
        broadcastToColor("Takeovers is turned off.", player.color, "White")
        return
    end

    local card = getPrestigeSearchActionCard(player.color)
    card.setName("Search")
    broadcastToColor("You will search for takeover / defense powers.", player.color, player.color)
    playerData[player.color].searchAction = "Takeover"
    updatePrestigeSearchTextBack(card, player.color)
end

function updatePrestigeSearchTextBack(card, player)
    local tbl = {
        ["Prestige Explore (+5)"] = "Prestige\nExplore (+5)",
        ["Prestige Explore (+1,+1)"] = "Prestige\nExplore (+1,+1)",
        ["Prestige Develop"] = "Prestige\nDevelop",
        ["Prestige Settle"] = "Prestige\nSettle",
        ["Prestige Consume ($)"] = "Prestige\nConsume ($)",
        ["Prestige Consume (x2)"] = "Prestige\nConsume (x2)",
        ["Prestige Produce"] = "Prestige\nProduce",
        ["MilitaryDev"] = "Search for\nMilitary\nDevelopment",
        ["MilitaryWindfall"] = "Search for\nMilitary\nWindfall World",
        ["Windfall"] = "Search for\nWindfall World",
        ["ChromoWorld"] = "Search for\nChromosome\nWorld",
        ["AlienWorld"] = "Search for\nAlien World",
        ["MultiConsume"] = "Search for\nMulti-Consume\nPower",
        ["Military5World"] = "Search for\nMilitary 5+\nWorld",
        ["6Dev"] = "Search for\n6-cost\nDevelopment",
        ["Takeover"] = "Search for\nTakeover/Defense\nPower"
    }
    local text = ""
    local name = card.getName()

    if name == "Search" then
        text = tbl[playerData[player].searchAction]
    elseif tbl[name] then
        text = tbl[name]
    end

    displayPrestigeSearchActionText(card, text, player)
end