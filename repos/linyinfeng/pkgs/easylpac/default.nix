{
  callPackage,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  gtk3,
  xorg,
  libglvnd,
  glfw,
  makeWrapper,
  lib,
  nix-update-script,
}:

let
  workDir = callPackage ./work-dir.nix { };
in
buildGoModule rec {
  pname = "easylpac";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-SouEaSYx5IFRQ/5tyGL+noHjxPWl9w46F9Mts2XaZJw=";
  };
  proxyVendor = true;
  vendorHash = "sha256-MotrZGwVhD6+qhDaoDbyMiNv0000mO9p0ceJSrhw5e0=";

  env = {
    EUM_REGISTRY_FILE = fetchurl {
      url = "https://euicc-manual.septs.app/docs/pki/eum/manifest.json";
      hash = "sha256-B3Hx96IqPEX7pbkbVZlK6Tk3teRrxD0HjHMTOshFSwY=";
    };
    CI_REGISTRY_FILE = fetchurl {
      url = "https://euicc-manual.septs.app/docs/pki/ci/manifest.json";
      hash = "sha256-LQSXWYlfqhl6T2y5QCRX0EWFyBvcTPe/mcnAmma9fiA=";
    };
  };
  postConfigure = ''
    cp --verbose "$EUM_REGISTRY_FILE" eum-registry.json
    cp --verbose "$CI_REGISTRY_FILE" ci-registry.json
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    gtk3
    libglvnd
    xorg.libXxf86vm
  ] ++ glfw.buildInputs;

  postInstall = ''
    wrapProgram "$out/bin/EasyLPAC" --chdir "${workDir}"
  '';

  passthru = {
    inherit workDir;

    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "EasyLPAC";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
