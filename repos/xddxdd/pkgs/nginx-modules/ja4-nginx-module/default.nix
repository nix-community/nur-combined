{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "ja4-nginx-module";
  version = "0-unstable-2026-10-12";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "FoxIO-LLC";
    repo = "ja4-nginx-module";
    rev = "cd16673ded88fcb7f5ca2d3cca2235b1be046b16";
    hash = "sha256-JJq9QIxhSlw+kS9Rnes3IJOdErQaN0MZXM9qziccT04=";
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
