local class = require "class"

local type = type
local assert = assert

local fmt = string.format
local tconcat = table.concat

local double = class("double")

function tdouble(obj)
    local ftype = math.type
    local result = obj
    if ftype(obj) == "float" then
        if obj == math.modf(obj) then
            return nil
        end
        result = fmt("%.15f", obj)
        return result
    end
    return nil
end

function double:ctor(opt)
    self.type = "double"
    self.auto_increment = opt.auto_increment   -- 自增
    self.comment = opt.comment                 -- 注释
    self.default = opt.default                 -- 默认值
    self.primary = opt.primary                 -- 主键
    self.null = opt.null                       -- NULL
    self.name = opt.name                       -- 字段名
end

-- 验证字段传值有效
function double:verify(x)
    x = assert(tdouble( x) , fmt("`%s` field was passed a invalid value(`double`).", self.name))
    return x >= -340282346638528859811704183484516925440 and x <= 340282346638528859811704183484516925440
end

-- 是否为自增
function double:isAutoIncrement()
    return self.auto_increment
end

-- 是否为主键
function double:isPrimary()
    return self.primary
end

-- 字段位置记录
function double:setIndex(index)
    self.index = index
end

-- 将字段转DDL语句
function double:toSqlDefine()
    local DDL = {" "}
    DDL[#DDL+1] = fmt([[`%s`]], assert(type(self.name) == 'string' and self.name ~= '' and self.name, "Invalid field name"))
    DDL[#DDL+1] = self.unsigned and "double UNSIGNED" or "TINYINT"
    DDL[#DDL+1] = self.null and "NULL" or "NOT NULL"
    if self:isPrimary() then
        assert(not self.null, "The `primary` field must be `non-NULL`.")
    end
    if self.default then
        DDL[#DDL+1] = fmt("DEFAULT '%d'", assert(tdouble(self.default), fmt("`%s` field has invalid default value.", self.name)))
    end
    if self.auto_increment then
        DDL[#DDL+1] = "AUTO_INCREMENT"
    end
    if self.comment then
        DDL[#DDL+1] = fmt("COMMENT '%s'", self.comment)
    end
    return tconcat(DDL, " ")
end

return function (meta)
    return double:new(assert(meta))
end


