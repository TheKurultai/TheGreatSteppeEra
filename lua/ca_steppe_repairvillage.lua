local H = wesnoth.require "helper"
local AH = wesnoth.require "ai/lua/ai_helper.lua"
local LS = wesnoth.require "location_set"
local M = wesnoth.map
local T = wml.tag
local debug_utils = wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/debug_utils.lua"
wesnoth.require "~add-ons/1The_Great_Steppe_Era/lua/ravana_inspect_table.lua"

local ca_repairvillage = {}
local repairer_unit
local repair_x
local repair_y
local destroyed_villages
local repair_locations
local repairloc_number

-- Move transport ships according to these rules:
-- 1. If transport can get to its designated landing site this move, find
--    close hex with the most unoccupied adjacent non-water hexes and move there
-- 2. If landing site is out of reach, move toward destination while
--    staying in deep water surrounded by deep water only
-- Also unload units onto best hexes adjacent to landing site

function wesnoth.custom_synced_commands.repair_village(cfg)
--    local unit = wesnoth.get_unit(cfg.x, cfg.y)
    wesnoth.set_variable("tmp_repair_y", repair_y)
    wesnoth.set_variable("tmp_repair_x", repair_x)
--    wesnoth.fire_event("steppe_customevent_repairing", cfg.x, cfg.y, {id = unit.id})
--    wesnoth.message(repair_id,repair_x)
--    wesnoth.message(repair_y)
--    wesnoth.message("steppe_repair_event_"..repair_id)
    wesnoth.fire_event("steppe_customevent_repairvillage", repair_x, repair_y, {})
end


function ca_repairvillage:evaluation()
--        wesnoth.message("repairing evaluation")

--    local units = wesnoth.get_units { side = wesnoth.current.side, formula = 'movement_left > 0' }
    local units = wesnoth.get_units { side = wesnoth.current.side, ability = "steppe_repair_village"}

    destroyed_villages = H.get_variable_array "destroyed_village_information"

--    debug_utils.dbms(destroyed_villages, true, "destroyed villages", true)

    if #destroyed_villages > 0 then

    for i,u in ipairs(units) do
--        wesnoth.message("repairing unit detected")
-- todo: add an a check whether the unit has enough moves too, tho maybe under this check
        if (u.side == wesnoth.current.side) then

            local can_repair = false
            local will_repair = false

            local tmp_repaircost = wesnoth.get_variable("steppe_village_repaircost")

--THIS CODE ISN'T REALLY NEEDED ANYMORE, AS I HAVE A SIMPLER SOLUTION
--                local village_distance
--                local closest_distance, location = 9e99
--
--                for e,destroyed_vill in ipairs(destroyed_villages) do
--
--                    village_distance = M.distance_between(u.x, u.y, destroyed_vill.x, destroyed_vill.y)
--                    if (village_distance < closest_distance) then
--
----    debug_utils.dbms(village_distance, true, "village distance", true)
--
--                        closest_distance = village_distance
--                        repairloc_number = e
--                    end
--
----    debug_utils.dbms(destroyed_villages[repairloc_number], true, "village distance", true)
--
--
--
--                end


            if (u.moves / u.max_moves) >= 0.66 and wesnoth.sides[wesnoth.current.side].gold >= tmp_repaircost then
--               repairoptions_usable = repairoptions

                can_repair = true
            end

-- if there is an option to repair, do an additional check for available tiles (just in case a unit can afford to repair but the adjacent tiles are occupied)
            if can_repair == true then


        repair_locations = wesnoth.get_locations {
            { "and", { x = u.x, y = u.y, radius = 1}},
            { "and", { find_in = "destroyed_village_information" } }
        }

--    debug_utils.dbms(repair_locations, true, "repair locations", true)


--        LS.of_pairs(
--        )

--            {
--            { "and", { x = u.x, y = u.y, radius = 1 }},
--            { "and", { 
--                { "not", { "filter" {} }}
--             }
--            }
--         }



--        debug_utils.dbms(repair_locations, true, "repair locations", true)

--            repair_locations = repair_locations:to_stable_pairs()

--        debug_utils.dbms(repair_locations, true, "repair locations", true)

            if #repair_locations > 0 then

--            debug_utils.dbms(repairloc_number, true, "repairloc number", true)

-- if there is no closest enemy, choose a random tile to repair on
            if repairloc_number then else
                repairloc_number = math.random(1, #repair_locations)
            end


                will_repair = true
            end


            end


            if will_repair == true then
--                wesnoth.message(repair_locations[rand][1])

                repairer_unit = u
                repair_x = repair_locations[repairloc_number][1]
                repair_y = repair_locations[repairloc_number][2]
                return 300000
            end
        end
    end
    end

    return 0
end

function ca_repairvillage:execution()
--        wesnoth.message("repairing execution")
        local repair_successful = false

--    wesnoth.message("the repairing ai is executed for side " .. wesnoth.current.side)

        local tmp_repair_tile_terrain = wesnoth.get_terrain(repair_x, repair_y)

--        debug_utils.dbms(tmp_repair_tile_terrain, true, "repair tile", true)



--        wesnoth.message("repairing unit transformed")
            local command_data = { repair_x = repair_x, repair_y = repair_y }
            wesnoth.invoke_synced_command("repair_village", command_data)

        local tmp_repair_tile_terrain2 = wesnoth.get_terrain(repair_x, repair_y)



        if tmp_repair_tile_terrain ~= tmp_repair_tile_terrain2 then
            repair_successful = true
        end


          if repair_successful == true then
             steppe_force_gamestate_change(ai)
--             wesnoth.message("gamestate changed")
          end



--        wesnoth.message("repairing unit not found")


end

return ca_repairvillage
