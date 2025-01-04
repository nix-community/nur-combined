{
  callPackage,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  xorg,
  libglvnd,
  glfw,
  wrapGAppsHook,
  lpac,
  lib,
}:

buildGoModule rec {
  pname = "easylpac";
  version = "0.7.6.6";
  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-K/vau80aD+Ux8sm2eLCHF2pKGpwSKzLfI8hOa6Iyayk=";
  };
  proxyVendor = true;
  vendorHash = "sha256-h/vRooTwbv63WraH/kBLfnmbd68oE6OtyghfocqDuhA=";

  postConfigure = ''
    cp --verbose "${./eum-registry.json}" eum-registry.json
    cp --verbose "${./ci-registry.json}"  ci-registry.json
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
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "24.11");
  };
}
