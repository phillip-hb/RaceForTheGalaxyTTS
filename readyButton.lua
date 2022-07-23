isReady = false

function onSave()
    local saved_data = {}
    saved_data.isReady = isReady
    return JSON.encode(saved_data)
end

function onload(saved_data)
     if saved_data ~= "" then
          local data = JSON.decode(saved_data)
          isReady = data.isReady
     end

     self.createButton({
          click_function = "toggleState",
          function_owner = self,
          width = 800,
          height = 800,
          color = color(0, 0, 0, 0),
          tooltip = "Ready"
     })

     self.createButton({
          click_function = "toggleState",
          function_owner = self,
          width = 800,
          height = 800,
          rotation = {0, 0, 180},
          color = color(0, 0, 0, 0),
          tooltip = "Ready"
     })
end

function toggleState(obj, _, rightClick)
     if rightClick or Global.getVar("gameStarted") == false then
          return
     end

     isReady = not isReady
     Global.call("updateReadyButtons", {player, isReady, true})
end

function setToggleState(ready)
     local rot = self.getRotation()
     isReady = ready

     if isReady then
          self.setRotation({rot[1], rot[2], 0})
     else
          self.setRotation({rot[1], rot[2], 180})
     end
end