{
  lib,
  apple-sdk_26,
  buildPackages,
  llvmPackages_current,
  stdenv,
  stdlib,
  swift,
  getBuildHost,
  getHostTarget,
  writers,
}:

let
  cc = getBuildHost stdenv.cc;
  inherit (cc) bintools targetPrefix;

  llvmBintools = getBuildHost llvmPackages_current.bintools-unwrapped;

  artifactName = "swift-${lib.getVersion swift}_nixpkgs${lib.version}";
  artifactPath = stdenv.hostPlatform.swift.triple;

  info = {
    artifacts = {
      "${artifactName}" = {
        type = "swiftSDK";
        inherit (swift) version;
        variants = [
          {
            path = artifactPath;
            #            supportedTriples = [ stdenv.buildPlatform.config ];
          }
        ];
      };
    };
    schemaVersion = "1.0";
  };

  swiftSdk = {
    schemaVersion = "4.0";
    targetTriples = {
      "${stdenv.hostPlatform.swift.triple}" = {
        toolsetPaths = [ "toolset.json" ];
        sdkRootPath = apple-sdk_26.sdkroot;
        swiftResourcesPath = "${lib.getLib (getHostTarget stdlib)}/lib/swift";
      };
    };
  };

  toolset = {
    schemaVersion = "1.0";
    swiftCompiler = {
      path = lib.getExe' (getBuildHost swift) "swiftc";
      extraCLIOptions = [ ];
    };
    cCompiler = {
      path = lib.getExe' cc "${targetPrefix}clang";
      extraCLIOptions = [ ];
    };
    cxxCompiler = {
      path = lib.getExe' cc "${targetPrefix}clang++";
      extraCLIOptions = [ ];
    };
    linker = {
      path = lib.getExe' cc.bintools "ld";
      extraCLIOptions = [ ];
    };
    librarian = {
      path = lib.getExe' llvmBintools (
        if stdenv.hostPlatform.isDarwin then "llvm-libtool-darwin" else "llvm-ar"
      );
      extraCLIOptions = [ ];
    };
  };
in
stdenv.mkDerivation {
  pname = "sdk";
  version = lib.getVersion swift;
  #  name = "sdk-${lib.getVersion swift}.artifactbundle";

  buildCommand = ''
    mkdir -p "$out/${artifactName}.artifactbundle/${artifactPath}"
    ln -s ${lib.escapeShellArg (writers.writeJSON "info.json" info)} "$out/${artifactName}.artifactbundle/info.json"
    ln -s ${lib.escapeShellArg (writers.writeJSON "swift-sdk.json" swiftSdk)} "$out/${artifactName}.artifactbundle/${artifactPath}/swift-sdk.json"
    ln -s ${lib.escapeShellArg (writers.writeJSON "toolset.json" toolset)} "$out/${artifactName}.artifactbundle/${artifactPath}/toolset.json"
  '';
}
