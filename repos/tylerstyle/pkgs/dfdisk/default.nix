{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  runCommand,
  makeWrapper,
  libewf,
  ddrescue,
  smartmontools,
  util-linux,
  systemd,
  hdparm,
  nvme-cli,
}:

let
  version = "0.2.2";

  dfdiskSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfdisk";
    tag = "v${version}";
    hash = "sha256-xKJ+N6zJLMnX7A637kGeme/xSb/9KgBHxbGv4eWMQTw=";
  };

  # dfdisk depends on dfcore via `path = "../dfcore"`; pin the revision
  # recorded in dfdisk's flake.lock for this tag
  dfcoreSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfcore";
    rev = "d2d9fcecf150965cbce075366cf15b2813a77a14";
    hash = "sha256-3YuDlCcEZkLknfkEpHKLDKEQ0KIzMLY3wE0gEB96IgY=";
  };

  # The tools dfdisk runs (package.nix passthru.runtimeTools); none is linked
  runtimeTools = [
    libewf
    ddrescue
    smartmontools
    util-linux
    systemd
    hdparm
    nvme-cli
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dfdisk";
  inherit version;

  __structuredAttrs = true;

  # Lay out the sources as siblings so the relative path dependency resolves
  src = runCommand "dfdisk-src-${version}" { } ''
    mkdir -p $out
    cp -r ${dfdiskSrc} $out/dfdisk
    cp -r ${dfcoreSrc} $out/dfcore
    chmod -R u+w $out
  '';
  sourceRoot = "${finalAttrs.src.name}/dfdisk";

  cargoHash = "sha256-ERA6ACRqPpYaL/2f2s+5bNIQ2klOpeHUP8kNgiwUq6k=";

  # build.rs cannot run git in the sandbox. dfdiskSrc is fetched by tag (its
  # rev is "refs/tags/v..."), so the release workflow writes the tag's commit
  # here; the dfcore revision is the pinned one
  env = {
    DFDISK_GIT_REV = "a5483a0be95ce4dbfb92e79cd0db009672835689";
    DFCORE_GIT_REV = dfcoreSrc.rev;
  };

  nativeBuildInputs = [ makeWrapper ];

  # The tool tests run against the real libewf and ddrescue (and a C compiler
  # for the fake-device shim) instead of skipping
  nativeCheckInputs = [
    libewf
    ddrescue
    stdenv.cc
  ];
  preCheck = ''
    export DFDISK_REQUIRE_TOOLS=1
  '';

  postInstall = ''
    wrapProgram $out/bin/dfdisk \
      --prefix PATH : ${lib.makeBinPath runtimeTools}
  '';

  meta = {
    description = "Modern forensic disk imaging, damaged media rescue and conversion CLI/TUI tool";
    homepage = "https://github.com/tylerstyle/dfdisk";
    changelog = "https://github.com/tylerstyle/dfdisk/releases/tag/v${version}";
    license = with lib.licenses; [ mit asl20 ];
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "dfdisk";
    platforms = lib.platforms.linux;
  };
})
