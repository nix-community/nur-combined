{ lib
, stdenv
, callPackage
, fetchurl
# feed-specific args
, feedName
, jsonPath
, url
}:

stdenv.mkDerivation {
  pname = feedName;
  version = "20230112";
  src = fetchurl {
    inherit url;
  };
  passthru.updateScript = [ ./update.py url jsonPath ];
  meta = {
    description = "metadata about any feeds available at ${feedName}";
    homepage = feedName;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.all;
  };
}

