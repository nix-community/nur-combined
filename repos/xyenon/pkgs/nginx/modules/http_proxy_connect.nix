{ lib, fetchFromGitHub }:

nginxVersion:
let
  patch =
    with lib;
    findFirst
      (p: versionAtLeast nginxVersion p.versionAtLeast && versionOlder nginxVersion p.versionOlder)
      (warn "No patch found for nginx version ${nginxVersion}, try the latest patch." {
        versionAtLeast = "1.21.1";
        versionOlder = "99.99.99";
        patchName = "proxy_connect_rewrite_102101";
      })
      [
        {
          versionAtLeast = "1.4.0";
          versionOlder = "1.13.0";
          patchName = "proxy_connect_rewrite";
        }
        {
          versionAtLeast = "1.13.0";
          versionOlder = "1.15.0";
          patchName = "proxy_connect_rewrite_1014";
        }
        {
          versionAtLeast = "1.15.2";
          versionOlder = "1.15.3";
          patchName = "proxy_connect_rewrite_1015";
        }
        {
          versionAtLeast = "1.15.4";
          versionOlder = "1.17.0";
          patchName = "proxy_connect_rewrite_101504";
        }
        {
          versionAtLeast = "1.17.0";
          versionOlder = "1.21.1";
          patchName = "proxy_connect_rewrite_1018";
        }
        {
          versionAtLeast = "1.21.1";
          versionOlder = "1.27.1";
          patchName = "proxy_connect_rewrite_102101";
        }
      ];
in
rec {
  name = "http_proxy_connect";
  src = fetchFromGitHub {
    inherit name;
    owner = "chobits";
    repo = "ngx_http_proxy_connect_module";
    rev = "v0.0.7";
    hash = "sha256-Yob2Z+a3ex3Ji6Zz8J0peOYnKpYn5PlC9KsQNcHCL9o=";
  };

  patches = [ "${src}/patch/${patch.patchName}.patch" ];

  supports =
    with lib.strings;
    version: versionOlder version patch.versionOlder && versionAtLeast version patch.versionAtLeast;

  meta = with lib; {
    description = "Forward proxy module for CONNECT request handling";
    homepage = "https://github.com/chobits/ngx_http_proxy_connect_module";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ xyenon ];
  };
}
