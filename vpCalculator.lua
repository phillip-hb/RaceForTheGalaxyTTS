function updateVp(player)
    local p = playerData[player]
    local i = p.index
    local zone = getObjectFromGUID(tableauZone_GUID[i])

    local vpChipCount = 0
    local prestigeCount = 0
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
            elseif obj.hasTag("Prestige") then
                prestigeCount = prestigeCount + math.max(1, obj.getQuantity())
            end
        elseif obj.type == "Card" and not obj.hasTag("Action Card") then
            if obj.is_face_down and obj.getDescription() ~= "" then -- the card is a good
                goodsCount = goodsCount + 1
            elseif not obj.is_face_down then
                local info = card_db[obj.getName()]

                cardNames[obj.getName()] = true
                flatVp = flatVp + info.vp

                local kind = getKind(obj)
                if kind and not uniqueWorlds[kind] then
                    uniqueWorldsCount = uniqueWorldsCount + 1
                    uniqueWorlds[kind] = true
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
            if dev.vpFlags["REBEL_FLAG"] and info.flags["REBEL"] then
                otherWorld = false
                vp = vp + dev.vpFlags["REBEL_FLAG"]
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
        if dev.vpFlags["PRESTIGE"] then
            vp = vp + prestigeCount * dev.vpFlags["PRESTIGE"]
        end
        if dev.vpFlags["GOODS_REMAINING"] then
            vp = vp + goodsCount * dev.vpFlags["GOODS_REMAINING"]
        end
        if dev.vpFlags["THREE_VP"] then
            vp = vp + math.floor(vpChipCount / 3) * dev.vpFlags["THREE_VP"]
        end
        if dev.vpFlags["TOTAL_MILITARY"] then
            vp = vp + baseMilitary * dev.vpFlags["TOTAL_MILITARY"]
        end
        if dev.vpFlags["NEGATIVE_MILITARY"] and baseMilitary < 0 then
            vp = vp + math.abs(baseMilitary) * dev.vpFlags["NEGATIVE_MILITARY"]
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
         statTracker.call("updateLabel", {"vp", flatVp + vpChipCount + prestigeCount + devVp})
    end
end