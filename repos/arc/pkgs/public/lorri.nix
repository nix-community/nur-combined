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
        [ $(sed -E 's/^(.*)$/    (dep \1)/' ${runtimeClosureInfo}/store-paths) ]
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
    rev = "d3e452ebc2b24ab86aec18af44c8217b2e469b2a";
    sha256 = "07yf3gl9sixh7acxayq4q8h7z4q8a66412z0r49sr69yxb7b4q89";
  };
  pname = "lorri";
  version = "rolling-release";
  cargoSha256 = if lib.isNixpkgsStable
    then "1ix9rmpfhs06xzccvx8xpdl60849ygm25rmixa69wkk0vs3s1bz2"
    else "094w2lp6jvxs8j59cjqp6b3kg4y4crlnqka5v2wmq4j0mn6hvhsj";
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
