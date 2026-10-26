def origin:
  capture("^https://(?<host>[A-Za-z0-9.-]+)(?<port>:[0-9]+)?(?:[/?#]|$)")
  | "https://" + (.host | ascii_downcase) + (if .port == ":443" then "" else (.port // "") end);

def selected($roots; $target):
  (map({key: .tag, value: .selected}) | from_entries) as $groups
  | def reaches($tag; $seen):
      if $tag == $target then true
      elif $tag == null or ($seen | index($tag)) != null or ($seen | length) >= 32 then false
      else reaches($groups[$tag]; $seen + [$tag]) end;
    any($roots[]; reaches(.; []));

def credential($encoding):
  if $encoding == "gopass-base64" then
    if test("(?im)^Content-Transfer-Encoding: *base64\\r?$") then
      split("\n") | map(select(test("(?i)^Content-") | not)) | join("") | gsub("[\\r\\n]"; "")
      | if length > 0 and test("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$") then . else error("credentials") end
    else error("credentials") end
  elif $encoding == "text" then
    sub("[\\r\\n]+$"; "")
    | if length > 0 and (test("[\r\n\u0000]") | not) then . else error("credentials") end
  else error("encoding") end;

def submission($endpoint; $challenge; $gateway):
  . as $session
  | if (.gateway | origin) != ($gateway | origin) then error("gateway") else . end
  | {endpointTag: $endpoint, challengeID: $challenge.id,
      browser: ({cookies: [
        $challenge.browser.cookieNames[] as $name
        | $session.cookies[$name] as $value
        | if ($value | type) != "string" or ($value | length) == 0 or ($value | test("[\r\n\u0000;]"))
          then error("cookie") else {name: $name, value: $value} end
      ]} + if ($challenge.browser.finalURL // "") == "" then {} else {finalURL: $challenge.browser.finalURL} end)};
