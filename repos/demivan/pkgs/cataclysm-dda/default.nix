{
  cataclysm-dda-git,
  fetchFromGitHub,
}:
cataclysm-dda-git.overrideAttrs (old: {
  version = "unstable-2024-09-16";

  src = fetchFromGitHub {
    owner = "CleverRaven";
    repo = "Cataclysm-DDA";
    rev = "acc244b46acf70721a41577b795bbdfa3b22d3ed"; # tags/cdda-experimental-*
    sha256 = "0x4glas4n9czmjjgmhy4798z88cwhz988916gljgz7lb55gy0qwg";
  };

  patches = [
  ];
})
