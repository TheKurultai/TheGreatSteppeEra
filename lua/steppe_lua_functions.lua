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
  
       local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")
  
        if russian_enabled then
        table.insert(s, { "element", {
          text = "Собранные Души: ".. (u.variables.collected_souls and (tostring(u.variables.collected_souls)) or "0"),
          tooltip = "Души собранные этим бойцом для способности 'пожиратель душ'"
        } })
        else
        table.insert(s, { "element", {
          text = "Collected Souls: ".. (u.variables.collected_souls and (tostring(u.variables.collected_souls)) or "0"),
          tooltip = "The souls this unit collects are used for the 'devourer of souls' ability"
        } })
        end
      end

      if steppe_has_ability(u, "birther_of_fiends") == true then
        if u.variables.birthturns and u.variables.birthturns > 0 then
  
         local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")

         local birthtext_disabled = wesnoth.get_variable("steppe_disable_birthturntext")

          if birthtext_disabled ~= "yes" then
  
            if russian_enabled then
            table.insert(s, { "element", {
              text = "Ходы до рождения: ".. (u.variables.birth_turns_left and (tostring(u.variables.birth_turns_left))),
              tooltip = "Количество ходов до того как канавара рождается и добавляется в список призыва"
            } })
            else
            table.insert(s, { "element", {
              text = "Turns until birth: ".. (u.variables.birth_turns_left and (tostring(u.variables.birth_turns_left))),
              tooltip = "Number of turns until a kanavar is birthed and added to the recall list"
            } })
            end
          end
        end
      end

      if steppe_has_ability(u, "adaptive_armor") == true then
  
       local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")
  
        if russian_enabled then
        table.insert(s, { "element", {
          text = "Адаптивная Броня: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
          tooltip = "Количество адаптивной брони которую этот юнит накопил. Важно для других способнотей как например 'апаптивный щит'"
        } })
        else
        table.insert(s, { "element", {
          text = "Adapative Armor: ".. (u.variables.adaptive_armor_stacks and (tostring(u.variables.adaptive_armor_stacks)) or "0"),
          tooltip = "Amount of adaptive armor this unit currently has (used for other abilities like 'adaptive shield')"
        } })
        end
      end

      if steppe_has_ability(u, "duel") == true then
        if u.variables.duel_turns_left and u.variables.duel_turns_left > 0 then
  
       local russian_enabled = wesnoth.get_variable("steppe_hunntext_russian_enabled")
  
          if russian_enabled then
          table.insert(s, { "element", {
            text = "Ходы вдохновления: ".. (u.variables.duel_turns_left and (tostring(u.variables.duel_turns_left)) or "0"),
            tooltip = "Колечество ходов после которых вдохноление от способности 'поединок' исчезает"
          } })
          else
          table.insert(s, { "element", {
            text = "Inspiration turns left: ".. (u.variables.duel_turns_left and (tostring(u.variables.duel_turns_left)) or "0"),
            tooltip = "Number of turns until the inspiration from the 'duel' ability wears off"
          } })
          end
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


--edit of the AH function so it works for the build CA properly

