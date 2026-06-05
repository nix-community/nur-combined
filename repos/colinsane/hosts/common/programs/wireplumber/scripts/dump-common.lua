local mod = {}

function mod:dump_table(t)
  local s = '{\n'
  for k,v in pairs(t) do
     if type(k) ~= 'number' then k = '"'..k..'"' end
     s = s .. '  ['..k..'] = ' .. self:dump_one(v) .. ',\n'
  end
  return s .. '}'
end

function mod:dump_event(event)
  return self:dump_table(event:get_properties())
end

function mod:dump_gobject(obj)
  -- this function is for WpLink, WpNode, WpPort, etc.
  -- `getmetadata(obj).__name` shows `GObject`, but idk if this is actually generic
  -- to all GObject or just to wireplumber objects.
  return self:dump_table(obj.properties)
end

function mod:dump_userdata(obj)
  if obj.properties then
    return self:dump_gobject(obj)
  elseif obj.get_properties then
    -- XXX this might not be safe
    return self:dump_event(obj)
  else
    return tostring(obj)
  end
end

function mod:dump_one(o)
  if type(o) == 'table' then
    return self:dump_table(o)
  elseif type(o) == 'userdata' then
    return self:dump_userdata(o)
  else
    return tostring(o)
  end
end

function mod:dump_om(om)
  om:connect("object-added", function (om, obj)
    print(self:dump_gobject(obj) .. '\n\n')
  end)

  om:activate()
end

return mod
