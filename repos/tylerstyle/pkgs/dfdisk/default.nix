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
  version = "0.2.1";

  dfdiskSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfdisk";
    tag = "v${version}";
    hash = "sha256-/37FjjcqRoHQX0/dbhB+64bumCLqnxq35m15fOuiRGs=";
  };

  # dfdisk depends on dfcore via `path = "../dfcore"`; pin the revision
  # recorded in dfdisk's flake.lock for this tag
  dfcoreSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfcore";
    rev = "d1a97cd05bbf6fb95123f9236fae37ea352926cf";
    hash = "sha256-CUcFeUqfEKERS9RU9Y039uP/1MAeMXiKRkIWgfiClLU=";
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

  cargoHash = "sha256-UoEK3Hdw+RtoAiC0GJSa5kkukWovLAJ+iYovn6xKGP8=";

  # build.rs cannot run git in the sandbox. dfdiskSrc is fetched by tag (its
  # rev is "refs/tags/v..."), so the release workflow writes the tag's commit
  # here; the dfcore revision is the pinned one
  env = {
    DFDISK_GIT_REV = "c7f29fe61f33fc70a72cd9dd2754ff9485948bee";
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
