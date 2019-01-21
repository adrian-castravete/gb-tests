#!/usr/bin/env lua

local fin = assert(io.open(arg[1], "rb"))
local data = {}

local sum = -25
local chSum = 0
repeat
  local inStr = fin:read(4096)
  for c in (inStr or ''):gmatch"." do
    data[#data+1] = c:byte()
  end
until not inStr
fin:close()

for i=1, #data do
  if i > 0x134 and i <= 0x14d then
    sum = sum - data[i]
  end
  if not (i == 0x14f or i == 0x150) then
    chSum = chSum + data[i]
  end
end

data[0x14e] = sum % 256
data[0x14f] = math.floor(chSum / 256) % 256
data[0x150] = chSum % 256

local outStr = ''
for i=1, #data do
  outStr = outStr..string.char(data[i])
end

local fout = assert(io.open(arg[1], "wb"))
fout:write(outStr)
fout:close()
