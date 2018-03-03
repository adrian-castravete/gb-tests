-- GrafX 2 unique tile count chechker for Gameboy
-- by Adrian Castravete
-- @2018, Adrian Castravete

function getTile(x, y)
  local tile = {}

  for j=1, 8 do
    local r = 0
    for i=1, 8 do
      r = r * 4 + (getpicturepixel((x-1)*8 + i-1, (y-1)*8 + j-1) % 4)
    end
    tile[j] = r
  end

  return tile
end

function insertUnique(tiles, tile)
  local found = nil

  for i=1, #tiles do
    local item = tiles[i]
    local same = true

    for r=1, 8 do
      if item[r] ~= tile[r] then
        same = false
        break
      end
    end

    if same then
      found = i
      break
    end
  end

  if not found then
    tiles[#tiles + 1] = tile
  end
end

local width, height = getpicturesize()
local gameboy = "gameboy "

if width ~= 160 or height ~= 144 then
  gameboy = ''
end

local tiles = {}
local nwidth = math.floor(width / 8)
local nheight = math.floor(height / 8)

if nwidth ~= width / 8 or nheight ~= height / 8 then
  local message = "Width or Height isn't a multiple of 8. (%s, %s)"
  messagebox("Warning!", message:format(width, height))
end

for j=1, nheight do
  for i=1, nwidth do
    local tile = getTile(i, j)

    insertUnique(tiles, tile)
  end
end

messagebox("Statistics", "This " .. gameboy .. "image contains " .. #tiles .. " unique tiles.")
