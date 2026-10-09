{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "bgd-browser";
  version = "0-unstable-2026-09-16";

  src = fetchFromGitLab {
    owner = "BuildGrid";
    repo = "bgd-browser";
    rev = "83636c98d6765278cbd765d039a09ef19ae6cee0";
    hash = "sha256-XfMqFSb5Q232KWuX/dp2grsTzSmMpaYuXrCdmEuhttg=";
  };

  npmDepsHash = "sha256-aeLnbcfqwSQIS4aOYvotoIl5pH65Ql9q/Fc2vsqPu6w=";

  # `npm pack` honours .gitignore, which excludes the built frontend
  postInstall = ''
    cp -r dist $out/lib/node_modules/bgd-browser/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Web-based UI for browsing a BuildGrid deployment";
    longDescription = ''
      A web-based UI for browsing Operations, Actions and CAS content in a
      BuildGrid deployment.
    '';
    homepage = "https://buildgrid.build";
    mainProgram = "bgd-browser";
    platforms = lib.platforms.linux;
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
