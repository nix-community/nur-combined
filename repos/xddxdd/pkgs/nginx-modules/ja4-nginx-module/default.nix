{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "ja4-nginx-module";
  version = "0-unstable-2026-11-06";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "FoxIO-LLC";
    repo = "ja4-nginx-module";
    rev = "116d2b27a63c8b3251b1f03a0b81758ad6b754fe";
    hash = "sha256-FEvq9emmPJ+BesQlVG9u4FnS92Rq5J9GgxN0JNzkj/I=";
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
