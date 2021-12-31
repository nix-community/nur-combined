local M = {}

local function normalizeContext(ctx, new)
    if not ctx then
        return "root"
    else
        if new then
            return ctx .. "." .. "new"
        else
            return ctx
        end
    end
end

local function must(condition, value, expectedType, ctx)
    if not condition then
        error("invalid value: " .. tostring(value) .. " is not a " .. expectedType .. " on " .. ctx)
    end
end

local function mustPrimitiveType(value, expectedType, ctx)
    must(type(value) == expectedType, value, expectedType, ctx)
end

local function primitiveValidator(primitiveType)
    return function()
        return function(value, ctx)
            ctx = normalizeContext(ctx)
            mustPrimitiveType(value, primitiveType, ctx)
            return value
        end
    end
end

M.string = primitiveValidator("string")
M.fn = primitiveValidator("function")
M.null = primitiveValidator("nil")
M.boolean = primitiveValidator("boolean")
M.number = primitiveValidator("number")
M.primitiveType = primitiveValidator

function M.compose(...)
    local args = ...
    return function(value, ctx)
        for _, v in pairs(args) do
            value = v(value, ctx)
        end
        return value
    end
end

function M.range(a, b)
    b = b or a
    return function(value, ctx)
        must(b >= value and a <= value, value, "a <= x <= b", ctx)
        return value
    end
end

function M.truthy()
    return function(value, ctx)
        must(value, value, "truthy", ctx)
        return value
    end
end

function M.falsy()
    return function(value, ctx)
        must(not value, value, "falsy", ctx)
        return value
    end
end

function M.table(child)
    return function (value, ctx)
        local ret = {}
        for k, v in pairs(child) do
            print(k)
            ctx = normalizeContext(ctx, k)
            if v == nil then
                error("validator keys should never be null on " .. ctx)
            end
            ret[k] = v(value[k], ctx)
        end
        return ret
    end
end
return M
