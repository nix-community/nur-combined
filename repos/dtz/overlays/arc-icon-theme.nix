self: super: {
  arc-icon-theme = super.arc-icon-theme.overrideAttrs(o: rec {
    version = "2017-06-22";
    src = super.fetchFromGitHub {
      owner = "arc-theme";
      repo = "arc-icon-theme";
      rev = "ec0f4f4c18d2391428dd59732a77437c9ce22597";
      sha256 = "10vf5jqki7n88bbz51l87jb90dfycshpqzar31nz2jsg5kf1qz9w";
    };
  });
}
