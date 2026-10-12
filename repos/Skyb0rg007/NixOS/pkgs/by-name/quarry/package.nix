{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  libpathrs,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "quarry";
  version = "0-unstable-2026-10-09";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "amutable-systems";
    repo = "quarry";
    rev = "db9063d3d869dd601501079ef55afcfda5ccb049";
    hash = "sha256-mB+cNU9zO9f9jnth31VNbY+fOBiDoxmMwr5KXRkYAqc=";
  };

  vendorHash = "sha256-CRdbFU3S2vc2cSuSGthr1ypMRf2CTqhNtp7GH4YjLpA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libpathrs
  ];

  tags = [ "http" ];

  excludedPackages = [
    "internal/keystore/insecure"
    "internal/testrepo"
  ];

  checkFlags =
    let
      skippedTests = [
        # need user xattrs, which the sandbox build directory may not support
        "TestPutBlob_WithAttributes"
        "TestRepository_PutVersionedFile_PutOption_WithAttribute"

        # need /etc/machine-id, which doesn't exist in the sandbox
        "TestParseConfig_Expand_Bundled"
        "TestParseConfig_Expand_CacheDir"
        "TestParseConfig_Expand_Invalid"
        "TestParseConfig_Expand_RepoName"
        "TestParseConfig_Expand_RepoName_MachineIDConsistent"
        "TestParseConfig_Expand_URL"
        "TestParseToml_RepoNameExpandedBeforeMerge"
      ];
    in
    [ "-skip=^(${lib.concatStringsSep "|" skippedTests})$" ];

  postInstall = ''
    mv $out/bin/hardhat $out/bin/quarry-hardhat
    ln -s quarry $out/bin/quarry-client
    ln -s quarry $out/bin/quarry-sysupdate
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUF-based software distribution toolchain";
    longDescription = ''
      Quarry is a TUF-based software distribution toolchain for immutable Linux
      distributions, with a protocol that is "dumb as rocks".
    '';
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
    mainProgram = "quarry";
  };
})
