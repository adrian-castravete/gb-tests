-- GrafX 2 exporter for Gameboy Sprite/Background data.
-- by Adrian Castravete
-- @2017, Adrian Castravete

fileName, filePath = getfilename()

outBase = fileName:match("[^%.]+")
outName = outBase .. ".bin"
outFull = filePath .. "/" .. outName
outPal = outBase .. ".pal"
outPalFull = filePath .. "/" .. outPal

width, height = getpicturesize()
cellsX = width / 8
cellsY = height / 8

function extractChr()
  sanityCheck()

  local out = assert(io.open(outFull, "wb"))
  for j = 1, cellsY do
    for i = 1, cellsX do
      manageTile(out, i, j)
    end
  end
  assert(out:close())
end

function round(value)
  return math.floor(value + 0.5)
end

function extractPal()
  local out = assert(io.open(outPalFull, "wb"))
  for j = 1, 16 do
    for i = 1, 4 do
      local r, g, b = getcolor((j - 1) * 4 + (i - 1))
      local v = round(r / 255 * 31)
      local i = round(g / 255 * 31)
      -- The intermediate value (i) holds the 5 bit value of the green channel
      -- of which we need the first 3 bits for the first byte.
      v = v + (i % 8) * 32
      out:write(string.char(v))
      v = math.floor(i / 8)
      i = round(b / 255 * 31)
      -- Finally the upper two bits of the old intermediate (green) get
      -- combined with the blue bits and written out as the second byte.
      v = v + i * 4
      out:write(string.char(v))
    end
  end
  assert(out:close())
end

function sanityCheck()
  if width < 8 or height < 8 or width % 8 ~= 0 or height % 8 ~= 0 then
    error("Unexpected picture size.\nMust be divisible by 8.\nGot (" .. width .. "x" .. height .. ")")
  end
  local tiles = width * height / 64
  if tiles % 256 ~= 0 or tiles <= 0 then
    error("Number of tiles must be in 256 increments. (" .. tiles .. ")")
  end
end

first = true
function manageTile(out, x, y)
  local tile = {}
  for j = 1, 8 do
    local pixels = {}
    for i = 1, 8 do
      local pixel = getpicturepixel((x - 1) * 8 + i - 1, (y - 1) * 8 + j - 1)
      pixel = pixel % 4
      pixels[#pixels + 1] = pixel
    end
    tile[#tile + 1] = pixels
  end

  for j = 1, 8 do
    local accum = 0
    for i = 1, 8 do
      accum = accum * 2 + tile[j][i] % 2
    end
    out:write(string.char(accum))
    accum = 0
    for i = 1, 8 do
      accum = accum * 2 + math.floor(tile[j][i] / 2)
    end
    out:write(string.char(accum))
  end
end

success, errorStr = pcall(extractChr)
if success then
  success, errorStr = pcall(extractPal)
  if success then
    messagebox("Success!", "Successfully written \"" .. outName .. "\" and \"" .. outPal .. "\".")
  else
    messagebox("Error!", errorStr)
  end
else
  messagebox("Error!", errorStr)
end
