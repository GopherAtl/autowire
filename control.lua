require 'defines'
require 'config'


local default_settings={visible=false,copper=true,red=false,green=false}
local settings={}

local mod_version="0.1.3"


local function copy(table)
  local res={}
  for k,v in pairs(table) do
    res[k]=v
  end
  return res
end

local function getPlayerSettings(player)
  if settings[player.name]==nil then
    settings[player.name]=copy(default_settings)
    createMainGUI(player)
  end
  return settings[player.name]

end

function showSettings(player)
  local settings=getPlayerSettings(player)
  player.gui.top.autowire_flow.add{type="frame",caption="",name="settings",direction="vertical", style="autowire_frame_style"}
  player.gui.top.autowire_flow.settings.add{type="checkbox",caption="Copper",name="aw_s_copper",state=settings.copper,direction="vertical",style="checkbox_5"}
  player.gui.top.autowire_flow.settings.add{type="checkbox",caption="Red",name="aw_s_red",state=settings.red,direction="vertical",style="checkbox_10"}
  player.gui.top.autowire_flow.settings.add{type="checkbox",caption="Green",name="aw_s_green",state=settings.green,direction="vertical",style="checkbox_15"}
  settings.visible=true
end

function createMainGUI(player)
  local settings=getPlayerSettings(player)
  player.gui.top.add{type="flow",name="autowire_flow",direction="vertical"}
  player.gui.top.autowire_flow.add{type="button", caption="Auto-wires",name="autowire",style="autowire_small_button_style"}
  if settings.visible then
    showSettings(player)
  end
end

function onGuiClick(event)
  local player=game.players[event.player_index]
  local settings=getPlayerSettings(player)
  if event.element.name=="autowire" then
    if settings.visible==true then
      player.gui.top.autowire_flow.settings.destroy()
      settings.visible=false
    else
      showSettings(player)
    end
  elseif event.element.name=="aw_s_copper" then
    settings.copper=player.gui.top.autowire_flow.settings.aw_s_copper.state
  elseif event.element.name=="aw_s_red" then
    settings.red=player.gui.top.autowire_flow.settings.aw_s_red.state
  elseif event.element.name=="aw_s_green" then
    settings.green=player.gui.top.autowire_flow.settings.aw_s_green.state
  end
end

local excluded_types = {}

for i=1,#wiring_exceptions do
  excluded_types[wiring_exceptions[i]]=true
end

function onBuiltEntity(event)
  local entity=event.created_entity
  if entity.type=="electric-pole" and not excluded_types[entity.name] then
    local player=game.players[event.player_index]
    local settings=getPlayerSettings(player)
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
    if global.autowire.version==nil then
      settings=global.autowire

      for k,v in pairs(game.players) do
        if v.gui.left.autowire_flow then
          v.gui.left.autowire_flow.destroy()
        end
        createMainGUI(v)
      end
    else
      settings=global.autowire.settings
    end
  else
    if pcall(function() p=game.player end) then
      --single-player!
      settings[game.player.name]=copy(default_settings)
      createMainGUI(game.player)
    else
      for k,v in pairs(game.players) do
        settings[v.name]=copy(default_settings)
        createMainGUI(v)
      end
    end
  end
end

function save()
  global.autowire={version=mod_version,settings=settings}
end

function newPlayer(event)
  local player=game.players[event.player_index]
  if not settings[player.name] then
    settings[player.name]=copy(default_settings)
  end

  createMainGUI(player)

end

game.on_event(defines.events.on_gui_click, onGuiClick)

game.on_event(defines.events.on_player_created,newPlayer)
game.on_init(load)
game.on_load(load)
game.on_save(save)
