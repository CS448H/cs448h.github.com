local function newclass(name)
    local cls = {}
    cls.__index = cls
    function cls.new(tbl)
        return setmetatable(tbl,cls)
    end
    function cls.isinstance(x) 
        return getmetatable(x) == cls 
    end
    function cls:__tostring()
        return "<"..name..">"
    end
    return cls
end

local expr = newclass("expr")

-- const (x)
function expr.val(x)
  return expr.new { kind = 'val', value = x }
end

-- a [op] b
function expr.binop(op, a, b)
  assert(op == '+' or op == '-' or op == '*' or op == '/')
  assert(expr.isinstance(a) and expr.isinstance(b))
  return expr.new { kind = 'binop', op = op,  lhs = a, rhs = b}
end

-- let name = val in e
function expr.let(name, val, e)
  assert(expr.isinstance(val), expr.isinstance(e))
  return expr.new { kind = 'let', name = name, val = val, e = e }
end

-- dereference name
function expr.varRef(name)
  return expr.new { kind = 'var', name = name }
end

function expr:__tostring()
  if self.kind == 'binop' then
    return '('..tostring(self.lhs)..self.op..tostring(self.rhs)..')'
  elseif self.kind == 'val' then
    return tostring(self.value)
  elseif self.kind == 'let' then
    return '(let '..self.name..' = '..tostring(self.val)..' in\n  '..
           tostring(self.e)..')'
  elseif self.kind == 'var' then
    return self.name
  else
    assert(false, "Don't understand expr kind '"..tostring(self.kind).."'")
  end
end

function expr.__add( self, rhs )
  return expr.binop('+', self, rhs)
end

function expr.__sub( self, rhs )
  return expr.binop('-', self, rhs)
end

function expr.__mul( self, rhs )
  return expr.binop('*', self, rhs)
end

function expr.__div( self, rhs )
  return expr.binop('/', self, rhs)
end

return expr