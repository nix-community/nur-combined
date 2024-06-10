{
  pkgs,
  system ? builtins.currentSystem
}:
let
  pklVersion = "0.0.2";

  shaMap = {
    x86_64-linux = "sha256-seWuHvBDOXARipHzSk5gEQrSZJO0pw19vyf3TVLiGaA=";
    aarch64-linux = "sha256-/wZgO7bg7btTdoiminl6aJSSxnoX7YLuBRxNVhPCa9s=";
    x86_64-darwin = "sha256-2RtGvtG64n5X6RIRZyfbpYMsF33/5eJipJpuLMblJh0=";
    aarch64-darwin = "sha256-PVnLttnS/fNxdnXQWV45Hbt2fb+iH9e/UEGtin+vcXo=";
  };

  urlMap = {
    x86_64-linux = "https://github.com/Drafteame/pkl-linter/releases/download/v${pklVersion}/pkl-linter_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/Drafteame/pkl-linter/releases/download/v${pklVersion}/pkl-linter_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/Drafteame/pkl-linter/releases/download/v${pklVersion}/pkl-linter_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/Drafteame/pkl-linter/releases/download/v${pklVersion}/pkl-linter_Darwin_arm64.tar.gz";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "pkl-linter";
  version = "${pklVersion}";

  src = pkgs.fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./pkl-linter $out/bin/pkl-linter
  '';

  system = system;

  meta = with pkgs.lib; {
    description = "Simple linter for PKL files";
    homepage = "https://github.com/Drafteame/pkl-linter";

    license = licenses.mit;

    sourceProvenance = [ sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}