self: super: {
  sddm = super.sddm.overrideAttrs (o: rec {
    name = "sddm-${version}";
    version = "2019-03-09";
    src = super.fetchFromGitHub {
      owner = "sddm";
      repo = "sddm";
      rev = "ff8766870f7b092d79853b21f0452de3336418e8";
      sha256 = "1cgjlkhkzcizfmz0zxq4pd647nkskj7cpqjsksn9s3pkajynyd36";
    };
    patches = [ <nixpkgs/pkgs/applications/display-managers/sddm/sddm-ignore-config-mtime.patch> ];

    postInstall = ''
      echo "Skipping postInstall from normal sddm...."
    '';
  });
}
