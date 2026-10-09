{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo127Module,
  openssh,
  hurl,
  nix-update-script,
}:
buildGo127Module (finalAttrs: {
  pname = "torchwood";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "torchwood";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eSDbIOzWKRlmGXj+/LlaT22HDC77Uyz96fTTR9vWbWk=";
  };

  nativeCheckInputs = [
    openssh
    hurl
  ];

  # - TestReadEndpoint and TestSumDB fetch from https://sum.golang.org/
  # - age-keyserver scripts verify the hCaptcha test secret against https://hcaptcha.com/
  # - On darwin, each parallel script's Setup rebuilds witnessctl into a shared $PATH dir.
  #   /tmp and /nix are on different volumes, so go build copies instead of renaming,
  #   and scripts get SIGKILLed exec'ing a partially written binary.
  checkFlags = [
    (
      if stdenv.hostPlatform.isDarwin then
        "-skip=^Test(ReadEndpoint|SumDB|Script)$"
      else
        "-skip=^Test(ReadEndpoint|SumDB)$|^TestScript$/^(age-keyserver|age-keylookup|monitor)$"
    )
  ];

  passthru.updateScript = nix-update-script { };

  vendorHash = "sha256-S1/PInF5TvvuY/lcn5DPQS5NJJaiH3y1gXZZzJzWvtU=";

  meta = {
    description = "Collection of open source tlog tooling";
    longDescription = ''
      The Torchwood repository is a collection of open-source tooling for tlogs.

      - litewitness is a cosigning witness backed by SQLite and ssh-agent.
        It implements c2sp.org/tlog-witness.

      - litebastion (and filippo.io/torchwood/bastion) is a public-service
        reverse proxy. It implements c2sp.org/https-bastion.

      - filippo.io/torchwood implements a tlog client and various
        c2sp.org/signed-note, c2sp.org/tlog-cosignature,
        c2sp.org/tlog-checkpoint, and c2sp.org/tlog-tiles functions, including
        extensions to the golang.org/x/mod/sumdb/tlog and
        golang.org/x/mod/sumdb/note packages.
    '';
    changelog = "https://github.com/FiloSottile/torchwood/blob/v${finalAttrs.version}/NEWS.md";
    homepage = "https://github.com/FiloSottile/torchwood";
    platforms = lib.platforms.all;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
