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

function createCardBottomButton(card, text, func)
    local slot = getCardSlot(card)
    slot.createButton({
        click_function = func,
        function_owner = Global,
        label = text,
        font_size = 150,
        width = 900,
        height = 220,
        position = {0, 0, .63},
        scale = {0.5, 1, 0.4}
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
        scale = {0.5, 1, 0.4}
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
    local offset = {0.28, 5, 0.13}
    local slot = getCardSlot(card)

    slot.createButton({
        click_function = "goodSelectClick",
        function_owner = Global,
        label = label or "",
        font_size = 175,
        color = color or "White",
        width = 500,
        height = 750,
        position = offset,
        scale = {0.5, 2, 0.35}
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
        o.UI.setXml('<Panel id="highlight" color="' .. color .. '" width="220" height="314" visibility="' .. player .. '"/>' ..
[[
<Panel id="hex" width="100" height="100" position="45 -113 -30" scale="0.3" rotation="0 0 180" active="false">
    <Image image="hex" preserveAspect="true"/>
    <Text id="vp" fontSize="65" fontStyle="Bold"></Text>
</Panel>
]])
    else
        o.UI.setAttributes("highlight",{
            active = true,
            visibility = player,
            color = color
        })
    end
end

function highlightOff(o)
    if o.UI.getXml() ~= '' then
        o.UI.setAttribute("highlight", "active", false)
    end
end

function displayVpHexOff(o)
    if o.UI.getXml() ~= '' then
        o.UI.setAttribute("hex", "active", false)
    end
end

function displayVpHexOn(o, value)
    if o.UI.getXml() == '' then
        o.UI.setXml('<Panel id="highlight" width="220" height="314" active="false"/>' ..
         '<Panel id="hex" width="100" height="100" position="45 -113 -30" scale="0.3" rotation="0 0 180"><Image image="hex" preserveAspect="true"/>'..
         '<Text id="vp" fontSize="65" fontStyle="Bold">' .. value .. '</Text></Panel>')
    else
        o.UI.setAttribute("hex", "active", true)
        o.UI.setValue("vp", value)
    end
end

function refreshTakeoverMenu(owner, takeoverPower)
    local players = {"Yellow", "Red", "Blue", "Green"}

    -- The main index value is to determine which of the UI windows to edit, and the player index determines column based on player seating.
    local indexValues = {
        Yellow = {main=3,Red=1,Blue=2,Green=3},
        Red = {main=4,Blue=1,Green=2,Yellow=3},
        Blue = {main=5,Green=1,Yellow=2,Red=3},
        Green = {main=6,Yellow=1,Red=2,Blue=3}
    }

    local xml = Global.UI.getXmlTable()
    local mainPanelBody = xml[indexValues[owner].main]
    local groupBody = mainPanelBody.children[1].children[4].children[1].children

    for _, player in pairs(players) do
        if player ~= owner then
            local column = {}

            -- Name box
            local nametext = {tag="Text", attributes={class="name",color=player}, value=Player[player].steam_name or player}
            local panel = {tag="Panel", attributes={class="namebox"}, children={nametext}}
            column[1] = panel

            local p = playerData[player]

            if takeoverPower == "TAKEOVER_MILITARY" and p.powersSnapshot["EXTRA_MILITARY"] <= 0 then
                goto skip_player
            end

            for card in allCardsInTableau(player) do
                local info = card_db[card.getName()]

                if takeoverPower == "TAKEOVER_REBEL" and not info.flags["REBEL"] then
                    goto skip_card
                end

                if info.type == 1 and info.flags["MILITARY"] then
                    local yourStrength = calcStrength(owner, card, false)
                    local theirDefense = calcStrength(player, card, true)
                    local canTake = yourStrength >= theirDefense

                    local btn = {
                        tag="ToggleButton",
                        attributes = {
                            id=owner .. "_" .. card.getGUID(),
                            interactable=canTake,
                            class=(canTake and "" or "disabled"),
                            onValueChanged="menuValueChanged"
                        },
                        children = {},
                        value = card.getName() .. " - [" .. yourStrength .. "]vs[" .. theirDefense .. "]"
                    }

                    column[#column + 1] = btn
                end

                ::skip_card::
            end

            ::skip_player::

            groupBody[indexValues[owner][player]].children = column
        end
    end

    Global.UI.setXmlTable(xml)
end

function calcStrength(player, card, addDefense)
    local p = playerData[player]
    local info = card_db[card.getName()]

    local value = p.powersSnapshot["EXTRA_MILITARY"]

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
    end

    return value
end

function menuValueChanged(player, value, id)
    if value == "True" then
        Global.UI.setAttribute(id, "color", "rgb(0.4,0.8,1)")
        playerData[player.color].takeoverTarget = split(id, "_")[2]
    else
        Global.UI.setAttribute(id, "color", "White")
        playerData[player.color].takeoverTarget = nil
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

function getDefaultVectorLines()
    return {{
        points={{-2.79, 1.49, -8.34},{2.77, 1.49, -8.34},{2.77, 1.49, -11.66},{-2.79, 1.49, -11.66}},
        color="Yellow", thickness=0.1, loop=true
    },
    {
        points={{8.31, 1.49, -2.79},{8.31, 1.49, 2.78},{11.70, 1.49, 2.78},{11.70, 1.49, -2.79}},
        color="Green", thickness=0.1, loop=true
    },
    {
        points={{2.83, 1.49, 8.27},{-2.78, 1.49, 8.27},{-2.78, 1.49, 11.70},{2.83, 1.49, 11.70},},
        color="Blue", thickness=0.1, loop=true
    },
    {
        points={{-8.31, 1.49, 2.78},{-8.31, 1.49, -2.78},{-11.67, 1.49, -2.78},{-11.67, 1.49, 2.78}},
        color="Red", thickness=0.1, loop=true
    }}
end