{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  buildNpmPackage,
  nix-update-script,
}:

let
  version = "1.3.0";

  frontendDist = buildNpmPackage (finalAttrs: {
    pname = "resin-webui";
    inherit version;
    src = fetchFromGitHub {
      owner = "Resinat";
      repo = "Resin";
      tag = "v${finalAttrs.version}";
      hash = "sha256-6YBI15NLupgEKwSwGy9x7JToYP7G5/7IyF+Ty5pKpQ8=";
    };
    sourceRoot = "source/webui";

    npmDepsHash = "sha256-HM1+bcEry9BY39xt7qUgRwnNfXwyfBJyUeFAPosrnKU=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  });
in
# upstream go.mod requires go >= 1.26.10; nixpkgs' default go is older
buildGo127Module (finalAttrs: {
  pname = "resin";
  inherit version;
  src = fetchFromGitHub {
    owner = "Resinat";
    repo = "Resin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6YBI15NLupgEKwSwGy9x7JToYP7G5/7IyF+Ty5pKpQ8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-oaDPOve+Jt+teRUPSSUaRIGYfP7PQbJTjeNpcbOwNvY=";

  proxyVendor = true;

  tags = [
    "with_quic"
    "with_wireguard"
    "with_grpc"
    "with_utls"
    # go 1.27 makes x/net/http2 a shim over the stdlib, removing the
    # internal symbols sing-box 1.12 links to; keep the legacy in-package
    # implementation (sing-box issue SagerNet/sing-box#4450)
    "http2legacy"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Resinat/Resin/internal/buildinfo.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/resin" ];

  preBuild = ''
    rm -rf webui/dist
    mkdir -p webui/dist
    cp -r ${frontendDist}/* webui/dist/
  '';

  passthru = {
    updateScript = nix-update-script { };
    # nix-update reads pkg.npmDeps.outputHash; without this the frontend's
    # npmDepsHash in the let-bound frontendDist goes stale on version bumps
    inherit (frontendDist) npmDeps;
  };
  meta = {
    mainProgram = "resin";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "High-performance intelligent proxy pool gateway with sticky sessions";
    homepage = "https://github.com/Resinat/Resin";
    license = lib.licenses.mit;
  };
})
