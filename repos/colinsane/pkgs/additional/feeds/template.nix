{ lib
, stdenv
, fetchurl
, update-feed
}:

# feed-specific args
{ feedName, jsonPath, url }:

stdenv.mkDerivation {
  pname = feedName;
  version = "20230112";
  src = fetchurl {
    inherit url;
  };
  passthru.updateScript = {
    name = "feed-update-script";
    command = [ "${update-feed}/bin/update.py" url jsonPath ];
  };
  meta = {
    description = "metadata about any feeds available at ${feedName}";
    homepage = feedName;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.all;
  };
}

