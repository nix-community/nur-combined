{
  cataclysm-dda-git,
  fetchFromGitHub,
}:
cataclysm-dda-git.overrideAttrs (old: {
  version = "unstable-2024-11-01-2";

  src = fetchFromGitHub {
    owner = "CleverRaven";
    repo = "Cataclysm-DDA";
    rev = "55335a2efb874d12ee722f4fd8f048e003105ca8"; # tags/cdda-experimental-*
    sha256 = "0cx0gxbj02yfiqnq0k1wdcxz3d8fxxnkj1j02lvvjsz5nr993gb9";
  };

  patches = [
  ];
})
