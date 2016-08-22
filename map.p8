pico-8 cartridge // http://www.pico-8.com
version 4
__lua__
-- map screen

-- math constants
pi = 3.14159265359

planets = {}
center = 64
orbits = {0, 15, 35, 55}
min_distance = 7

function _init()
  -- createPlanets
  for o=1,count(orbits) do
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
  for i=1,count(orbits) do
    circ(center, center, orbits[i], 5)
  end

  -- draw planets
  foreach(planets, draw_planet)
end

function draw_planet(planet)
  circ(planet.x, planet.y, 3, 12)
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
    orbit = orbit
  }
  add(planets, planet)
end

-- make sure this planet wont be too close to any others
function validate_planet(x, y)
  for p=1,count(planets) do
    local planet = planets[p]
    if(distance(x, y, planet.x, planet.y) < min_distance) then
      return false
    end
  end
  return true
end

function generate_planet_name()
  return 'poop'
end

-- connect with closest neighbor
-- connect with closest lower orbit
function connect_planet(planet)
  local neighbor
  local lower_orbit
  if planet.orbit == 1 then return end

end

-- math functions

function distance(x1, y1, x2, y2)
  return sqrt(sqr(x1 - x2) + sqr(y1 - y2))
end

function sqr(x)
  return x * x
end


__gfx__
