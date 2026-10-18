{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
  zstd,
}:

mkNginxPlugin (finalAttrs: {
  pname = "zstd-nginx-module";
  version = "0-unstable-2026-10-18";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "HanadaLee";
    repo = "ngx_http_zstd_module";
    rev = "1c0d3f96708c86afeebd7d9778504f77c7893227";
    hash = "sha256-h5iEd2cuDsm3ymcjlJkiQkZimpGiEO+o9kBHG2OQKsU=";
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
