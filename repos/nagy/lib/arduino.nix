{ pkgs, ... }:

rec {
  mkArduinoCompile = { sketch, sketchname, }:
    pkgs.runCommandLocal "arduino-compile"
      {
        env = {
          inherit sketchname;
          NO_COLOR = "1";
        };
        nativeBuildInputs =
          [ pkgs.arduino-cli (pkgs.python3.withPackages (ps: [ ps.pyserial ])) ];
        src = sketch;
        # fqbn = "esp32:esp32:esp32s3";
        fqbn = "arduino:avr:uno";
      } ''
      cp -r ${mkArduinoCoreInstall} .arduino15
      cp -r $src $sketchname
      chmod u+w -R .arduino15 $sketchname
      export HOME=$PWD
      arduino-cli compile --verbose --fqbn "$fqbn" --output-dir build $sketchname/$sketchname.ino
      mv build $out
    '';

  mkArduinoCoreInstall = pkgs.runCommandLocal "arduino-core"
    {
      nativeBuildInputs = [ pkgs.arduino-cli ];
    } ''
    HOME=$PWD \
      arduino-cli core install arduino:avr
    mv .arduino15 $out
  '';

  mkArduinoCoreEspInstall = pkgs.runCommandLocal "arduino-core-esp"
    {
      nativeBuildInputs = [ pkgs.arduino-cli ];
    } ''
    HOME=$PWD \
      arduino-cli core install esp32:esp32
    mv .arduino15 $out
  '';

  mkArduinoDownloaded = pkgs.runCommandLocal "arduino-core-esp32-esp32"
    {
      core = "esp32:esp32";
      version = "2.0.14";
      nativeBuildInputs = [ pkgs.arduino-cli ];
      env = {
        ARDUINO_BOARD_MANAGER_ADDITIONAL_URLS =
          "https://espressif.github.io/arduino-esp32/package_esp32_index.json";
      };
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      # TODO: pull this out of https://downloads.arduino.cc/libraries/library_index.json
      # maybe need to remove files other than stagin/ for the hash to be stable
      outputHash = "sha256-Xbx5I8mYtcC4YGRTljPyM6A+LzAukc2gLstuJhzn4Vg=";
    } ''
    HOME=$PWD
    arduino-cli core download $core@$version
    mv .arduino15/staging $out
  '';

  # TODO implement this as a setup-hook of the `downloaded` above.
  mkArduinoInstalled = pkgs.runCommandLocal "arduino-core-esp32-esp32"
    {
      core = "esp32:esp32";
      version = "2.0.14";
      # downloaded = mkArduinoDownloaded;
      env = {
        ARDUINO_DIRECTORIES_DOWNLOADS = mkArduinoDownloaded;
        ARDUINO_BOARD_MANAGER_ADDITIONAL_URLS =
          "https://espressif.github.io/arduino-esp32/package_esp32_index.json";
      };
      nativeBuildInputs = [ pkgs.arduino-cli ];
    } ''
    HOME=$PWD
    arduino-cli core install $core@$version
    mv .arduino15 $out
  '';

  # mkArduinoCompiled = pkgs.runCommandLocal "arduino-core-esp32-esp32"
  #   {
  #     core = "esp32:esp32";
  #     version = "2.0.11";
  #     nativeBuildInputs = [
  #       pkgs.arduino-cli
  #       # for esp32
  #       (pkgs.python3.withPackages (ps: with ps; [ pyserial ]))
  #     ];
  #     src = /tmp/t4/MyProgram;
  #   } ''
  #   HOME=$PWD
  #   cp -r ${mkArduinoInstalled} .arduino15
  #   chmod u+w -R .arduino15
  #   cp -r $src MyProgram
  #   arduino-cli compile --fqbn esp32:esp32:esp32s3:CDCOnBoot=cdc --output-dir build MyProgram
  #   mv build $out
  # '';

}
