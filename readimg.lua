local PNG_HEADER = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a}
local CHUNK_LENGTH_SIZE = 4
local CHUNK_TYPE_SIZE = 4
local CRC_SIZE = 4

PngImage = {}
PngImage.__index = PngImage

function PngImage:create(path)
  local img = {}
  setmetatable(img, PngImage)
  img.path = path
  img.index = 0
  img:read()
  return img
end

function PngImage:read()
  local file = assert(io.open(self.path, 'rb'))
  local content = file:read('*all')
  file:close()
  self.content = content
  self:fileheader()
  self:imgheader()
end

function PngImage:fileheader()
  if string.len(self.content) < #PNG_HEADER then
    error('Invalid PNG header, too short')
  end
  for i=1, #PNG_HEADER do
    self.index = self.index + 1
    if self.content:byte(self.index) ~= PNG_HEADER[i] then
      error('Invalid PNG header at byte' .. i)
    end
  end
end

function PngImage:imgheader()
  local length = 0
  for i=1, CHUNK_LENGTH_SIZE do
    self.index = self.index + 1
    local byte = self.content:byte(self.index)
    length = length + math.floor(byte*2^(8*(chunk_length_size - i)))
  end
  local chunk_type = 0
  for i = i, CHUNK_TYPE_SIZE do
    self.index = self.index + 1
    
  end
end

pngimg = PngImage:create('./test.png')
