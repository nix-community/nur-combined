local lpeg = require 'lpeg'
local pcommon = require 'parser.common'

local P = lpeg.P
local V = lpeg.V
local C = lpeg.C
local Cg = lpeg.Cg
local Ct = lpeg.Ct
local Cc = lpeg.Cc
-- local B = lpeg.B
local Letter = pcommon.Letter
local Number = pcommon.Number

local Sep = V("Sep")

local spaced = function(...)
    return pcommon.spaced(Sep, ...)
end

local function v(value)
    return function()
        return value
    end
end

local function node(kind)
    return function(...)
        return {
            kind, ...
        }
    end
end

local function consumeUntil(stopWhen, match)
    match = match or P(1)
    return match - stopWhen
end

local sepChar = P" " + pcommon.Newline + P"\t"

local grammar = {"Entry"}
grammar.Sep = sepChar^0
grammar.MustSep = sepChar^1
grammar.Identifier = Letter * (Letter + Number + P'-' + P'_')^0
grammar.PathName = (Letter + Number + P'-' + P'_')^1

grammar.Sym = Cg(V'Identifier') / node('sym')
grammar.RefStage = Cg(V'StringInterpolationStmt' + V'Identifier')

local specialKeywords = P'with'
grammar.Ref = ((Cg(V'Identifier') * (P'.' * Cg(V'RefStage'))^0) - specialKeywords) / node('ref')
grammar.Integer = C(Number ^ 1) / tonumber / node('int')
grammar.Float = C((Number ^ 0) * P"." * (Number ^ 1)) / tonumber / node('float')

grammar.CurrentPath = P'./.'
grammar.PathSegment = P'/' * V'PathName'
grammar.Path = C(
    V'CurrentPath' + (
        ((P".")^-1) *  (V'PathSegment'^1) * (P'/'^-1)
    )
)  / node('path')

-- grammar.Path = Cg(spaced(P"."^2 * (P"/" * (P(1) - "/") ^ 1)^0)) / node('path')
grammar.Boolean = (P"true" * Cc({"boolean", true})) + (P"false" * Cc({"boolean", false}))
grammar.Null = P"null" / v(nil) / node('null')
grammar.List = P"[" * spaced((V"Stmt"))^0 * P"]" / node('list')

local function stringUntil(pattern)
    return consumeUntil(pattern + P'${')^1
end
grammar.StringInterpolationStmt = spaced(P"${", Cg(V'Stmt'), P"}") / node('stringInterpolation')
grammar.StringElemInline = V'StringInterpolationStmt' + Cg(stringUntil(P"\"") / node("text"))
grammar.StringElemMultiline = V'StringInterpolationStmt' + Cg(stringUntil(P"''") / node("text"))
grammar.InlineString = P"\"" * V'StringElemInline'^0 * P"\""
grammar.MultilineString = P"''" * V'StringElemMultiline'^0 * P"''"
grammar.String = Ct(V'InlineString' + V'MultilineString') / node('string')

grammar.Rest = Ct(P(1)^1) / node('rest')
grammar.LetExpr = spaced(
    V'Sym',
    P"=",
    Ct(V'Stmt'),
    P";"
)

grammar.SetItemExpr = spaced(
    Ct(Ct(V'Identifier') * (P'.' * Ct(V'Identifier'))^0) / node('key'),
    P"=",
    Cg(V'Stmt', 'value'),
    P";"
)


grammar.SetExpr = Ct(spaced(P"{", (V'SetItemExpr' / node('setItem')) ^0, P"}"))
grammar.Set = V'SetExpr' / node('set')
grammar.RecursiveSet = V'SetExpr' / node('recursiveSet')

grammar.Let = spaced(
    P'let',
    Ct(Ct(V'LetExpr', "letItem")^0, "vars"),
    P'in',
    Ct(V'Stmt', 'child')
) / node('let')

grammar.ParamItems = spaced(
    Ct(V'Sym', "key"),
    spaced(
        P"?",
        Ct(V'Stmt', "defaultValue")
    )^-1
)

grammar.FunctionParams = Ct(
    spaced(
        P"{",
        Ct(V'ParamItems') / node("param"),
        (spaced(P",", Ct(V'ParamItems')) / node("param"))^0,
        spaced(P",", P'...')^-1,
        P"}" * (P"@" * Cg(V"Sym", "args"))
    ) + (Cg(V"Sym", "args") / node("args"))
)

grammar.FuncCall = Ct(spaced(Ct(V'Ref', 'fnref') * V'MustSep' * Ct(V'Stmt', 'params')^1)) / node('funcCall')

grammar.Function = spaced(V'FunctionParams' * P":", Ct(V"Stmt")) / node('function')

grammar.With = spaced(P'with', Ct(V'Stmt'), P';', Ct(V'Stmt')) / node('with')

grammar.Stmt = spaced(
   V'Path' + V'Let' + V'With' + V'List' + V'Set' + V'FuncCall' + V'Function' + V'Float' + V'Integer' +  V'Boolean' + V'Null' +  V'String' + V'Ref' + V'MustSep'
)/node('stmt')

grammar.Entry = Cg(V'Stmt') -- * V'Rest'

return grammar
