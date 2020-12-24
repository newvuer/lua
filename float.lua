local class = require "class"

local type = type
local assert = assert

local fmt = string.format
local tconcat = table.concat

local float = class("float")

function tfloat(obj)
    local ftype = math.type
    local result = obj
    if ftype(obj) == "float" then
        local fir, sec = math.modf(obj)
        if  (sec*1000000 - 1) > 0 then
            sec = math.modf(sec*1000000)
            sec = sec/1000000
            result = fir + sec
        end
        return result
    end
    return nil
end

function float:ctor(opt)
    self.type = "float"
    self.auto_increment = opt.auto_increment   -- 自增
    self.comment = opt.comment                 -- 注释
    self.unsigned = opt.unsigned               -- 无符号
    self.default = opt.default                 -- 默认值
    self.primary = opt.primary                 -- 主键
    self.null = opt.null                       -- NULL
    self.name = opt.name                       -- 字段名
end

-- 验证字段传值有效
function float:verify(x)
    x = assert(tfloat( x) , fmt("`%s` field was passed a invalid value(`Float`).", self.name))
    if self.unsigned then
        return x >= 0 and x <= 340282346638528859811704183484516925440
    end
    return x >= -340282346638528859811704183484516925440 and x <= 340282346638528859811704183484516925440
end

-- 是否为自增
function float:isAutoIncrement()
    return self.auto_increment
end

-- 是否为主键
function float:isPrimary()
    return self.primary
end

-- 字段位置记录
function float:setIndex(index)
    self.index = index
end

-- 将字段转DDL语句
function float:toSqlDefine()
    local DDL = {" "}
    DDL[#DDL+1] = fmt([[`%s`]], assert(type(self.name) == 'string' and self.name ~= '' and self.name, "Invalid field name"))
    DDL[#DDL+1] = self.unsigned and "float UNSIGNED" or "TINYINT"
    DDL[#DDL+1] = self.null and "NULL" or "NOT NULL"
    if self:isPrimary() then
        assert(not self.null, "The `primary` field must be `non-NULL`.")
    end
    if self.default then
        DDL[#DDL+1] = fmt("DEFAULT '%d'", assert(tfloat(self.default), fmt("`%s` field has invalid default value.", self.name)))
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
    return float:new(assert(meta))
end


