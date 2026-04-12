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
          rev = "0.20.7";
          hash = "sha256-S6EuLiMbJp7sgAVGV0M9DuinuVLwQ9hStjlA5w9VxOo=";
          # Beginning with this firmware version or earlier, it seems
          # that a key, when pressed with a combination, is only
          # registered once the second key is released. For example
          # super-q is only registered when q is released and not when
          # pressed.
          # Could it have something todo with the permissive hold feature?
          # https://github.com/qmk/qmk_firmware/blob/master/docs/tap_hold.md
          # maybe this could be the solution https://docs.qmk.fm/tap_hold#hold-on-other-key-press
          # this could be the changelog entry: https://docs.qmk.fm/ChangeLog/20230528#i-m-t-i
          # rev = "0.26.0";
          # hash = "sha256-TfsLZ/xMUfL/B457YqXfVDhbixJoxnkIFoH6bpqam94=";
          # rev = "0.27.9";
          # hash = "sha256-bxzjcUYvDMoY6WZSpOpq2dJKHW/KgdUhPmkLoBvvbVg=";
          # rev = "0.28.5";
          # hash = "sha256-pY8WFXGihltJrakjaQgePlDUlpJBsibjmxOhKLmFIbY=";
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
