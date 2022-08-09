require("util")

phaseCardNames = {"Explore (+5)", "Explore (+1,+1)", "Develop", "Settle", "Consume ($)", "Consume (x2)", "Produce", "Prestige / Search"}
phaseCardNamesAdv2p = {"Explore (+5)", "Explore (+1,+1)", "Develop", "Develop [2p]", "Settle", "Settle [2p]", "Consume ($)", "Consume (x2)", "Produce", "Prestige / Search"}

prestigeButton_GUID = {['b5027c']=1,['77721b']=1,['a276bc']=1,['09bbe0']=1}
targetActionCardName = ""
selectedActions = {}
btnIndexOffset = 7
adv2pBtnIndexOffset = 9

function onload()
     actionZone = getObjectFromGUID(actionZone_GUID)
     selectedActionCardTile = getObjectFromGUID(selectedActionCardTile_GUID)
     selectedActionCardZone = getObjectFromGUID(selectedActionCardZone_GUID)
     componentsBag = getObjectFromGUID("4c1650")

     buttonIndex = {}
     adv2pButtonIndex = {}

     if prestigeButton_GUID[self.getGUID()] then prestigeSearch = true end

     if prestigeSearch then
          btnIndexOffset = 1
          adv2pBtnIndexOffset = 2
          buttonIndex["Prestige / Search"] = 0
          adv2pButtonIndex["Prestige / Search"] = 1
     else
          local i = 0
          for _, entry in ipairs(phaseCardNames) do
               buttonIndex[entry] = i
               i = i + 1
          end

          local i = 14
          for _, entry in ipairs(phaseCardNamesAdv2p) do
               adv2pButtonIndex[entry] = i
               i = i + 1
          end
     end

     createButtons()

     refreshButtonHighlights()

     local players = {"Yellow", "Red", "Blue", "Green"}
     local hideFrom = {}
     for _, target in pairs(players) do
          if target ~= player then
               hideFrom[#hideFrom + 1] = target
          end
     end

     self.setInvisibleTo(hideFrom)
end

function createButtons()
     local tooltips = {
          "I: Explore (+5)",
          "I: Explore (+1,+1)",
          "II: Develop",
          "III: Settle",
          "IV: Consume ($)",
          "IV: Consume (2x)",
          "V: Produce"
     }

     local tooltips2pAdv = {
          "I: Explore (+5)",
          "I: Explore (+1,+1)",
          "II: Develop",
          "II: Develop",
          "III: Settle",
          "III: Settle",
          "IV: Consume ($)",
          "IV: Consume (2x)",
          "V: Produce"
     }

     local clickFunc = {
          "explore5Click",
          "explore11Click",
          "developClick",
          "settleClick",
          "consumeTradeClick",
          "consumex2Click",
          "produceClick"
     }

     local clickFunc2pAdv = {
          "explore5Click",
          "explore11Click",
          "developClick",
          "develop2Click",
          "settleClick",
          "settle2Click",
          "consumeTradeClick",
          "consumex2Click",
          "produceClick"
     }

     local startx = -5.73
     local startx2p = 7.63

     if prestigeSearch then
          tooltips = {"Prestige / Search"}
          tooltips2pAdv = tooltips
          clickFunc = {"prestigeSearchClick"}
          clickFunc2pAdv = clickFunc
          startx = 0
          startx2p = 0
     end

     for i=1, #tooltips do
          self.createButton({
               click_function = clickFunc[i],
               function_owner = self,
               width = 600,
               height = 600,
               position = {startx + (i-1) * 1.905, 0.11, 0},
               color = color(0, 0, 0, 0),
               tooltip = tooltips[i]
          })
     end

     for i=1, #tooltips do
          self.createButton({
               click_function = "none",
               function_owner = self,
               width = 0,
               height = 0,
               font_size = 120,
               position = {startx + (i-1) * 1.905, 0.11, -0.1},
               rotation = {0, 0, 180},
               color = color(0, 0, 0, 0),
               label = "■",
               scale = {2,1,2},
               font_size = 1000,
               font_color = "Yellow"
          })
     end

     for i=1, #tooltips2pAdv do
          self.createButton({
               click_function = clickFunc2pAdv[i],
               function_owner = self,
               width = 600,
               height = 600,
               position = {startx2p - (i-1) * 1.895, 0, 0},
               rotation = {0, 0, 180},
               color = color(0, 0, 0, 0),
               tooltip = tooltips2pAdv[i]
          })
     end

     -- these extra set of buttons are for highlighting selected actions
     for i=1, #tooltips2pAdv do
          self.createButton({
               click_function = "none",
               function_owner = self,
               width = 0,
               height = 0,
               font_size = 120,
               position = {startx2p - (i-1) * 1.895, 0, -0.1},
               rotation = {0, 0, 180},
               color = color(0, 0, 0, 0),
               label = "■",
               scale = {2,1,2},
               font_size = 1000,
               font_color = "Yellow"
          })
     end
end

function explore5Click()
     targetActionCardName = "Explore (+5)"
     startLuaCoroutine(self, "selectPhaseCo")
end

function explore11Click()
     targetActionCardName = "Explore (+1,+1)"
     startLuaCoroutine(self, "selectPhaseCo")
end

function developClick()
     targetActionCardName = "Develop"
     startLuaCoroutine(self, "selectPhaseCo")
end

function develop2Click()
     targetActionCardName = "Develop [2p]"
     startLuaCoroutine(self, "selectPhaseCo")
end

function settleClick()
     targetActionCardName = "Settle"
     startLuaCoroutine(self, "selectPhaseCo")
end

function settle2Click()
     targetActionCardName = "Settle [2p]"
     startLuaCoroutine(self, "selectPhaseCo")
end

function consumeTradeClick()
     targetActionCardName = "Consume ($)"
     startLuaCoroutine(self, "selectPhaseCo")
end

function consumex2Click()
     targetActionCardName = "Consume (x2)"
     startLuaCoroutine(self, "selectPhaseCo")
end

function produceClick()
     targetActionCardName = "Produce"
     startLuaCoroutine(self, "selectPhaseCo")
end

function prestigeSearchClick()
     targetActionCardName = "Prestige / Search"
     startLuaCoroutine(self, "selectPhaseCo")
end

function selectPhaseCo()
     local playerData = Global.getVar("playerData")
     if Global.getVar("gameStarted") == false or Global.getVar("currentPhaseIndex") ~= 0 or Global.getVar("transitionNextPhase") or 
          (Global.getVar("selectLastPhase") and not playerData[player].powersSnapshot["SELECT_LAST"]) or playerData[player].selectedCardPower == "START_SAVE" then
          broadcastToColor("You cannot select an action card at this time.", player, "White")
          return 1
     end

     local adv2p = Global.getVar("advanced2p")
     local targetName = targetActionCardName

     if adv2p then
          -- Check to see if action was already selected. If so, just return it back to selection area
          local card = checkIfSelected(targetName)
          if card then
               returnSelectedActionCard(card)
               return 1
          end
     else
          returnAllSelectedActionCards()
     end

     wait(0.01)

     local sp = selectedActionCardTile.getSnapPoints()
     local rot = self.getRotation()
     local objs = actionZone.getObjects()
     local targetSnapIndex = 1

     if adv2p then
          local cardN = countSelectedActionCards()

          -- too many selected cards
          if cardN >= 2 then
               return 1
          elseif cardN == 1 then
               -- move the other card into the correct spot just in case
               for _, obj in pairs(selectedActionCardZone.getObjects()) do
                    if obj.hasTag("Action Card") then
                         obj.setPositionSmooth(add(selectedActionCardTile.positionToWorld(sp[2].position), {0, 0.04, 0}))
                         break
                    end
               end
          end

          targetSnapIndex = targetSnapIndex + 1 + cardN
     end

     for _, obj in pairs(objs) do
          if obj.type == "Card" and obj.getName() == targetName then
               local pos = selectedActionCardTile.positionToWorld(sp[targetSnapIndex].position)

               obj.setPosition({pos[1], pos[2] + 0.5, pos[3]})
               obj.setRotation({rot[1], rot[2], 180})
               return 1
          end
     end

     return 1
end

-- Returns the card into the hidden action card hand.
function returnSelectedActionCard(card)
     card.setPosition(actionZone.getPosition())
     card.setRotationSmooth({card.getRotation().x, card.getRotation().y, 0})
end

-- Returns all selected action cards.
function returnAllSelectedActionCards()
     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if obj.hasTag("Action Card") then
               obj.setPosition(actionZone.getPosition())
               obj.setRotationSmooth({obj.getRotation().x, obj.getRotation().y, 0})
          end
     end
end

function placeCardAtSnapPoint(card, spOwner, sp, faceDown)
     local rot = spOwner.getRotation()

     for i=1, 3 do
          rot[i] = rot[i] + sp.rotation[i]
     end

     if faceDown then rot[3] = 180 end

     local pos = spOwner.positionToWorld(sp.position)
     card.setPositionSmooth({pos[1], pos[2] + 0.5, pos[3]})
     card.setRotationSmooth(rot)
end

-- Returns the card with the matching name
function checkIfSelected(actionName)
     local adv2p = Global.getVar("advanced2p")

     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if obj.type == 'Card' and obj.hasTag("Action Card") and (obj.getName() == actionName or actionName == "Prestige / Search" and obj.hasTag("PrestigeSearch")) then
               return obj
          end
     end

     return nil
end

function countSelectedActionCards()
     local n = 0

     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if obj.hasTag("Action Card") then
               n = n + 1
          end
     end

     return n
end

function onObjectEnterZone(zone, obj)
     if zone == selectedActionCardZone and obj.hasTag("Action Card") then
          refreshButtonHighlights()
          if obj.hasTag("PrestigeSearch") and Global.getVar('currentPhaseIndex') == 0 and not Global.getVar('searchPhase') then
               uiSetVisibilityToPlayer("prestigeSearchMenu", player, true)
          end
     end
end

function onObjectLeaveZone(zone, obj)
     if not obj or obj.isDestroyed() then return end
     if zone == selectedActionCardZone and obj.hasTag("Action Card") then
          refreshButtonHighlights()
          if obj.hasTag("PrestigeSearch") then
               uiSetVisibilityToPlayer("prestigeSearchMenu", player, false)
          end
     end
end

function refreshButtonHighlights()
     local adv2p = Global.getVar("advanced2p")

     local startInd = btnIndexOffset
     local endInd = btnIndexOffset * 2 - 1

     if adv2p then
          startInd = btnIndexOffset * 2 + adv2pBtnIndexOffset
          endInd = (btnIndexOffset + adv2pBtnIndexOffset) * 2 - 1
     end

     if prestigeSearch then 
          startInd = 1
          endInd = 1
     end

     for i=startInd, endInd do
          self.editButton({
               index = i,
               color = color(0,0,0,0)
          })
     end

     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if obj.hasTag("Adv2p") and not adv2p or obj.hasTag("PrestigeSearch") and not prestigeSearch or not obj.hasTag("PrestigeSearch") and prestigeSearch then
               goto skip
          end

          if obj.hasTag("Action Card") then
               local name = obj.getName()
               local ind = adv2pButtonIndex[name]

               if ind or obj.hasTag("PrestigeSearch") then
                    local index = 1
                    
                    if prestigeSearch then
                         index = 1
                    else
                         index = adv2p and adv2pButtonIndex[name] + adv2pBtnIndexOffset or buttonIndex[name] + btnIndexOffset
                    end

                    self.editButton({
                         index = index,
                         color = color(0,0,0,0.8)
                    })
               end
          end

          ::skip::
     end
end