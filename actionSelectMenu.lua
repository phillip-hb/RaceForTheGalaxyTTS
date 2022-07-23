require("util")

targetActionCardName = ""
selectedActions = {}
btnIndexOffset = 7
adv2pBtnIndexOffset = 9

function onload()
     actionZone = getObjectFromGUID(actionZone_GUID)
     selectedActionCardTile = getObjectFromGUID(selectedActionCardTile_GUID)
     selectedActionCardZone = getObjectFromGUID(selectedActionCardZone_GUID)

     buttonIndex = {}
     local i = 0
     for _, entry in ipairs(Global.getVar("phaseCardNames")) do
          buttonIndex[entry] = i
          i = i + 1
     end

     adv2pButtonIndex = {}
     local i = 14
     for _, entry in ipairs(Global.getVar("phaseCardNamesAdv2p")) do
          adv2pButtonIndex[entry] = i
          i = i + 1
     end

     createButtons()

     refreshButtonHighlights()
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

     tooltips2pAdv = {
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

     for i=1, #tooltips do
          self.createButton({
               click_function = clickFunc[i],
               function_owner = self,
               width = 600,
               height = 600,
               position = {-5.73 + (i-1) * 1.905, 0.11, 0},
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
               position = {-5.73 + (i-1) * 1.905, 0.11, -0.1},
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
               position = {7.63 - (i-1) * 1.895, 0, 0},
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
               position = {7.63 - (i-1) * 1.895, 0, -0.1},
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
     targetActionCardName = "DevelopAdv2p"
     startLuaCoroutine(self, "selectPhaseCo")
end

function settleClick()
     targetActionCardName = "Settle"
     startLuaCoroutine(self, "selectPhaseCo")
end

function settle2Click()
     targetActionCardName = "SettleAdv2p"
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

function selectPhaseCo()
     if Global.getVar("gameStarted") == false or Global.getVar("currentPhaseIndex") ~= 0 then
          return 1
     end

     local adv2p = Global.getVar("advanced2p")
     local targetName = targetActionCardName

     if adv2p then
          -- Check to see if action was already selected. If so, just return it back to selection area
          if checkIfSelected(targetName) then
               returnSelectedActionCard(targetName)
               wait(0.01)
               --rearrangeActionCards()
               return 1
          end
     else
          returnSelectedActionCard()
     end

     wait(0.01)

     --rearrangeActionCards()

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
                         obj.setPositionSmooth(selectedActionCardTile.positionToWorld(sp[2].position))
                         break
                    end
               end
          end

          targetSnapIndex = targetSnapIndex + 1 + cardN
     end

     for _, obj in pairs(objs) do
          if obj.type == "Card" and getName(obj) == targetName then
               local pos = selectedActionCardTile.positionToWorld(sp[targetSnapIndex].position)

               obj.setPosition({pos[1], pos[2] + 1, pos[3]})
               obj.setRotation({rot[1], rot[2], 180})
               return 1
          end
     end

     return 1
end

function returnSelectedActionCard(name)
     local objs = selectedActionCardZone.getObjects()

     for _, obj in pairs(objs) do
          if obj.hasTag("Action Card") then
               if not name or name == getName(obj) then
                    obj.setPosition(actionZone.getPosition())
                    obj.setRotationSmooth({obj.getRotation()[1],obj.getRotation()[2], 0})
                    if name then return end
               end
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
     card.setPositionSmooth({pos[1], pos[2] + 0.15, pos[3]})
     card.setRotationSmooth(rot)
end

function checkIfSelected(actionName)
     local adv2p = Global.getVar("advanced2p")

     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if obj.type == 'Card' and obj.hasTag("Action Card") and getName(obj) == actionName then
               return true
          end
     end

     return false
end

function getName(obj)
     return obj.getName() .. (obj.hasTag("Adv2p") and "Adv2p" or "")
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
     if zone == selectedActionCardZone then
          refreshButtonHighlights()
     end
end

function onObjectLeaveZone(zone, obj)
     if zone == selectedActionCardZone then
          refreshButtonHighlights()
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

     for i=startInd, endInd do
          self.editButton({
               index = i,
               color = color(0,0,0,0)
          })
     end

     for _, obj in pairs(selectedActionCardZone.getObjects()) do
          if adv2p then
          end

          local ind = adv2pButtonIndex[getName(obj)]

          if ind then
               local name = getName(obj)
               self.editButton({
                    index = adv2p and adv2pButtonIndex[name] + adv2pBtnIndexOffset or buttonIndex[name] + btnIndexOffset,
                    color = color(0,0,0,0.8)
               })
          end
     end
end