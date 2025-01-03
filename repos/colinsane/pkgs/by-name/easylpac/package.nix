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
  pkg-config,
  wrapGAppsHook,
  xorg,
}:

buildGoModule rec {
  pname = "easylpac";
  version = "0.7.6.5";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-WQukghrBiUOb2t+iJVy2LYY0Hqkw5IMSe2e+8bQIw+U=";
  };
  proxyVendor = true;  #< ??
  vendorHash = "sha256-h/vRooTwbv63WraH/kBLfnmbd68oE6OtyghfocqDuhA=";

  postConfigure = ''
    cp ${euicc-manual.eum_manifest} eum-registry.json
    cp ${euicc-manual.ci_manifest} ci-registry.json
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];
  buildInputs = [
    gtk3
    libglvnd
    xorg.libXxf86vm
  ] ++ glfw.buildInputs;

  postInstall = ''
    ln -s "${lpac}/bin/lpac" "$out/bin/lpac"
  '';

  meta = with lib; {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "EasyLPAC";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane yinfeng ];
  };
}
