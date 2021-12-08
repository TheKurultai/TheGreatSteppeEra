--#textdomain wesnoth-gse
_ = wesnoth.textdomain "wesnoth-gse"

-- NOTE: this check the ability TAG, not ability id
function steppe_has_ability(unit, ability)
    -- Returns true/false depending on whether unit has the given ability
    local has_ability = false
    local abilities = wml.get_child(unit.__cfg, "abilities")
    if abilities then
        if wml.get_child(abilities, ability) then has_ability = true end
    end
    return has_ability
end

function steppe_attach_unit_status_renderer()
  local old_unit_weapons = wesnoth.theme_items.unit_weapons
  function wesnoth.theme_items.unit_weapons()
    local s = old_unit_weapons()
    local u = wesnoth.get_displayed_unit()
    if u then
--        wesnoth.message("unit exists check passed")
      if steppe_has_ability(u, "devourer_of_souls") == true then
  
        table.insert(s, { "element", {
          text = _"Collected Souls: ".. (u.variables.collected_souls and (tostring(u.variables.collected_souls)) or "0").."\n",
          tooltip = _"The souls this unit collects are used for the 'devourer of souls' ability"
        } })
      end

      if steppe_has_ability(u, "birther_of_fiends") == true then
        if u.variables.birthturns and u.variables.birthturns > 0 then
  
         local birthtext_disabled = wesnoth.get_variable("steppe_disable_birthturntext")

          if birthtext_disabled ~= "yes" then
  
            table.insert(s, { "element", {
              text = _"Turns until birth: ".. (u.variables.birth_turns_left and (tostring(u.variables.birth_turns_left))).."\n",
              tooltip = _"Number of turns until a kanavar is birthed and added to the recall list"
            } })
          end
        end
      end

--not really needed at the moment, as adaptive strike is unused
--      if steppe_has_ability(u, "adaptive_armor") == true then
--  
--       local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")
--  
--        if russian_enabled then
--        table.insert(s, { "element", {
--          text = "Адаптивная Броня: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
--          tooltip = "Количество адаптивной брони которую этот юнит накопил. Важно для других способнотей как например 'апаптивный щит'"
--        } })
--        else
--        table.insert(s, { "element", {
--          text = "Adapative Armor: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
--          tooltip = "Amount of adaptive armor this unit currently has (used for other abilities like 'adaptive shield')"
--        } })
--        end
--      end

--      if steppe_has_ability(u, "duel") == true then
--        if u.variables.duel_turns_left and u.variables.duel_turns_left > 0 then
--  
--          table.insert(s, { "element", {
--            text = _"Inspiration turns left: ".. (u.variables.duel_turns_left and (tostring(u.variables.duel_turns_left)) or "0").."\n",
--            tooltip = _"Number of turns until the inspiration from the 'duel' ability wears off"
--          } })
--        end
--      end


      if steppe_has_ability(u, "idol_buff") == true then
        if u.variables.idolbuff_turns_left and u.variables.idolbuff_turns_left > 0 then
  
          table.insert(s, { "element", {
            text = _"Idol turns left: ".. (u.variables.idolbuff_turns_left and (tostring(u.variables.idolbuff_turns_left)) or "0").."\n",
            tooltip = _"Number of turns until the damage bonus from an idol wears off"
          } })
        end
      end

      if steppe_has_ability(u, "kingdomfaction") == true or u.variables.faith then

        local faith_name = {}
        local heresy_name = {}

        local faith = 0
--        local heresy = 0

        local max_faith = 3
--        local max_heresy = 4

--        local is_heretic = false

       if u.variables.faith then
          faith = u.variables.faith
       end

--for debugging
       if u.variables.faith > max_faith then
          faith = 99
       end

--       if u.variables.faith < 0 then
--          is_heretic=true
--          heresy = u.variables.faith * -1
--
--          faith = 99
--       end
-- 
--       if heresy > max_heresy then
--          heresy = 99
--       end

          faith_name[0] = _"Godless"
          faith_name[1] = _"Believer"
          faith_name[2] = _"Faithful"
          faith_name[3] = _"Pious"
--          faith_name[4] = "Fanatic"
          faith_name[99] = _"ERROR: TOO HIGH FAITH"

--          heresy_name[1] = "Godless"
--          heresy_name[2] = "Sinner"
--          heresy_name[3] = "Apostate"
--          heresy_name[4] = "Heretic"
--          heresy_name[99] = "ERROR: TOO HIGH HERESY"

 --         if heresy > 0 then
 --         table.insert(s, { "element", {
 --           text = "Heresy: ".. (heresy and (tostring(heresy)) or "0").." ("..heresy_name[heresy]..")".."\n",
 --           tooltip = "The unit gains an invisuble backstab-like weapon special that deals 25% more damage per level of heresy. Also, at heresy 3 and higher, the unit becomes chaotic."
 --         } })
 --         else
          table.insert(s, { "element", {
            text = _"Faith: ".. (u.variables.faith and (tostring(u.variables.faith)) or "0").." ("..faith_name[faith]..")".."\n",
            tooltip = _"Gives different effects based on faith level:\n".."1 - unit becomes lawful\n".."2 - unit becomes fearless and gains self-unpoison, but also gets pride 15\n".."3 - unit gains the soul fire ability, but also gets pride 25\n"
          } })
--         end


              if u.variables.faith < max_faith then
    
              table.insert(s, { "element", {
                text = _"Sermons left: ".. (u.variables.sermons_left and (tostring(u.variables.sermons_left)) or "0").."\n",
                tooltip = _"The amount of sermons until the unit's faith level increases by 1"
              } })
    
              end

      end

    end
    return s
  end
end

function steppe_find_enslave_level(variable)
--   wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/ravana_inspect_table.lua"
   helper = wesnoth.require "lua/helper.lua"
   local attack = wesnoth.get_variable(variable)
--   inspect_table({attack}, {})
   local specials = helper.get_child(attack, "specials")
   local special = helper.get_child(specials, "enslave")
--   wesnoth.message("unit enslave level:",special.enslave_level)
   return special.enslave_level   
end

function steppe_find_enslave_nonliving(variable)
--   wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/ravana_inspect_table.lua"
   helper = wesnoth.require "lua/helper.lua"
   local attack = wesnoth.get_variable(variable)
--   inspect_table({attack}, {})
   local specials = helper.get_child(attack, "specials")
   local special = helper.get_child(specials, "enslave")
--   wesnoth.message("unit enslave level:",special.enslave_level)
   return special.works_on_nonliving
end


function steppe_check_overlay_x1_y1(overlay_img)

--checks the variables of a unit at x1,y1

local overlayunit = wesnoth.get_unit(wesnoth.current.event_context.x1, wesnoth.current.event_context.y1)

for overlay in overlayunit.__cfg.overlays:gmatch("[^,]+") do
    if overlay:match("^%s*(.-)%s*$") == overlay_img then
        --return a yes value, to show that the unit does have the overlay
        return true
    end
end

end



-- Force a gamestate change


--note: this won't be needed if/when I switch to 1.16, but it is necessary in 1.14
function steppe_force_gamestate_change(ai)
    -- Can be done using any unit of the AI side; works even if the unit already has 0 moves
    local unit = wesnoth.get_units { side = wesnoth.current.side }[1]
    local cfg_reset_moves = { id = unit.id, moves = unit.moves }
    ai.stopunit_moves(unit)
    wesnoth.invoke_synced_command('reset_moves', cfg_reset_moves)
end

function wesnoth.custom_synced_commands.reset_moves(cfg)
    local unit = wesnoth.get_units { id = cfg.id }[1]
    unit.moves = cfg.moves
end