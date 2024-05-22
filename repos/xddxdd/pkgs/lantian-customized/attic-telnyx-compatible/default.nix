{
  sources,
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  installShellFiles,
  nix,
  boost,
}:
rustPlatform.buildRustPackage {
  pname = "attic-telnyx-compatible";
  inherit (sources.attic) version src;

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    nix
    boost
  ];

  cargoLock = {
    lockFile = sources.attic.src + "/Cargo.lock";
    allowBuiltinFetchGit = true;
  };
  cargoBuildFlags = lib.concatMapStrings (c: "-p ${c} ") [
    "attic-client"
    "attic-server"
  ];

  postPatch = ''
    sed -i "/x-id/d" $cargoDepsCopy/aws-sdk-s3-*/src/operation/*.rs
  '';

  ATTIC_DISTRIBUTOR = "attic";

  # See comment in `attic/build.rs`
  NIX_INCLUDE_PATH = "${lib.getDev nix}/include";

  # Recursive Nix is not stable yet
  doCheck = false;

  postInstall = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    if [[ -f $out/bin/attic ]]; then
      installShellCompletion --cmd attic \
        --bash <($out/bin/attic gen-completions bash) \
        --zsh <($out/bin/attic gen-completions zsh) \
        --fish <($out/bin/attic gen-completions fish)
    fi
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Attic (Nix binary cache) patched for Telnyx Cloud Storage compatibility";
    homepage = "https://github.com/zhaofengli/attic";
    license = licenses.asl20;
  };
}
