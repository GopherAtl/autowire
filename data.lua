data:extend({
    {
        type = "font",
        name = "autowire_tiny_font",
        from = "default",
        size = 10,
    },
    {
        type = "font",
        name = "autowire_small_font",
        from = "default",
        size = 14,
    },
    {
        type = "font",
        name = "autowire_title_font",
        from = "default",
        size = 14,
    },
})

local small_button_style = {
    type = "button_style",
    parent = "button_style",
    font = "autowire_small_font",
    scalable = false,
    top_padding = 2,
    bottom_padding = 2,
    left_padding = 2,
    right_padding = 3,
}

local tiny_button_style = {
    type = "button_style",
    parent = "button_style",
    font = "autowire_tiny_font",
    scalable = false,
    width = 18,
    height = 18,
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,
}

local frame_style = {
    type="frame_style",
    parent="frame_style",
    font = "autowire_title_font",
    scalable=false,
    top_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    right_padding = 0,
  }

data.raw["gui-style"].default["autowire_small_button_style"] = small_button_style
data.raw["gui-style"].default["autowire_tiny_button_style"] = tiny_button_style
data.raw["gui-style"].default["autowire_frame_style"] = frame_style
data.raw["gui-style"].default["checkbox_5"] = {type="checkbox_style",parent="checkbox_style",size=5}
data.raw["gui-style"].default["checkbox_10"] = {type="checkbox_style",parent="checkbox_style",size=10}
data.raw["gui-style"].default["checkbox_15"] = {type="checkbox_style",parent="checkbox_style",size=15}