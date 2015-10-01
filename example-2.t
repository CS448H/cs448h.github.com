local C = terralib.includecstring [[
    #include<stdio.h>
    #include<stdlib.h>
]]
local function alloc_image_data(w,h)
    local data = C.malloc(3*w*h)
    return terralib.cast(&uint8,data)
end
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
    -- read the data as flat data
    local data = alloc_image_data(image.width,image.height)
    for i = 0,image.width*image.height - 1 do
        data[3*i],data[3*i+1],data[3*i+2] = parseNumber(),parseNumber(),parseNumber()
    end
    image.tree = { kind = "load", data = data }
    assert(cur == nil, "expected EOF")
    return image
end

local headerpattern = [[
P6
%d %d
%d
]]
local function saveppm(image,filename)
    assert(image.tree.kind == "load", "not a reified image")
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
        local r,g,b = image.tree.data[3*i],image.tree.data[3*i+1],image.tree.data[3*i+2]
        writeNumber(r)
        writeNumber(g)
        writeNumber(b)
    end
    F:close()
end

local image = {}
image.__index = image
function image.new(w,h)
    return setmetatable({ width = w, height = h, precision = 255 },image)
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
    result.tree = { kind = "const", value = const }
    return result
end

-- Support constant numbers as images
local function toimage(w,h,x)
  if image.isinstance(x) then
    return x
  elseif type(x) == "number" then
    return image.constant(w,h,x)
  end
  print("HERE")
  terralib.tree.printraw(x)
  return nil
end

local function pointwise(self,rhs,op)
    local model = image.isinstance(self) and self or rhs
    self,rhs = assert(toimage(model.width,model.height,self),"not an image"),assert(toimage(model.width,model.height,rhs),"not an image")
    local result = image.new(self.width,self.height)
    assert(self.width == rhs.width and 
           self.height == rhs.height, "images different size")
    result.tree = { kind = "operator", op = op, lhs = self.tree, rhs = rhs.tree } 
    return result
end

function image:__add(rhs)
    return pointwise(self,rhs,function(x,y) return `x + y end)
end
function image:__sub(rhs)
    return pointwise(self,rhs,function(x,y) return `x - y end)
end
function image:__mul(rhs)
    return pointwise(self,rhs,function(x,y) return `x * y end)
end
function image:__div(rhs)
    return pointwise(self,rhs,function(x,y) return `x / y end)
end
-- generate an image that translates the pixels in the new image 
function image:shift(sx,sy)
    local width,height = self.width,self.height
    local result = image.new(width,height)
    result.tree = { kind = "shift", sx = sx, sy = sy, value = self.tree }
    return result
end

local function compile_image_ir(W,H,tree)
    local terra load_data(data : &uint8, x : int, y : int, c : int) : float
        if x < 0 or x >= W and y < 0 or y >= H then
            return 0.f
        end
        return data[3*(y*W + x) + c]
    end
    local function gen_tree(tree,x,y,c)
        if tree.kind == "const" then
            return `float(tree.value)
        elseif tree.kind == "load" then
            return `load_data(tree.data,x,y,c)
        elseif tree.kind == "operator" then
            local lhs = gen_tree(tree.lhs,x,y,c)
            local rhs = gen_tree(tree.rhs,x,y,c)
            return tree.op(lhs,rhs)
        elseif tree.kind == "shift" then
            local xn,yn = `x + tree.sx,`y + tree.sy
            return gen_tree(tree.value,xn,yn,c) 
        end
    end
    local terra body(data : &uint8) 
        for y = 0,H do
          for x = 0,W do
            for c = 0,3 do
              data[3*(y*W + x) + c] = [ gen_tree(tree,x,y,c) ]
            end
          end
        end
    end
    body:printpretty(true,false)
    body:disas()
    return body
end
function image:reify()
    local result = image.new(self.width,self.height)
    result.tree = { kind = "load", data = alloc_image_data(self.width,self.height) }
    local compiled_function = compile_image_ir(self.width,self.height,self.tree)
    compiled_function(result.tree.data)
    local b = terralib.currenttimeinseconds()
    for i =1,100 do
        compiled_function(result.tree.data)
    end
    local e = terralib.currenttimeinseconds()
    print(self.width,self.height, (e-b)/100, self.width*self.height/(1000*1000) / ((e - b)/100) )
    return result
end

local function printtree(t)
    local function fmt(t)
      if type(t) == "table" and t.kind then
        local str = ("{ kind = %q "):format(t.kind)
        for k,v in pairs(t) do
          if k ~= "kind" then
            str = str .. ", " .. fmt(v)
          end
        end
        return str.." }"
      else return tostring(t)
      end
    end
    return fmt(t)
end

local ifile,ofile = arg[1],arg[2]
local a = image.load(ifile)
local r = (a + a:shift(1,0) + a:shift(0,1) + a:shift(0,-1) + a:shift(-1,0)) / 5.0
print(printtree(r.tree))
r = r:reify()
r:save(ofile)
