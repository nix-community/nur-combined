self: super: {
  kanboard = { kanboard_config ? "/etc/kanboard/config.php" }:
    super.kanboard.overrideAttrs(old: rec {
      name = "kanboard-${version}";
      version = "1.2.9";
      src = self.fetchFromGitHub {
        owner = "kanboard";
        repo = "kanboard";
        rev = "c4152316b14936556edf3bcc4d11f16ba31b8ae7";
        sha256 = "1hdr95cpxgdzrzhffs63gdl0g7122ma2zg8bkqwp42p5xphx0xan";
      };
      installPhase = ''
        cp -a . $out
        ln -s ${kanboard_config} $out/config.php
        mv $out/data $out/dataold
        '';
    });
}
