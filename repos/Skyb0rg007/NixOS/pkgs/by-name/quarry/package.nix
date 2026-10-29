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
  version = "0-unstable-2026-10-29";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "amutable-systems";
    repo = "quarry";
    rev = "314ed3c96448ddae7c438bb1c77d07cdbe4ab7b7";
    hash = "sha256-ri83wy/zHYGht6MlJTYPX0Jpu0JB11tP5pjxRbyWzKo=";
  };

  vendorHash = "sha256-k+EuBeAGO3PFydwLAAaHgIm3/qe1V72x2/jgHnxXAlo=";

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
        # need xattrs, which the sandbox build directory may not support
        # (flistxattr returns ENOTSUP on GitHub runners)
        "TestDeleteBlob_IfETagMatches"
        "TestDeleteBlob_RequiresPolicy"
        "TestPutBlob_Clobber"
        "TestPutBlob_IfETagMatches"
        "TestPutBlob_NoClobberByDefault"
        "TestPutBlob_WithAttributes"
        "TestPutGetBlob_RoundTrip"
        "TestRepository_GetBlob_DummyOption"
        "TestRepository_GetLatestRoot_IterationError"
        "TestRepository_GetLatestRoot_PicksHighestVersion"
        "TestRepository_GetLatestRoot_VersionGap"
        "TestRepository_GetLatestRoot_WrongRole"
        "TestRepository_GetLatestTimestamp"
        "TestRepository_GetLatestTimestamp_InvalidJSON"
        "TestRepository_GetLatestTimestamp_WrongRole"
        "TestRepository_PutGetVersionedFile_RoundTrip"
        "TestRepository_PutVersionedFile_LandsAtExpectedFilename"
        "TestRepository_PutVersionedFile_PutOption_WithAttribute"
        "TestXattrs_GetEmpty"

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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "TUF-based software distribution toolchain";
    longDescription = ''
      Quarry is a TUF-based software distribution toolchain for immutable Linux
      distributions, with a protocol that is "dumb as rocks".
    '';
    homepage = "https://github.com/amutable/quarry";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
    mainProgram = "quarry";
  };
})
