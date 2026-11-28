# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/dart/package-source-builders/rhttp/default.nix
{
  replaceVars,
  rustPlatform,
  stdenvNoCC,
}:
{ version, src, ... }:
let
  rustDep = rustPlatform.buildRustPackage {
    pname = "rhttp-rs";
    inherit version src;

    sourceRoot = "${src.name}/rust";

    unpackPhase = ''
      runHook preUnpack

      cp -r $src/${src.passthru.packageRoot} ${src.name}

      chmod -R u+w -- "$sourceRoot"

      runHook postUnpack
    '';

    cargoHash = "sha256-ue5eoydkgqOZS0vI5ltXZAx+tSqpypLlQtyxBuUyIcM=";

    env.RUSTFLAGS = "--cfg reqwest_unstable";

    passthru.libraryPath = "lib/librhttp.so";
  };
in
stdenvNoCC.mkDerivation {
  pname = "rhttp";
  inherit version src;
  inherit (src) passthru;

  prePatch = ''
    pushd ./${src.passthru.packageRoot}
  '';

  patches = [
    (replaceVars ./cargokit.patch {
      output_lib = "${rustDep}/${rustDep.passthru.libraryPath}";
    })
  ];

  postPatch = ''
    popd
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}
