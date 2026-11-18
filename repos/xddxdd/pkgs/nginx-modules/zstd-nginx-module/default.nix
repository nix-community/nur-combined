{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
  zstd,
}:

mkNginxPlugin (finalAttrs: {
  pname = "zstd-nginx-module";
  version = "0-unstable-2026-11-17";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "HanadaLee";
    repo = "ngx_http_zstd_module";
    rev = "33324b7e365b65a0b157973c07d48a12b69749de";
    hash = "sha256-+KeGd8P86tRGmoG8EttYQXnyG7WOfiBXIAci1gWHAyI=";
  };

  buildInputs = [ zstd ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/HanadaLee/ngx_http_zstd_module";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "HTTP zstd compression module for nginx";
    homepage = "https://github.com/HanadaLee/ngx_http_zstd_module";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
