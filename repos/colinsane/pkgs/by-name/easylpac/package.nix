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
  version = "0.8.0.3";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = finalAttrs.version;
    sha256 = "sha256-q76p0BqrG8opuTClYKLfmM5hdziJIrZCwQmg2NkzW/E=";
  };
  proxyVendor = true;  #< ??
  vendorHash = "sha256-Oo6RfltmWBBmLFWxt99VzNhO+QzmF62KtGblScEKoKc=";

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
