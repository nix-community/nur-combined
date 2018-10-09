self: super: {
  sddm = super.sddm.overrideAttrs (o: rec {
    name = "sddm-${version}";
    version = "2018-09-10";
    src = super.fetchFromGitHub {
      owner = "sddm";
      repo = "sddm";
      rev = "76a9fcf3cd4eb0cd7a7ad50c53cc6624a5b35626";
      sha256 = "1qqv8d5gxppmk0h6n98dwwdly1wzq3z2lrk4d63fchdym9hn35gg";
    };
    patches = [ <nixpkgs/pkgs/applications/display-managers/sddm/sddm-ignore-config-mtime.patch> ];

    postInstall = ''
      echo "Skipping postInstall from normal sddm...."
    '';
  });
}
