# Replace entries with matching tags, retaining unrelated subscription entries.
def overlay_tags($extra):
  ($extra | map(.tag)) as $tags
  | map(select(.tag as $tag | $tags | index($tag) | not)) + $extra;

if type != "object" or (.outbounds | type != "array" or length == 0) then
  error("subscription must contain a non-empty outbounds array")
else
  .services as $subscriptionServices
  | . * $local[0]
  | .services = (
      [($subscriptionServices // [])[] | select(.type != "api")]
      | overlay_tags($local[0].services // [])
    )
  | del(.experimental.clash_api)
  | if $ovpn then
      $vpn[0] as $overlay
      | .endpoints = ((.endpoints // []) | overlay_tags($overlay.endpoints))
      | .dns.servers = ((.dns.servers // []) | overlay_tags($overlay.dns.servers))
      | .dns.rules = ($overlay.dns.rules + (.dns.rules // []))
      # Sniffing and DNS interception must precede the VPN's learned routes.
      | .route.rules = (
          (.route.rules // []) as $rules
          | ($rules | map(.action != "sniff" and .action != "hijack-dns")
              | index(true) // length) as $offset
          | $rules[:$offset] + $overlay.route.rules + $rules[$offset:]
        )
    else . end
end
