{
  stdenv,
  fetchannex,
  autoPatchelfHook,
  zlib,
  ncurses,
  more,
  cpio,
  rpm,
  libxml2,
  version ? "19.2",
  sha256 ? "1r6ar4p75sykn8iylvj70sq3qxam8skfwa8w6zpzn0v5sm6r5cp6",
  lib,
}: let
  extract = pattern: ''
    for rpm in $(ls $build/rpms/${pattern}); do
      echo "Extracting: $rpm"
      ${rpm}/bin/rpm2cpio $rpm | ${cpio}/bin/cpio -ivd
    done
  '';

  common = {components, ...} @ args:
    stdenv.mkDerivation (rec {
        name = "arm-instruction-emulator-${version}";
        src = fetchannex {
          url = "https://developer.arm.com/tools-and-software/server-and-hpc/compile/arm-instruction-emulator/get-software/download";
          file = "ARM-Instruction-Emulator_${version}_AArch64_RHEL_7_aarch64.tar.gz";
          name = "ARM-Instruction-Emulator_${version}_AArch64_RHEL_7_aarch64.tar.gz";
          inherit sha256;
        };
        dontPatchELF = true;
        dontStrip = true;

        buildInputs = [more cpio rpm autoPatchelfHook];
        installPhase = ''
          sed -i -e "s@/bin/ls@ls@" ${name}*.sh
          bash -x ./${name}*.sh --accept --save-packages-to rpms

          set -xve
          export build=$PWD

          ls rpms

          mkdir $out; cd $out
          ${lib.concatMapStringsSep "\n" extract components}

          set +xve

          mv opt/arm/*/* .
          rm -rf opt/*

          ln -sv bin64 bin
        '';
      }
      // args);
in rec {
  armie = common {
    components = [
      "arm-instruction-emulator-*"
    ];
  };
}
