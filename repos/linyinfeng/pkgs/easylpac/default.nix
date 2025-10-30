{
  callPackage,
  go,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  xorg,
  libglvnd,
  glfw,
  wrapGAppsHook3,
  lpac,
  lib,
}:

buildGoModule rec {
  pname = "easylpac";
  version = "0.7.8.4";
  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-vNXeDm2LH5b/upZR1KX326+PMeXzT0fE1VNmPPNpSZU=";
  };
  proxyVendor = true;
  vendorHash = "sha256-tX7abWGn1f4p+7vx2gDa5/NKg5SbWqMfHT8kbPwHK14=";

  postConfigure = ''
    cp --verbose "${./eum-registry.json}" eum-registry.json
    cp --verbose "${./ci-registry.json}"  ci-registry.json
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    libglvnd
    xorg.libXxf86vm
  ]
  ++ glfw.buildInputs;

  postInstall = ''
    ln -s "${lpac}/bin/lpac" "$out/bin/lpac"
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript =
      let
        script = callPackage ./update.nix { };
      in
      [ "${script}/bin/update-easylpac" ];
  };

  meta = with lib; {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "EasyLPAC";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast go.version "1.24");
  };
}
