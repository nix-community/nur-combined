{ lib
, sources
, buildGoModule
, xz
, ...
}:

buildGoModule rec {
  inherit (sources.payload-dumper-go) pname version src;
  vendorSha256 = "sha256-CqIZFMDN/kK9bT7b/32yQ9NJAQnkI8gZUMKa6MJCaec=";

  buildInputs = [ xz ];

  meta = with lib; {
    description = "An android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
  };
}
