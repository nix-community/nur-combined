{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  pkg-config,
  pciutils
}:

stdenv.mkDerivation rec {
  pname = "fastfetch";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "LinusDierheimer";
    repo = "fastfetch";
    rev = "c15f55762dd3d78f30af1606384bf4d79cf7745d";
    hash = "sha256-/M4eT9BQir36NAp1+knKdwiyyFNcuOyNg/yhYEV9eSg=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ pciutils ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-macro-redefined"
    "-Wno-implicit-int-float-conversion"
  ];

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/nix-community/nur-combined" +
        "/cd58f18ba81b0a8a79497bbab55c7a86c2639d39" + 
        "/repos/vanilla/pkgs/fastfetch/no-install-config.patch";
      hash = "sha256-IKhVhgDRN5qbLNlbnheYM5aMnm/h1VeFgOqsTl/Ww0Q=";
    })
  ];

  cmakeFlags = [ "--no-warn-unused-cli" ];

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C. ";
    homepage = "https://github.com/LinusDierheimer/${pname}";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}


