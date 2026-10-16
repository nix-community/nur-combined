{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
  zstd,
}:

mkNginxPlugin (finalAttrs: {
  pname = "zstd-nginx-module";
  version = "0-unstable-2026-09-25";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "HanadaLee";
    repo = "ngx_http_zstd_module";
    rev = "d35686b29b9fb6a65db6091c365775b45ca93200";
    hash = "sha256-hY+WKddcyilMsUj8MMCUrQG2PDSN2HriEvpRMDUvF1Q=";
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
