#!/usr/bin/env -S NIX_BUILD_SHELL=/bin/sh nix-shell
--[[
#!nix-shell -i wpexec ../../../../../integrations/nix-shell --arg f 'ps: [ ps.wireplumber ]'
--]]
--
-- this script notices whenever an app links to a microphone,
-- and duplicates that link for the Mic Effects node.
-- thus, anything recording from a real mic also gets the Mic Effects.
--
-- places to reference:
-- - wireplumber src/scripts/lua
-- - <https://www.reddit.com/r/Bazzite/comments/1rmhw5h/wireplumber_application_routing_success_with/>

dumputils = require("./dump-common")

-- this object manager knows about all mic nodes we wish to follow.
-- mic_effects itself is omitted from this
mic_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "=", "Audio/Source", type = "pw-global" },
    -- do not consider virtual items created by WirePlumber
    Constraint { "wireplumber.is-virtual", "!", true, type = "pw" },
  }
}
mic_om:activate()

-- this object manager knows only about the mic_effects.sink node
mic_effects_sink_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.name", "=", "mic_effects.sink", type = "pw-global" },
  }
}
mic_effects_sink_om:activate()

-- this object manager knows only about the mic_effects.source node
mic_effects_source_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "node.name", "=", "mic_effects.source", type = "pw-global" },
  }
}
mic_effects_source_om:activate()

mic_effects_source_ports_om = ObjectManager {
  Interest {
    type = "port",
    Constraint { "port.alias", "=", "Mic Effects:output_MONO", type = "pw-global" },
  }
}
mic_effects_source_ports_om:activate()

get_mic_effects_sink = function()
  return mic_effects_sink_om:lookup { }
end

get_mic_effects_source = function()
  return mic_effects_source_om:lookup { }
end

get_mic_effects_source_port = function()
  -- assume Mic Effects exposes only one output port
  return mic_effects_source_ports_om:lookup { }
end

is_mic = function(node_id)
  local mic_node = mic_om:lookup {
    Constraint { "object.id", "=", node_id },
  }
  return mic_node ~= nil
end

-- Hook to force a specific set of applications to send their output *to* mic_effects
SimpleEventHook {
  name = "redirect-output-to-mic-effects",
  before = "linking/find-defined-target",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "node-added" },
      -- these are the nodes to send into mic_effects
      Constraint { "node.name", "c", "DTMFtool", type = "pw-global" },
    },
  },
  execute = function (event)
    print("redirecting output into mic_effects", dumputils:dump_event(event))
    local node = event:get_subject()
    local source = event:get_source()
    local metadata_om = source:call("get-object-manager", "metadata")

    local metadata = metadata_om:lookup {
      Constraint { "metadata.name", "=", "default" }
    }
    local target = get_mic_effects_sink()
    if metadata and target then
      metadata:set(node["bound-id"], "target.object", "Spa:Id", target.properties["object.serial"])
      print("redirected output to: ", target.properties["object.serial"])
    end
  end
}:register()

-- Hook to monitor everything which links to a real microphone, and supplement its input with mic_effects.source
SimpleEventHook {
  name = "duplicate-input-with-mic-effects",
  interests = {
    EventInterest {
      Constraint { "event.type", "c", "link-added", "link-removed" },
    },
  },
  execute = function (event)
    print(dumputils:dump_event(event))
    local link = event:get_subject()
    print("link:", dumputils:dump_gobject(link))
    local props = event:get_properties()
    if not is_mic(props["link.output.node"]) then
      print("link source != mic: uninteresting")
      return
    end
    if props["event.type"] == "link-added" then
      local mic_effects = get_mic_effects_source()
      print(dumputils:dump_gobject(mic_effects))
      local mic_effects_port = get_mic_effects_source_port()
      print(dumputils:dump_gobject(mic_effects_port))

      local new_props = {
        ["link.output.node"] = mic_effects.properties["object.id"],
        ["link.output.port"] = mic_effects_port.properties["object.id"],
        -- ["link.output.port"] = link.properties["link.output.port"],
        ["link.input.node"] = link.properties["link.input.node"],
        ["link.input.port"] = link.properties["link.input.port"],

        -- bennetthardwick says he needed object.id = nil, but it seems optional to me.
        -- ["object.id"] = nil,
        -- without object.linger = true, the link doesn't actually appear in the graph
        ["object.linger"] = true,
        ["node.description"] = "Mic Effects auto-follow link",
      }
      print("making link... ", dumputils:dump_table(new_props))
      local link = Link("link-factory", new_props)
      print("made link: ", link)
      -- TODO: what's this parameter to `link:activate`?
      print("activated: ", link:activate(1))
      -- local link = SessionItem ("si-standard-link")
      -- link:configure { }
    elseif props["event.type"] == "link-removed" then
      print("TODO: remove the Mic Effects link")
    end
    -- dump_mic_if_linked(event)
    -- dump_event_nodes(event)



    -- local link = event:get_subject ()
    -- local eprops = event:get_properties ()
    -- local source = event:get_source ()
    -- local node = source:get_associated_proxy ("node")
    -- print("link: ", dumputils:dump_table(link))
    -- -- print("props: ", dumputils:dump_table(eprops))
    -- print("node: ", type(node))
    -- print("node: ", dumputils:dump_table(node))
    -- print("source: ", type(source))
    -- print("source: ", dumputils:dump_table(getmetatable(source)))
  end
}:register()

-- dump_mic_if_linked = function(event)
--   -- local source = event:get_source()
--   -- local node_om = source:call("get-object-manager", "node")
--   -- local link = event:get_subject ()
--   -- local out_stream_id = link.properties["link.output.node"]
--   -- local out_node = node_om:lookup {
--   -- local out_stream_id = link.properties["link.output.node"]
--   local out_stream_id = event:get_properties()["link.output.node"]
--   local out_node = mic_om:lookup {
--     Constraint { "object.id", "=", out_stream_id },
--   }
--   if out_node ~= nil then
--     print("mic node: ", dumputils:dump_gobject(out_node))
--   else
--     print("(no mic node)")
--   end
-- end
-- 
-- dump_event_nodes = function(event)
--   local source = event:get_source()
--   local node_om = source:call("get-object-manager", "node")
--   local link = event:get_subject ()
-- 
--   local in_stream_id = link.properties["link.input.node"]
--   local in_node = node_om:lookup {
--     Constraint { "object.id", "=", in_stream_id }
--   }
--   print("input node: ", dumputils:dump_gobject(in_node))
-- 
--   local out_stream_id = link.properties["link.output.node"]
--   local out_node = node_om:lookup {
--     Constraint { "object.id", "=", out_stream_id }
--   }
--   print("output node: ", dumputils:dump_gobject(out_node))
-- end

print("autolink-mic-effects: activated")
