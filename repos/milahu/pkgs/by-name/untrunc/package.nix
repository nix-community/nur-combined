{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ffmpeg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "untrunc";
  # https://github.com/anthwlock/untrunc/issues/100
  # git log --reverse --format=%H | grep -n . | while IFS=: read N H; do echo git tag v$N $H; done | tail
  version = "410"; # 9d86ec9ef2ffed1bf8131abe80742c0574db52b6
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "anthwlock";
    repo = "untrunc";
    # tag = finalAttrs.version;
    rev = "9d86ec9ef2ffed1bf8131abe80742c0574db52b6";
    hash = "sha256-0qAgQnTURKxoKsjx+VUK59lwdTycLZEW0RChhFGlSi8=";
  };

  buildInputs = [
    ffmpeg
  ];

  # https://github.com/anthwlock/untrunc/issues/100
  patchPhase = ''
    substituteInPlace Makefile \
      --replace \
        'VER = $(shell test -d .git && command -v git >/dev/null && echo "v`git rev-list --count HEAD`-`git describe --always --dirty --abbrev=7`")' \
        'VER = "${finalAttrs.version}-${builtins.substring 0 7 finalAttrs.src.rev}"'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -v untrunc $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Restore truncated MP4 and MOV video files";
    homepage = "https://github.com/anthwlock/untrunc";
    changelog = "https://github.com/anthwlock/untrunc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "untrunc";
    platforms = lib.platforms.all;
  };
})
