function createButtons()
    self.createButton({
         click_function = "none",
         function_owner = self,
         label = "0",
         width = 0,
         height = 0,
         position = {-0.82, 0.2, -0.4},
         font_size = 600,
         scale = {0.5, 0.5, 0.5},
    })

    self.createButton({
         click_function = "none",
         function_owner = self,
         label = "+0",
         width = 0,
         height = 0,
         position = {-0.72, 0.2, 0.5},
         font_size = 400,
         scale = {0.5, 0.5, 0.5},
         font_color = "Red"
    })

    self.createButton({
         click_function = "none",
         function_owner = self,
         label = "0",
         width = 0,
         height = 0,
         position = {0.5, 0.2, 0.02},
         font_size = 1000,
         scale = {0.5, 0.5, 0.5},
         font_color = color(1,1,1)
    })
end

function updateLabel(params)
    if not self.getButtons() then
         return
    end

    type = params[1]
    value = params[2]

    if type == "hand" then
         self.editButton({
              index = 0,
              label = value
         })
    elseif type == "military" then
         local prefix = "+"
         if value < 0 then
              prefix = ""
         end
         self.editButton({
              index = 1,
              label = prefix .. value
         })
    elseif type == "vp" then
         self.editButton({
              index = 2,
              label = value
         })
    end
end