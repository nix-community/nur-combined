{ stdenvNoCC
, callPackage
, lib
, pkgs
, mloeper
, fetchurl
, stdenv
, stdenvAdapters
, nix-alien ? (import
    (
      builtins.fetchTarball {
        url = "https://github.com/thiagokokada/nix-alien/tarball/master";
        sha256 = "1hi8gynzdxgfd0fbxvhyn4fakrnz4v60ap27l35xz646mbkhfzg9";
      }
    )
    { inherit pkgs; }).nix-alien
, makeWrapper
}:

# it looks like vercel binaries are just not easily packagable on nix since patching the elf binary is not possible
# see: https://github.com/tweag/nix-marp/pull/1
let
  pname = "postman-cli";
  version = "1.7.1"; #postman-cli-1.7.1-linux-x64.tar.gz
  meta = with lib; {
    homepage = "https://learning.postman.com/docs/postman-cli/postman-cli-overview/";
    description = "Postman's command-line companion";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.postman;
    platforms = [ "x86_64-linux" ];
    maintainers = [ mloeper ];
    mainProgram = "postman-cli";
  };

  # we somehow need debug symbols enabled, see: https://github.com/getsolus/packages/issues/940
  stdenvWithDebugSymbols = stdenvAdapters.keepDebugInfo stdenv;
in
stdenvWithDebugSymbols.mkDerivation {
  inherit pname version meta;

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D postman-cli $out/bin/.postman-cli-wrapped
    makeWrapper ${nix-alien}/bin/nix-alien $out/bin/postman-cli --add-flags "$out/bin/.postman-cli-wrapped"
    runHook postInstall
  '';

  # see: https://nixos.wiki/wiki/Packaging/Binaries
  nativeBuildInputs = [
    # note: we use nix-alien instead since vercel does not support binary patching
    #autoPatchelfHook
    stdenvWithDebugSymbols.cc.cc.lib
    makeWrapper
  ];

  src = fetchurl {
    url = "https://dl-cli.pstmn.io/download/version/${version}/linux64";
    hash = "sha256-xH6x8vBqFlTszNoohdrgt/vDvSdd9m/5AfPvbzydRQs=";
    name = "${pname}-${version}.tar.gz";
  };
}
