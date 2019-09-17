{ lib, stdenv, fetchFromGitHub, makeWrapper
, rustPlatform
, coreutils, nix, direnv, which, darwin
# for runtime: https://github.com/target/lorri/blob/d3e452ebc2b24ab86aec18af44c8217b2e469b2a/nix/runtime.nix
, bash, closureInfo, substituteAll, runCommand, buildEnv
}: let
  runtimeClosure = let
    tools = buildEnv {
      name = "lorri-runtime-tools";
      paths = [ coreutils bash ];
    };

    runtimeClosureInfo = closureInfo {
      rootPaths = [ tools ];
    };

    closureToNix = runCommand "closure.nix" {} ''
      tee $out <<EOF
        { dep }: [ $(sed -E 's/^(.*)$/    (dep \1)/' ${runtimeClosureInfo}/store-paths) ]
      EOF
    '';

    runtimeClosureTemplate = ''
      let
        tools_build_host = @tools_build_host@;
        dep = if toString (dirOf tools_build_host) == toString builtins.storeDir
          then (builtins.trace "using storePath"  builtins.storePath)
          else (builtins.trace "using toString" toString); # assume we have no sandboxing
        tools = dep tools_build_host;
      in {
        path = "''${tools}/bin";
        builder = "''${tools}/bin/bash";
        closure = import @runtime_closure_list@ { inherit dep; };
      }
    '';

  in substituteAll {
    name = "runtime-closure.nix";
    runtime_closure_list = closureToNix;
    tools_build_host = tools;
    src = builtins.toFile "runtime-closure.nix.template"  runtimeClosureTemplate;
  };
in rustPlatform.buildRustPackage rec {
  src = fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    #branch = "rolling-release";
    rev = "38eae3d487526ece9d1b8c9bb0d27fb45cf60816";
    sha256 = "11k9lxg9cv6dlxj4haydvw4dhcfyszwvx7jx9p24jadqsy9jmbj4";
  };
  pname = "lorri";
  version = "rolling-release";
  cargoSha256 = if lib.isNixpkgsStable
    then "1bc5clyxsmfq45xlb394zmvsv8gihwrn7apnh5h90wncarsr1sbq"
    else "1daff4plh7hwclfp21hkx4fiflh9r80y2c7k2sd3zm4lmpy0jpfz";
  COREUTILS = coreutils;
  BUILD_REV_COUNT = 1;
  RUN_TIME_CLOSURE = runtimeClosure;

  buildInputs = [ nix direnv which ] ++
    lib.optionals stdenv.isDarwin [
      darwin.Security
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
    ];

  nativeBuildInputs = [ makeWrapper ];
  wrapperPath = lib.makeBinPath [ nix direnv ];

  postInstall = ''
    wrapProgram $out/bin/$pname --prefix PATH : $wrapperPath
  '';

  doCheck = false;

  meta.broken = lib.versionAtLeast "1.34" rustPlatform.rust.rustc.version;
}
