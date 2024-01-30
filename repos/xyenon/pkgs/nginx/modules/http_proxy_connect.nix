{ lib, fetchFromGitHub }:

nginxVersion:
let
  patch = with lib; findFirst
    (p: versionAtLeast nginxVersion p.versionAtLeast && versionOlder nginxVersion p.versionOlder)
    (builtins.abort "No patch found for this version of nginx")
    [
      { versionAtLeast = "1.17.0"; versionOlder = "1.21.1"; patchName = "proxy_connect_rewrite_1018"; }
      { versionAtLeast = "1.21.1"; versionOlder = "1.26.0"; patchName = "proxy_connect_rewrite_102101"; }
    ];
in
rec {
  name = "http_proxy_connect";
  src = fetchFromGitHub {
    inherit name;
    owner = "chobits";
    repo = "ngx_http_proxy_connect_module";
    rev = "v0.0.5";
    hash = "sha256-NZuW/wtKqqC4Gq/Ju3RuZZUmxpM3BNeIB/XMU0apqz8=";
  };

  patches = [ "${src}/patch/${patch.patchName}.patch" ];

  supports = with lib.strings; version: versionOlder version patch.versionOlder && versionAtLeast version patch.versionAtLeast;

  meta = with lib; {
    description = "Forward proxy module for CONNECT request handling";
    homepage = "https://github.com/chobits/ngx_http_proxy_connect_module";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ xyenon ];
  };
}
