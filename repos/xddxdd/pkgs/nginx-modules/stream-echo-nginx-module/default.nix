{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "stream-echo-nginx-module";
  version = "0-unstable-2016-12-18";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "openresty";
    repo = "stream-echo-nginx-module";
    rev = "b7b76b853131b6fa7579d20c2816b4b6abb16bea";
    hash = "sha256-Q7Zv/e296zPcmB+lshBsEXEhtt7TAfRjGgy09uBGxHA=";
  };

  patches = [ ./patches/stream-echo-nginx-module.patch ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/openresty/stream-echo-nginx-module";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "TCP stream echo module for nginx";
    homepage = "https://github.com/openresty/stream-echo-nginx-module";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
