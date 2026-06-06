{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  nix-update-script,
}:

buildGo126Module (finalAttrs: {
  pname = "cli-proxy-api";
  version = "7.1.43";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WsiTx/0S4moxzTBBrquKj9YB3lZk+rG2z8hE/AWaUEg=";
    # Populate values from the git repository; by doing this in 'postFetch' we
    # can delete '.git' afterwards and the 'src' should stay reproducible.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      # Replicate 'COMMIT' and 'DATE' variables from upstream's Makefile.
      git rev-parse --short=12 HEAD > $out/COMMIT
      git log -1 --format=%cd --date=iso-strict > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -exec rm -rf '{}' '+'
    '';
  };

  vendorHash = "sha256-AIue9XBsfsKGClRLB1DCME+36crapnOdQrEICFYG1a0=";

  subPackages = [ "./cmd/server" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  # ldflags based on metadata from git.
  preBuild = ''
    ldflags+=" -X=main.Commit=$(cat COMMIT)"
    ldflags+=" -X=main.BuildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  postInstall = ''
    mv $out/bin/server $out/bin/${finalAttrs.pname}
    install -Dm644 config.example.yaml $out/share/${finalAttrs.pname}/config.example.yaml
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go proxy server providing OpenAI/Gemini/Claude/Codex compatible APIs with OAuth and round-robin load balancing";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
