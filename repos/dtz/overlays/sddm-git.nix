self: super: {
  sddm = super.sddm.overrideAttrs (o: rec {
    name = "sddm-${version}";
    version = "2018-12-31";
    src = super.fetchFromGitHub {
      owner = "sddm";
      repo = "sddm";
      rev = "4b652e01ac589bce109429b2716826aecbc2f218";
      sha256 = "14i8gnc0a0sci7knxz4w0ykwz5m8bhzs676i4nvzgk8x3xsm363q";
    };
    patches = [ <nixpkgs/pkgs/applications/display-managers/sddm/sddm-ignore-config-mtime.patch> ];

    postInstall = ''
      echo "Skipping postInstall from normal sddm...."
    '';
  });
}
