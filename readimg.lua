local PNG_HEADER = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a}
local PNG_HEADER_LENGTH = 8
local IHDR_TYPE = {0x49, 0x48, 0x44, 0x52}
local CHUNK_LENGTH_SIZE = 4
local CHUNK_TYPE_SIZE = 4
local CRC_SIZE = 4
local IMAGE_HEADER_LENGTH = 13
local IHDR_WIDTH_SIZE = 4
local IHDR_HEIGHT_SIZE = 4
local IHDR_BIT_DEPTH_SIZE = 1
local IHDR_COLOR_TYPE_SIZE = 1
local IHDR_COMPRESSION_METHOD_SIZE = 1
local IHDR_FILTER_METHOD_SIZE = 1
local IHDR_INTERLACE_METHOD_SIZE = 1

PngImage = {}
PngImage.__index = PngImage

function PngImage:readbytes(bytes)
  self.bytes = {}
  self.value = 0
  for i = 1, bytes do
    self.index = self.index + 1
    self.value = math.floor(self.value*2^8)
    local byte = self.content:byte(self.index)
    self.bytes[i] = byte
    self.value = self.value + byte
  end
end

function PngImage:checkbytes(expected)
  if #expected ~= #self.bytes then
    return false
  end
  for i = 1, #expected do
    if self.bytes[i] ~= expected[i] then
      return false
    end
  end
  return true
end

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
  if string.len(self.content) < PNG_HEADER_LENGTH then
    error('Invalid PNG header, too short')
  end
  self:readbytes(PNG_HEADER_LENGTH)
  if not self:checkbytes(PNG_HEADER) then
    error('Invalid PNG header')
  end
end

function PngImage:imgheader()
  self:readbytes(CHUNK_LENGTH_SIZE)
  if self.value ~= IMAGE_HEADER_LENGTH then
    error('Invalid IHDR chunk incorrect length')
  end

  self:readbytes(CHUNK_TYPE_SIZE)
  if not self:checkbytes(IHDR_TYPE) then
    error('First chunk is not IHDR type')
  end

  self:readbytes(IHDR_WIDTH_SIZE)
  self.width = self.value

  self:readbytes(IHDR_HEIGHT_SIZE)
  self.height = self.value

  self:readbytes(IHDR_BIT_DEPTH_SIZE)
  self.bitdepth = self.value

  self:readbytes(IHDR_COLOR_TYPE_SIZE)
  self.colortype = self.value

  self:readbytes(IHDR_COMPRESSION_METHOD_SIZE)
  self.compression = self.value

  self:readbytes(IHDR_FILTER_METHOD_SIZE)
  self.filter = self.value

  self:readbytes(IHDR_INTERLACE_METHOD_SIZE)
  self.interlace = self.value
end

pngimg = PngImage:create('./test.png')
