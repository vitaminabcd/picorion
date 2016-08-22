pico-8 cartridge // http://www.pico-8.com
version 4
__lua__
-- map screen

-- math constants
pi = 3.14159265359

planets = {}
center = 64
orbits = {0, 15, 35, 55}
inner_radius = 15
mid_radius = 35
outer_radius = 55
min_distance = 5

function _init()
  -- createPlanets
  for i=1,count(orbits) do
    local num_planets = i == 1 and i or rnd(i) + i * 3
    for j=1,num_planets do create_planet(orbits[i], i) end
  end
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

function create_planet(radius, level)
  local valid = false
  while(valid == false) do 
    local angle = rnd(pi*2);
    local x = cos(angle) * radius + center
    local y = sin(angle) * radius + center
    valid = validate_planet(x, y)
  end

  local planet = {
    discovered = false,
    name = generate_planet_name(),
    x = x,
    y = y,
    level = level
  }
  add(planets, planet)
end

function validate_planet(x, y)
  for i=1,count(planets) do
    local planet = planets[i]
    local dist = distance(x, y, planet.x, planet.y)
    if(dist < min_distance) then
      return false
    end
  end
  return true
end

function generate_planet_name()
  return 'poop'
end

function distance(x1, y1, x2, y2)
  return sqrt(sqr(x1 - x2) + sqr(y1 - y2))
end

function sqr(x)
  return x * x
end


__gfx__
