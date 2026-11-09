{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "w2c2";
  version = "0-unstable-2026-11-08";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "turbolent";
    repo = "w2c2";
    rev = "8b05ef3d60788642d3dad348781e18942232c3c9";
    hash = "sha256-VCzfo30xmZsEnpNBpKTHOVMVH5LZuxKOZPDTyc8thnA=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  doCheck = true;

  # TODO pr the wasi install upstream
  postInstall = ''
    install -Dm644 -t $out/lib wasi/libw2c2wasi.a
    install -Dm644 -t $out/include/wasi/ $src/wasi/*.h
  '';

  meta = {
    description = "Translates WebAssembly modules to portable C";
    homepage = "https://github.com/turbolent/w2c2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "w2c2";
    platforms = lib.platforms.all;
  };
}
