{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, callPackage
, ...
}:

let
  deps = source: builtins.mapAttrs (name: value: callPackage value { }) (import "${source}/nix/packages.nix");
in

stdenv.mkDerivation rec {
  pname = "emmylua-analyzer-rust";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "EmmyLuaLs";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-Fvg3G0C/YECDEWZ4mDC5b8qocWvyDJ9KdLYNtwIu0+I=";
  };

  buildPhase = ''
    mkdir -p $out/bin
    cp ${(deps src).emmylua_ls}/bin/emmylua_ls $out/bin/
    cp ${(deps src).emmylua_check}/bin/emmylua_check $out/bin/
    cp ${(deps src).emmylua_doc_cli}/bin/emmylua_doc_cli $out/bin/
  '';

  buildInputs = [ pkg-config ];

  meta = with lib; {
    description = "EmmyLua Language Server";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    licenses = licenses.mit;
    maintainers = with maintainers; [ congee ];
  };
}
