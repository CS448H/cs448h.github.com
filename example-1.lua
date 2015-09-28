local function loadppm(filename)
    local F = assert(io.open(filename,"rb"),"file not found")
    local cur
    local function next()
        cur = F:read(1)
    end
    next()
    local function isspace()
        return cur and (cur:match("%s") or cur == "#")
    end
    local function isdigit()
        return cur and cur:match("%d")
    end
    local function parseWhitespace()
        assert(isspace(), "expected at least one whitespace character")
        while isspace() do 
            if cur == "#" then 
                repeat
                    next()
                until cur == "\n"
            end
            next() 
        end
    end 
    local function parseInteger()
        assert(isdigit(), "expected a number")
        local n = ""
        while isdigit() do
            n = n .. cur
            next()
        end
        return assert(tonumber(n),"not a number?")
    end
    assert(cur == "P", "wrong magic number")
    next()
    assert(cur == "6", "wrong magic number")
    next()
    
    local image = {}
    parseWhitespace()
    image.width = parseInteger()
    parseWhitespace()
    image.height = parseInteger()
    parseWhitespace()
    image.precision = parseInteger()
    assert(image.precision > 0 and image.precision < 2^16)
    assert(isspace(), "expected whitespace after precision")
    next()
    local function parseNumber()
        assert(cur ~= nil, "early EOF")
        local n = string.byte(cur)
        next()
        if image.precision >= 256 then
            n = n * 256
            n = n + string.byte(cur)
            next()
        end
        return n
    end
    local function parseRGB()
        return { r = parseNumber(), g = parseNumber(), b = parseNumber() }
    end
    image.data = {}
    for i = 0,image.width*image.height - 1 do
        image.data[i] = parseRGB()
    end
    assert(cur == nil, "expected EOF")
    return image
end

local headerpattern = [[
P6
%d %d
%d
]]
local function saveppm(image,filename)
    local F = assert(io.open(filename,"w"), "file could not be opened for writing")
    F:write(string.format(headerpattern, image.width, image.height, image.precision))
    local function writeNumber(v)
        assert(type(v) == "number","NaN?")
        v = math.floor(v)
        v = math.max(0,math.min(v,image.precision))
        if image.precision >= 256 then
            F:write(string.char(math.floor(v/256)),string.char(v % 256))
        else
            F:write(string.char(v))
        end
    end
    for i = 0, image.width*image.height - 1 do
        local p = image.data[i]
        writeNumber(p.r)
        writeNumber(p.g)
        writeNumber(p.b)
    end
    F:close()
end

local image = {}
image.__index = image
function image.new(w,h)
    return setmetatable({ width = w, height = h, precision = 255, data = {} },image)
end
function image.isinstance(x) return getmetatable(x) == image end
function image.load(filename)
    return setmetatable(loadppm(filename),image)
end
function image:save(filename)
    saveppm(self,filename)
end

function image.constant(width,height,const)
    local result = image.new(width,height)
    for i = 0, result.width * result.height - 1 do
        result.data[i] = { r = const, g = const, b = const }
    end
    return result
end

-- Support constant numbers as images
local function toimage(w,h,x)
  if image.isinstance(x) then
    return x
  elseif type(x) == "number" then
    return image.constant(w,h,x)
  end
  return nil
end

local function pointwise(self,rhs,op)
    local model = image.isinstance(self) and self or rhs
    self,rhs = assert(toimage(model.width,model.height,self),"not an image"),assert(toimage(model.width,model.height,rhs),"not an image")
    local result = image.new(self.width,self.height)
    assert(self.width == rhs.width and 
           self.height == rhs.height, "images different size")
    for i = 0, self.width * rhs.height - 1 do
        local l,r = self.data[i],rhs.data[i]
        result.data[i] = { r = op(l.r,r.r), g = op(l.g,r.g), b = op(l.b,r.b) }
    end
    return result
end

function image:__add(rhs)
    return pointwise(self,rhs,function(x,y) return x + y end)
end
function image:__sub(rhs)
    return pointwise(self,rhs,function(x,y) return x - y end)
end
function image:__mul(rhs)
    return pointwise(self,rhs,function(x,y) return x * y end)
end
function image:__div(rhs)
    return pointwise(self,rhs,function(x,y) return x / y end)
end
-- generate an image that translates the pixels in the new image 
function image:shift(sx,sy)
    local width,height = self.width,self.height
    local result = image.new(width,height)
    for x = 0,width-1 do
        for y = 0,height-1 do
            local fx,fy = x - sx,y - sy
            local p = { r = 0, g = 0, b = 0 }
            if fx >= 0 and fx < width and fy >= 0 and fy < height then
                p = self.data[fy*width+fx]
            end
            if not p then
                print(x,y,sx,sy,fx,fy)
            end
            result.data[y*width+x] = p
        end
    end
    return result
end
local ifile,ofile = arg[1],arg[2]
local a = image.load(ifile)
local r = (a + a:shift(1,0) + a:shift(0,1) + a:shift(0,-1) + a:shift(-1,0)) / 5.0
r:save(ofile)
