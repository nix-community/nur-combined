{ pkgs, lib }:

let
  yogabook-src = pkgs.fetchgit {
    url = "https://github.com/jekhor/yogabook-linux.git";
    rev = "b699dfd21c0a1b4c32f4a6851e621b6324aa5f30";
    sha256 = "sha256-qTQZqHtNXoGbM9U4iASuobzOeypJiWf6sXQn2AiD+1A=";
    fetchSubmodules = true;
  };
in
{
  src = yogabook-src;

  touch-keyboard = pkgs.stdenv.mkDerivation {
    pname = "touch-keyboard-yogabook";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "jekhor";
      repo = "chromiumos_touch_keyboard";
      rev = "deccecb08889aa031664f5e22ec5c4c33fb6c41c";
      hash = "sha256-ASddTw/b6w29FxI+N66FwZCqJphQrprQPITHkYKMEtU=";
    };

    patches = [ ./touchpad-fix.patch ];

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
    ];
    buildInputs = with pkgs; [
      systemd
      udev
    ];

    postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace-warn "\''${UDEV_DIR}/rules.d" "lib/udev/rules.d" \
        --replace-warn "\''${UDEV_DIR}/hwdb.d" "lib/udev/hwdb.d" \
        --replace-warn "\''${SYSTEMD_SYSTEM_UNIT_DIR}" "lib/systemd/system"
    '';

    meta = with lib; {
      description = "Touch keyboard driver for Lenovo Yoga Book";
      homepage = "https://github.com/jekhor/chromiumos_touch_keyboard";
      license = licenses.bsd3;
      platforms = platforms.linux;
    };
  };

  yogabook-modes-handler = pkgs.stdenv.mkDerivation {
    pname = "yogabook-modes-handler";
    version = "1.0.0";

    src = "${yogabook-src}/yogabook-support";

    buildInputs = [
      (pkgs.python3.withPackages (
        ps: with ps; [
          evdev
          pyudev
        ]
      ))
    ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp yogabook-modes-handler $out/bin/
      chmod +x $out/bin/yogabook-modes-handler
    '';

    meta = with lib; {
      description = "Yoga Book modes handler";
      platforms = platforms.linux;
    };
  };

  iio-sensor-proxy-yogabook = pkgs.stdenv.mkDerivation {
    pname = "iio-sensor-proxy-yogabook";
    version = "3.1-patched";

    src = "${yogabook-src}/iio-sensor-proxy";

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
      gobject-introspection
    ];
    buildInputs = with pkgs; [
      glib
      systemd
      libgudev
      polkit
    ];

    PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";
    PKG_CONFIG_UDEV_UDEVDIR = "${placeholder "out"}/lib/udev";

    meta = with lib; {
      description = "Patched IIO sensor proxy for Lenovo Yoga Book hinge and tablet mode";
      homepage = "https://gitlab.freedesktop.org/jekhor/iio-sensor-proxy";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };

  yogabook-config = pkgs.runCommandCC "yogabook-kernel-config" {
    nativeBuildInputs = with pkgs; [ gnumake bison flex elfutils perl ];
  } ''
    cp -r ${yogabook-src}/yogabook-linux-kernel/* .
    chmod -R +w .
    make ARCH=x86 yogabook_defconfig
    cp .config $out
  '';

  yogabook-modules = { kernel, kernelModuleMakeFlags }: pkgs.stdenv.mkDerivation {
    pname = "yogabook-modules";
    version = kernel.version;

    src = yogabook-src;

    nativeBuildInputs = kernel.moduleBuildDependencies;

    preConfigure = ''
      patch -p1 -i ${./yogabook-wmi-power.patch}
      cp yogabook-linux-kernel/drivers/platform/x86/serdev_helpers.h .
      mkdir build
      cp -r yogabook-linux-kernel/drivers/platform/x86/x86-android-tablets/* build/
      cp yogabook-linux-kernel/drivers/input/misc/drv260x.c build/
      cp yogabook-linux-kernel/drivers/platform/x86/lenovo/yogabook.c build/
      substituteInPlace build/lenovo.c \
        --replace-fail 'PROPERTY_ENTRY_U32("mode", 0),' 'PROPERTY_ENTRY_U32("mode", 1),'
      cd build

      cat << 'EOF' > Makefile
      obj-m += vexia_atla10_ec.o
      obj-m += x86-android-tablets.o
      x86-android-tablets-y := core.o dmi.o shared-psy-info.o asus.o lenovo.o other.o
      obj-m += drv260x.o
      obj-m += lenovo-yogabook.o
      lenovo-yogabook-y := yogabook.o
      EOF
    '';

    makeFlags = kernelModuleMakeFlags ++ [
      "-C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "modules"
    ];

    preBuild = ''
      makeFlagsArray+=("M=$(pwd)")
    '';

    installPhase = ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/updates
      find . -name '*.ko' -exec cp '{}' $out/lib/modules/${kernel.modDirVersion}/updates/ \;
      find $out/lib/modules/${kernel.modDirVersion}/updates/ -name '*.ko' -exec xz -f '{}' \;
    '';

    meta = {
      description = "Patched kernel modules for Lenovo Yoga Book (x86-android-tablets, drv260x)";
      license = lib.licenses.gpl2Only;
      platforms = lib.platforms.linux;
    };
  };
}
