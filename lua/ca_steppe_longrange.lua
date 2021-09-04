local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag
local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"


local ca_longrange = {}
local longrange_unit
local target
local rand

-- Move transport ships according to these rules:
-- 1. If transport can get to its designated landing site this move, find
--    close hex with the most unoccupied adjacent non-water hexes and move there
-- 2. If landing site is out of reach, move toward destination while
--    staying in deep water surrounded by deep water only
-- Also unload units onto best hexes adjacent to landing site

function wesnoth.custom_synced_commands.longrange_attack(cfg)
--    local unit = wesnoth.get_unit(cfg.x, cfg.y)
    wesnoth.fire_event("steppe_longrangedattack", cfg.x, cfg.y, cfg.x2, cfg.y2, {})
end


function longrange_get_species(cfg)
    local abilities = wml.get_child(cfg.__cfg, "abilities")
    local longrange_ability = wml.get_child(abilities, "longrange")
    return longrange_ability.species
end

function ca_longrange:evaluation()
--        wesnoth.message("longrange evaluation")


--    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }

    local units = wesnoth.get_units { side = wesnoth.current.side, { "has_attack", { special = "steppe_longrange" }} }

-- TODO: add a check so that longranged attacks can't be used on units adjacent to the longrange unit

    for i,u in ipairs(units) do
--        wesnoth.message("longrange unit detected")
--        if (u.side == wesnoth.current.side) and steppe_has_ability(u, "longrange") and not steppe_has_ability(u, "longrange_transformed") then
        if (u.side == wesnoth.current.side) and u.attacks_left > 0 then

                local will_attack = false
            
                local filter_second = { { "filter_side", { { "enemy_of", { side = wesnoth.current.side } } } } }
                local enemies = AH.get_live_units {
                    { "and", filter_second },
                    { "filter_location", { x = u.x, y = u.y, radius = 3 } },
                    { "filter_vision", { side = wesnoth.current.side, visible = 'yes' } }
                }
                        
                local enemies_found = false
            
                if not enemies[1] then else
                    enemies_found = true
                end
            
            --    wesnoth.message(enemies_found)
            --    wesnoth.message(species)
            
            --transform raven into human with enemies nearby
                if enemies_found == true then


                    will_attack = true
                    rand = math.random(1, #enemies)
                end
            
            if will_attack == true then
                longrange_unit = u
                target = enemies[rand]

--                debug_utils.dbms(target, true, "tmp build loc", true)
                return 300000
            end
        end
    end

    return 0
end

function ca_longrange:execution()
--        wesnoth.message("longrange execution")

--    wesnoth.message("the longrange ai is executed for side " .. wesnoth.current.side)

        local orig_attacks_left = longrange_unit.attacks_left

--        wesnoth.message("longrange unit transformed")
            local command_data = { x = longrange_unit.x, y = longrange_unit.y, x2 = target.x, y2 = target.y}
            wesnoth.invoke_synced_command("longrange_attack", command_data)

--local new_species = longrange_get_species(longrange_unit)


          if longrange_unit.attacks_left < orig_attacks_left then
             steppe_force_gamestate_change(ai)
          end

--        wesnoth.message("longrange unit not found")

end

return ca_longrange
