{
  fetchFromGitHub,
  lib,
  mkNginxPlugin,
  unstableGitUpdater,
}:

mkNginxPlugin (finalAttrs: {
  pname = "ngx_http_js_challenge_module";
  version = "0-unstable-2023-03-17";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "simon987";
    repo = "ngx_http_js_challenge_module";
    rev = "da6852df4103492f9136ef814cda0c7d402e0a90";
    hash = "sha256-CaOO8naCyq26GFjlCf8s1xL9Nccwb/zVgnDZ0f+mKU8=";
  };

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/simon987/ngx_http_js_challenge_module";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Simple JavaScript proof-of-work based DDoS protection module for nginx";
    homepage = "https://github.com/simon987/ngx_http_js_challenge_module";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
