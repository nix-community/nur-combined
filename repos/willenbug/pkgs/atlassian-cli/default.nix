{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "atlassian-cli";
  version = "1.3.3-stable";

  src = fetchurl {
    url = if stdenv.hostPlatform.system == "x86_64-linux"
      then "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
      else if stdenv.hostPlatform.system == "aarch64-linux"
      then "https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"
      else throw "Unsupported platform: ${stdenv.hostPlatform.system}";
    hash = if stdenv.hostPlatform.system == "x86_64-linux"
      then "sha256-068fjcgq1n2s86sq2nlx15wy7543zprmi2zpc119fvphkm4xarcx"
      else if stdenv.hostPlatform.system == "aarch64-linux"
      then "sha256-1kxgi468yfdryzyj5mhngf7gv221i6324jxxqbrcfr68s2gcv4w2"
      else "";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/acli
    runHook postInstall
  '';

  meta = with lib; {
    description = "Atlassian Command Line Interface (CLI)";
    homepage = "https://developer.atlassian.com/cloud/acli/";
    license = licenses.unfreeRedistributable;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ "willenbug" ];
    mainProgram = "acli";
  };
}
