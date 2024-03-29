{
  callPackage,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  gtk3,
  xorg,
  libglvnd,
  glfw,
  makeWrapper,
  lib,
}:

let
  workDir = callPackage ./work-dir.nix { };
in
buildGoModule rec {
  pname = "easylpac";
  version = "0.7.3";
  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-cgARONBFJAyBhA3bfYCgRPONDytNFSMk2Y+Ak16u3bQ=";
  };
  proxyVendor = true;
  vendorHash = "sha256-aivuY9ep7QOtYNpHkSZSAHdHrpbTsL3fLbE5AFktHF0=";

  postConfigure = ''
    cp --verbose "${./eum-registry.json}" eum-registry.json
    cp --verbose "${./ci-registry.json}"  ci-registry.json
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
  };
}
