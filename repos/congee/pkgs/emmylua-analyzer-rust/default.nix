{ stdenv
, lib
, fetchFromGitHub
, callPackage
, which
, ...
}:

let
  deps = stdenv.mkDerivation rec {
    pname = "emmylua-analyzer-rust";
    version = "0.10.0";
    name = "deps";
    src = fetchFromGitHub {
      owner = "EmmyLuaLs";
      repo = "${pname}";
      rev = "${version}";
      sha256 = "sha256-Fvg3G0C/YECDEWZ4mDC5b8qocWvyDJ9KdLYNtwIu0+I=";
    };
    propagatedBuildInputs = builtins.attrValues (builtins.mapAttrs
      (name: value: callPackage value { })
      (import "${src}/nix/packages.nix")
    );
  };
in

stdenv.mkDerivation {
  pname = "emmylua-analyzer-rust";
  version = "0.10.0";

  buildInputs = [ which ];
  propagatedBuildInputs = [ deps ];

  buildPhase = ''
    mkdir -p $out/bin
    ln -s $(which emmylua_ls) $out/bin/
    ln -s $(which emmylua_check) $out/bin/
    ln -s $(which emmylua_doc_cli) $out/bin/
  '';

  meta = with lib; {
    description = "EmmyLua Language Server";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    licenses = licenses.mit;
    maintainers = with maintainers; [ congee ];
  };
}
