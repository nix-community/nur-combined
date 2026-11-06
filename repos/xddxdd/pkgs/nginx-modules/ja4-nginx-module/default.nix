{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "ja4-nginx-module";
  version = "0-unstable-2026-11-05";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "FoxIO-LLC";
    repo = "ja4-nginx-module";
    rev = "50bd33092d819c8145b677acc28112c62449692b";
    hash = "sha256-fpUVMVLeIZs0cIXEol+p7ktXlbJ3AAAL4xVXStwwD2I=";
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
