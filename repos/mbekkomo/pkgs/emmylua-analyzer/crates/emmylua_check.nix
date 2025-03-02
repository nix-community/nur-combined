version:
{
  stdenv,
  pkg-config,
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "emmylua_check";
  inherit version;

  src = fetchFromGitHub {
    owner = "CppCXY";
    repo = "emmylua-analyzer-rust";
    rev = version;
    hash = "sha256-cMqBNUR3zibWsERt9cJLCkZ8ksUrIdC6K5xLKHXJqR0=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-AW1aCruxKk2vNKRkfpevdCWslr/JlZypzdTiAPIO0fo=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ stdenv.cc.cc.lib ];

  buildAndTestSubdir = "crates/${pname}";

  postFixup = ''
    patchelf --set-rpath "${stdenv.cc.cc.lib}/lib" $out/bin/${pname}
  '';
}
