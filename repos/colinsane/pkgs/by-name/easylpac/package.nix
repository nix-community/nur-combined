# based on linyinfeng's package
{
  buildGoModule,
  # euicc-manual,
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

buildGoModule (finalAttrs: {
  pname = "easylpac";
  version = "0.8.1.1";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = finalAttrs.version;
    sha256 = "sha256-xMXi+AJjbKX7RlcUAutbL/Gfg+DoltSldQza7YMgUWU=";
  };
  proxyVendor = true;  #< ??
  vendorHash = "sha256-Vamrw5f8wm+0FY3Cd1ye6A5xQ5Tw5yvcEGvS55/7zus=";

  # XXX: starting with 21c4a125 (2026-02-27) easylpac vendors eum-registry.json and ci-registry.json.
  # this is likely in response to the euicc-manual changing its registry formats?
  # postConfigure = ''
  #   cp ${euicc-manual.eum_manifest} eum-registry.json
  #   cp ${euicc-manual.ci_manifest} ci-registry.json
  # '';

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

  meta = {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "EasyLPAC";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane yinfeng ];
  };
})
