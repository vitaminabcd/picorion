pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- map screen

-- utility constants
pi = 3.14159265359

-- game constants
planets = {}
center = 64
orbits = {0, 15, 35, 55}
min_planet_distance = 7
origin = nil

-- mapscreen globals
selected = nil
current = nil

function _init()
  -- createPlanets
  for o=1,#orbits do
    local extra_planets = o == 4 and 1 or o -- want fewer planets on the outside
    local num_planets = o == 1 and 1 or rnd(o) + extra_planets
    for p=1,num_planets do create_planet(orbits[o], o) end
  end
  origin = planets[1]

  -- createConnections
  origin.connected = true
  foreach(planets, connect_planet)

  origin.current = true

  -- this would normally go in the map screens init
  for planet in all(planets) do
    if planet.current then
      selected = planet
      current = planet
      break
    end
  end
end

function create_planet(radius, orbit)
  -- planet init
  local valid = false
  local x, y
  while(valid == false) do 
    local angle = rnd();
    x = cos(angle) * radius + center
    y = sin(angle) * radius + center
    valid = validate_planet(x, y)
  end

  local planet = {
    discovered = false,
    name = generate_planet_name(),
    x = x,
    y = y,
    orbit = orbit,
    connected = false,
    neighbors = {}
  }
  add(planets, planet)
end

function validate_planet(x, y)
  -- make sure this planet wont be too close to any others
  for planet in all(planets) do
    if(v_distance({x=x, y=y}, planet) < min_planet_distance) return false 
  end
  return true
end

function generate_planet_name()
  return 'poop'
end

function connect_planet(planet)
  -- recursively connect all planets with the origin planet
  --
  -- just keep connecting planets with their neighbors until
  -- you reach a planet that is already connected
  -- note that the origin planet starts out 'connected'
  if (planet.connected) return true
  local closest_neighbor
  local closest_dist = 1000
  for neighbor in all(planets) do
   local dist = v_distance(neighbor, planet)
    -- dont connect planet with itself, or any neighbor connected to
   if dist ~= 0
   and indexOf(planet.neighbors, neighbor) == -1
   and (planet.orbit - neighbor.orbit < 2) then
     if dist < closest_dist then
       closest_dist = dist
       closest_neighbor = neighbor
     end
   end
  end

 add(planet.neighbors, closest_neighbor) 
 add(closest_neighbor.neighbors, planet) 
 
 planet.connected = connect_planet(closest_neighbor)
end

function move_selection(dir)
  -- move the selection around the map. seems huge.
  -- find the nearest planet in the correct direction
  -- among the list of the current planets neighbors
  -- (including the current planet)
  local candidate_selection
  local candidate_dist = 1000
  local axis = (dir == 0 or dir == 1) and 'x' or 'y'
  local selectable = copy_table(current.neighbors)
  add(selectable, current)
  for planet in all(selectable) do
    local candidate = false
    if (dir == 0 or dir == 2) then
      candidate = (planet[axis] < selected[axis])
    else
      candidate = (planet[axis] > selected[axis])
    end

    local dist = v_distance(selected, planet)
    if candidate and (dist <= candidate_dist) then
      candidate_dist = dist
      candidate_selection = planet
    end
  end
  if (candidate_selection) selected = candidate_selection
end

function _update()
  -- left
  if btnp(0) then
   move_selection(0)
  end

  -- right
  if btnp(1) then
   move_selection(1)
  end

  -- up
  if btnp(2) then
   move_selection(2)
  end

  -- down
  if btnp(3) then
   move_selection(3)
  end
end

function _draw()
  cls()

  -- draw orbits
  --for orbit in all(orbits) do
  --  circ(center, center, orbit, 5)
  --end

  -- draw planet connections
  foreach(planets, draw_planet_connections)

  -- draw selection box
  rectfill(selected.x - 3, selected.y - 3, selected.x + 3, selected.y + 3, 11) 

  -- draw planets
  foreach(planets, draw_planet)
end

function draw_planet(planet)
  -- draw a circle at the planets coords
  local color = planet.current and 12 or 13 
  circfill(planet.x, planet.y, 3, color)
  circfill(planet.x, planet.y, 2, 0)
end

function draw_planet_connections(planet)
  -- draw a line from the planet to its neighbors
  for neighbor in all(planet.neighbors) do
    line(planet.x, planet.y, neighbor.x, neighbor.y, 6)
  end
end

-- utility functions

function distance(x1, y1, x2, y2)
  return sqrt(sqr(x1 - x2) + sqr(y1 - y2))
end

function v_distance(t1, t2)
  return sqrt(sqr(t1.x - t2.x) + sqr(t1.y - t2.y))
end

function sqr(x)
  return x * x
end

function indexOf(t, object)
  for i=1,#t do
    if object == t[i] then
      return i
    end
  end
  return -1
end

function copy_table(orig)
  local copy = {}
  for orig_key, orig_value in pairs(orig) do
    copy[orig_key] = orig_value
  end
  return copy
end

__gfx__
