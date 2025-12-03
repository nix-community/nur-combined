# based on linyinfeng's package
{
  buildGoModule,
  euicc-manual,
  fetchFromGitHub,
  glfw,
  gtk3,
  lib,
  libglvnd,
  lpac,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
  xorg,
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
  proxyVendor = true;  #< ??
  vendorHash = "sha256-tX7abWGn1f4p+7vx2gDa5/NKg5SbWqMfHT8kbPwHK14=";

  postConfigure = ''
    cp ${euicc-manual.eum_manifest} eum-registry.json
    cp ${euicc-manual.ci_manifest} ci-registry.json
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    libglvnd
    xorg.libXxf86vm
  ] ++ glfw.buildInputs;

  postInstall = ''
    ln -s "${lpac}/bin/lpac" "$out/bin/lpac"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "EasyLPAC";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane yinfeng ];
  };
}
