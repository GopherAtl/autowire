require 'defines'


local default_settings={visible=false,copper=true,red=false,green=false}
local settings={}

function showSettings(player)
  local settings=settings[player.name]
  player.gui.left.autowire_flow.add{type="frame",caption="Autowire Settings",name="settings"}
  player.gui.left.autowire_flow.settings.add{type="checkbox",caption="Copper Cable",name="aw_s_copper",state=settings.copper,direction="vertical"}
  player.gui.left.autowire_flow.settings.add{type="checkbox",caption="Red Wire",name="aw_s_red",state=settings.red,direction="vertical"}
  player.gui.left.autowire_flow.settings.add{type="checkbox",caption="Green Wire",name="aw_s_green",state=settings.green,direction="vertical"}
  settings.visible=true
end

function onGuiClick(event)
  local player=game.players[event.player_index]
  local settings=settings[player.name]
  if event.element.name=="autowire" then
    if settings.visible==true then
      player.gui.left.autowire_flow.settings.destroy()
      settings.visible=false
    else
      showSettings(player)
    end
  elseif event.element.name=="aw_s_copper" then
    settings.copper=player.gui.left.autowire_flow.settings.aw_s_copper.state
  elseif event.element.name=="aw_s_red" then
    settings.red=player.gui.left.autowire_flow.settings.aw_s_red.state
  elseif event.element.name=="aw_s_green" then
    settings.green=player.gui.left.autowire_flow.settings.aw_s_green.state
  end
end

electric_pole_types = {
  ["small-electric-pole"]=true,
  ["medium-electric-pole"]=true,
  ["large-electric-pole"]=true,
  ["substation"]=true,
}

function onBuiltEntity(event)
  local entity=event.created_entity
  if electric_pole_types[entity.name] then
    local player=game.players[event.player_index]
    local settings=settings[player.name]
    if settings.red or settings.green then
      local max_red=player.get_item_count("red-wire")
      local max_green=player.get_item_count("green-wire")
      local placed=0

      for i=1,#entity.neighbours.copper do
        local n=entity.neighbours.copper[i]
        if settings.red and placed<max_red then
          entity.connect_neighbour{wire=defines.circuitconnector.red,target_entity=n}
        end
        if settings.green and placed<max_green then
          entity.connect_neighbour{wire=defines.circuitconnector.green,target_entity=n}
        end
        placed=placed+1
      end
      local red_placed=math.min(max_red,placed)
      local green_placed=math.min(max_green,placed)
      if settings.red and red_placed>0 then player.remove_item{name="red-wire",count=red_placed} end
      if settings.green and green_placed>0 then player.remove_item{name="green-wire",count=green_placed} end
    end
    if settings.copper==false then
      entity.disconnect_neighbour()
    end
  end
end

game.on_event(defines.events.on_built_entity, onBuiltEntity)

function load()
  if global.autowire then
    settings=global.autowire
  end

end

function save()
  global.autowire=settings
end

local function copy(table)
  local res={}
  for k,v in pairs(table) do
    res[k]=v
  end
  return res
end

function newPlayer(event)
  local player=game.players[event.player_index]
  if not settings[player.name] then
    settings[player.name]=copy(default_settings)
  end

  local settings=settings[player.name]

  player.gui.left.add{type="flow",name="autowire_flow",direction="horizontal"}
  player.gui.left.autowire_flow.add{type="button", caption="Auto-wires",name="autowire"}

end

game.on_event(defines.events.on_gui_click, onGuiClick)

game.on_event(defines.events.on_player_created,newPlayer)
game.on_init(init)
game.on_load(load)
game.on_save(save)
