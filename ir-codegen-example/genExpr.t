local symtab = {}
local function gen(e)
  if e.kind == 'val' then
    return `[e.value]
  elseif e.kind == 'binop' then
    local lhs = gen(e.lhs)
    local rhs = gen(e.rhs)
    if e.op == '+' then
      return `[lhs] + [rhs]
    elseif e.op == '*' then
      return `[lhs] * [rhs]
    elseif e.op == '-' then
      return `[lhs] - [rhs]
    elseif e.op == '/' then
      return `[lhs] / [rhs]
    end
  elseif e.kind == 'let' then
    local oldsym = symtab[e.name]
    local sym = symbol(e.name)
    symtab[e.name] = sym
    local res = quote
      var [sym] = [gen(e.val)]
    in [gen(e.e)] end
    symtab[e.name] = oldsym
    return res
  elseif e.kind == 'var' then
    return `[symtab[e.name]]
  end
end

local function run(e)
  local terra doit()
    return [gen(e)]
  end
  doit:printpretty(false)
  doit:disas()
  return doit()
end

local function reload()
  package.loaded.genExpr = nil
  return require('genExpr')
end

return { reload = reload, run = run, gen = gen }
