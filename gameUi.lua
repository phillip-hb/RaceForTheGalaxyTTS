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
         color = color(1, 1, 1, 0.5),
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
         color = color(1, 1, 1, 0.5),
         tooltip = 'Cancel "' .. card.getName() .. '"'
    })
end

function createCardTopButton(card, text, func, tooltip)
    local slot = getCardSlot(card)
    slot.createButton({
        click_function = func,
        function_owner = Global,
        label = text,
        font_size = 150,
        width = 900,
        height = 220,
        position = {0, 0, -.61},
        scale = {0.5, 1, 0.4},
        tooltip = tooltip or "",
    })
end

function createCardTop2Buttons(card, text, funcs, tooltips)
    local slot = getCardSlot(card)
    for i=1, 2 do
        local w = 500
        local h = 220
        local lbl =  text .. " " .. i
        if funcs[i] == "none" then
            w = 0
            h = 0
            lbl = ""
        end

        slot.createButton({
            click_function = funcs[i],
            function_owner = Global,
            label = lbl,
            font_size = 150,
            width = w,
            height = h,
            position = {-0.25 + (i-1) * 0.5, 0, -.61},
            scale = {0.5, 1, 0.4},
            tooltip = tooltips[i] or "",
        })
    end
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
        position = {0, 0, .61},
        scale = {0.5, 1, 0.4}
    })
end

function createUsePowerButton(card, powerIndex, powersCount, tooltip)
    local slot = getCardSlot(card)
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
        position = {-offx / 2 * (powersCount - 1) + (powerIndex-1) * offx, 0, -0.61},
        tooltip = tooltip
    })
end

function createCancelButton(card)
    local slot = getCardSlot(card)

    slot.createButton({
        click_function = "cancelPowerClick",
        function_owner = Global,
        label = "Cancel",
        font_size = 150,
        width = 900,
        height = 220,
        position = {0, 0, -.61},
        scale = {0.5, 1, 0.4},
        tooltip = "Cancel power.",
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