{
  pkgs,
}:

{
  mkQmkFirmware =
    {
      name,
      keyboard,
      keymap ? "default",
      ...
    }@args:
    pkgs.stdenv.mkDerivation (
      {
        src = pkgs.fetchFromGitHub {
          owner = "qmk";
          repo = "qmk_firmware";
          rev = "0.26.0";
          sha256 = "sha256-TfsLZ/xMUfL/B457YqXfVDhbixJoxnkIFoH6bpqam94=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = [
          pkgs.qmk
          pkgs.writableTmpDirAsHomeHook
          (pkgs.python3.withPackages (ps: [ ps.appdirs ]))
          # pkgs.git
        ];

        # this allows us to not need the .git folder
        env.SKIP_VERSION = "1";

        outputs = [
          "out"
          "hex"
        ];

        buildPhase = ''
          runHook preBuild

          qmk setup --home . --yes
          qmk compile -kb "${keyboard}" -km "${keymap}"

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/qmk $out/bin
          install -Dm644 *.hex $out/share/qmk/${name}.hex
          install -Dm644 *.hex $hex
          cat > $out/bin/${name} <<EOF
          #!/usr/bin/env bash
          exec ${pkgs.avrdude}/bin/avrdude \\
            -p atmega32u4 \\
            -c avr109 \\
            -P /dev/ttyACM0 \\
            -U flash:w:$out/share/qmk/${name}.hex:i "\$@"
          EOF
          patchShebangs $out/bin/*
          chmod +x $out/bin/*

          runHook postInstall
        '';

        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      // args
    );
}
