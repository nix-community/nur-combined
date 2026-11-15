{
  lib,
  rustPlatform,
  buildNpmPackage,
  pkg-config,
  wrapGAppsHook3,
  webkitgtk_4_1,
  openssl,
  glib-networking,
  src,
  version,
}:
let
  frontend = buildNpmPackage {
    pname = "recompia-frontend";
    inherit src version;
    sourceRoot = "source/launcher";
    npmDepsHash = "sha256-cWfN14BiYe/L93g4WYZzbVRsjxdjSWgwaD8sE95PW2A=";
    installPhase = "cp -r dist $out";
  };
in
rustPlatform.buildRustPackage {
  pname = "recompia-launcher";
  inherit src version;
  cargoRoot = "launcher/src-tauri";
  buildAndTestSubdir = "launcher/src-tauri";
  cargoHash = "sha256-r5oRLhPg2JUcjTBX+lXZ6C8Km25+Pm68Q7wBAYGZiwE=";
  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    webkitgtk_4_1
    openssl
    glib-networking
  ];
  postPatch = ''
    substituteInPlace launcher/src-tauri/src/update.rs \
      --replace-fail 'pub fn install(t: &Target, p: &Paths, st: &UpdateState, report: &mut dyn FnMut(Progress), steps: &Steps) -> Result<Session, String> {' \
      'pub fn install(t: &Target, p: &Paths, st: &UpdateState, report: &mut dyn FnMut(Progress), steps: &Steps) -> Result<Session, String> {
        if std::env::var_os("RECOMPIA_NIX_PACKAGE").is_some() {
            return Err("Update Recompia through Nix, then restart the launcher.".into());
        }'
    # The translator wrapper supplies Nix's shared .NET runtime.
    substituteInPlace launcher/src-tauri/src/shaders.rs \
      --replace-fail ', "libhostfxr.so", "libhostpolicy.so", "libcoreclr.so"' ""
  '';
  preBuild = ''
    cp -r ${frontend} launcher/dist
  '';
  # The launcher tests require a desktop and writable game folders.
  doCheck = false;
  env.TAURI_SKIP_SIDECAR_SIGNATURE_CHECK = "true";
}
