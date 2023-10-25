-- simple proof-of-concept Prosody module
-- module development guide: <https://prosody.im/doc/developers/modules>
-- module API docs: <https://prosody.im/doc/developers/moduleapi>
--
-- much of this code is lifted from Prosody's own `mod_cloud_notify`

local jid = require"util.jid";

local ntfy = module:get_option_string("ntfy_binary", "ntfy");
local ntfy_topic = module:get_option_string("ntfy_topic", "xmpp");

module:log("info", "initialized");

local function is_urgent(stanza)
  if stanza.name == "message" then
    if stanza:get_child("propose", "urn:xmpp:jingle-message:0") then
      return true, "jingle call";
    end
  end
end

local function publish_ntfy(message)
  -- message should be the message to publish
  local ntfy_url = string.format("https://ntfy.uninsane.org/%s", ntfy_topic)
  local cmd = string.format("%s pub %q %q", ntfy, ntfy_url, message)
  module.log("debug", "invoking ntfy: %s", cmd)
  local success, reason, code = os.execute(cmd)
  if not success then
    module:log("warn", "ntfy failed: %s => %s %d", cmd, reason, code)
  end
end


local function archive_message_added(event)
  -- event is: { origin = origin, stanza = stanza, for_user = store_user, id = id }
  local stanza = event.stanza;
  local to = stanza.attr.to;
  to = to and jid.split(to) or event.origin.username;

  -- only notify if the stanza destination is the mam user we store it for
  if event.for_user == to then
    local is_urgent_stanza, urgent_reason = is_urgent(event.stanza);

    if is_urgent_stanza then
      module:log("info", "urgent push for %s (%s)", to, urgent_reason);
      publish_ntfy(urgent_reason)
    end
  end
end


module:hook("archive-message-added", archive_message_added);
