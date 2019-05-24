self: super: {
  kanboard = { kanboard_config ? "/etc/kanboard/config.php" }:
    super.kanboard.overrideAttrs(old: rec {
      name = "kanboard-${version}";
      version = "1.2.9";
      src = self.fetchFromGitHub {
        owner = "kanboard";
        repo = "kanboard";
        rev = "c4152316b14936556edf3bcc4d11f16ba31b8ae7";
        sha256 = "18bn9zhyfc5x28hwcxss7chdq7c8rshc8jxgai65i5l68iwhvjg7";
      };
      installPhase = ''
        cp -a . $out
        ln -s ${kanboard_config} $out/config.php
        mv $out/data $out/dataold
        '';
    });
}
