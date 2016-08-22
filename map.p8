pico-8 cartridge // http://www.pico-8.com
version 4
__lua__
-- map screen

-- math constants
pi = 3.14159265359

-- game constants
planets = {}
center = 64
orbits = {0, 15, 35, 55}
min_planet_distance = 7

function _init()
  -- createPlanets
  for o=1,#orbits do
    local num_planets = o == 1 and 1 or rnd(o) + o * 2
    for p=1,num_planets do create_planet(orbits[o], o) end
  end

  -- createConnections
  foreach(planets, connect_planet)
end

function _update()
end

function _draw()
  cls()

  -- draw orbits
  for orbit in all(orbits) do
    circ(center, center, orbit, 5)
  end

  -- draw planets
  foreach(planets, draw_planet_connections)
  foreach(planets, draw_planet)
end

function draw_planet(planet)
  -- draw a circle at the planets coords
  circfill(planet.x, planet.y, 3, 12)
end

function draw_planet_connections(planet)
  -- draw a line from the planet to its neighbors
  for neighbor in all(planet.neighbors) do
    line(planet.x, planet.y, neighbor.x, neighbor.y, 6)
  end
end

-- planet init

function create_planet(radius, orbit)
  local valid = false
  local x, y
  while(valid == false) do 
    local angle = rnd(pi*2);
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
    neighbors = {}
  }
  add(planets, planet)
end

function validate_planet(x, y)
  -- make sure this planet wont be too close to any others
  for planet in all(planets) do
    if(distance(x, y, planet.x, planet.y) < min_planet_distance) then
      return false
    end
  end
  return true
end

function generate_planet_name()
  return 'poop'
end

function connect_planet(planet)
  -- connect with closest neighbor
  -- connect with closest lower orbit
  -- might be able to save some tokens by putting this in the same
  -- loop as in 'validate_planet'
  -- but that would draw worse connections

  -- find neighbors
  local same_neighbor, lower_neighbor
  local same_dist, lower_dist = 1000, 1000
  if planet.orbit == 1 then return end
  for neighbor in all(planets) do
    local dist = distance(neighbor.x, neighbor.y, planet.x, planet.y)
    if dist ~= 0 then -- dont consider yourself your closest neighbor
      if neighbor.orbit == planet.orbit and dist < same_dist then
        same_dist = dist
        same_neighbor = neighbor
      elseif neighbor.orbit == (planet.orbit - 1) and dist < lower_dist then
        lower_dist = dist
        lower_neighbor = neighbor
      end
    end
  end

  -- make connections
  connect_planets(same_neighbor, planet)
  connect_planets(planet, same_neighbor)

  connect_planets(lower_neighbor, planet)
  connect_planets(planet, lower_neighbor)
end

function connect_planets(planet, neighbor)
  if(indexOf(planet.neighbors, neighbor) == -1) then
   add(planet.neighbors, neighbor) 
  end
end

-- math functions

function distance(x1, y1, x2, y2)
  return sqrt(sqr(x1 - x2) + sqr(y1 - y2))
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


__gfx__
