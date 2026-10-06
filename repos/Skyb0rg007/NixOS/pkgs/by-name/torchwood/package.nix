{
  lib,
  fetchFromGitHub,
  buildGo127Module,
  openssh,
  hurl,
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

  # Network access is required:
  # - TestReadEndpoint and TestSumDB fetch from https://sum.golang.org/
  # - age-keyserver scripts verify the hCaptcha test secret against https://hcaptcha.com/
  checkFlags = [
    "-skip=^Test(ReadEndpoint|SumDB)$|^TestScript$/^(age-keyserver|age-keylookup|monitor)$"
  ];

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
