self: super: {
  sddm = super.sddm.overrideAttrs (o: rec {
    name = "sddm-${version}";
    version = "2018-10-09";
    src = super.fetchFromGitHub {
      owner = "sddm";
      repo = "sddm";
      rev = "3e45d8bd66619fde29db04eb1f8e5e5464daa6dc";
      sha256 = "0jffm2s0a22s258xq912pjccanc96yymbcwclklm8hp75xnx95q1";
    };
    patches = [ <nixpkgs/pkgs/applications/display-managers/sddm/sddm-ignore-config-mtime.patch> ];

    postInstall = ''
      echo "Skipping postInstall from normal sddm...."
    '';
  });
}
