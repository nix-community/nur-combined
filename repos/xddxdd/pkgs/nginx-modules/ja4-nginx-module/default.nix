{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "ja4-nginx-module";
  version = "0-unstable-2026-10-26";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "FoxIO-LLC";
    repo = "ja4-nginx-module";
    rev = "99cc308c0b4d03a869fd196b729a6254b18996e1";
    hash = "sha256-ENEgvtzZDJvep0AyOqc+ijoHLhxt8moesPSRDJHxJoY=";
  };

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/FoxIO-LLC/ja4-nginx-module";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "JA4+ TLS fingerprint module for nginx";
    homepage = "https://github.com/FoxIO-LLC/ja4-nginx-module";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
