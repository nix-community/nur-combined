{ stdenv
, lib
, runCommand
, git
, cacert
, pkg-config
, hidapi
, jimtcl
, libjaylink
, libusb1
, libgpiod1
, autoreconfHook
, fetchFromGitHub

, enableFtdi ? true, libftdi1

# Allow selection the hardware targets (SBCs, JTAG Programmers, JTAG Adapters)
, extraHardwareSupport ? []
}:

stdenv.mkDerivation rec {
  pname = "openocd-riscv";
  version = "2025-10-09";

  src = fetchFromGitHub {
    owner = "riscv-collab";
    repo = "riscv-openocd";
    fetchSubmodules = true;
    # deepClone = true;
    rev = "eb01c632a4bb1c07d2bddb008d6987c809f1c496";
    sha256 = "sha256-4a6Mt7nT6Lwvj5hf3vC9CFyZ+wSPrdXn/Ng670ZyRLI=";
    # sha256 = "";
  };

  # src = runCommand "openocd-riscv-src" {
  #   rev = "af786c0eca6a3b845c8e6f2bb41fdc4ecbe83748";
  #   outputHash = "sha256-p+oyf0yk7hZvJ7T0WxF4/zjcw8IYFWL1Xf3B76GW/kY=";
  #   url = "https://github.com/riscv/riscv-openocd.git";
  #   outputHashMode = "recursive";
  #   outputHashAlgo = "sha256";
  #   nativeBuildInputs = [ git ];
  #   GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  # } ''
  #   git init $out
  #   cd $out
  #   git remote add origin $url
  #   git fetch --depth=1 origin $rev
  #   git checkout FETCH_HEAD
  #   git submodule update --recursive --init
  #   rm -rf $out/.git
  # '';

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  buildInputs = [ hidapi jimtcl libftdi1 libjaylink libusb1 ]
    ++ lib.optional stdenv.isLinux libgpiod1;

  configureFlags = [
    "--disable-werror"
    "--disable-internal-jimtcl"
    "--disable-internal-libjaylink"
    "--enable-jtag_vpi"
    "--enable-buspirate"
    "--enable-remote-bitbang"
    (lib.enableFeature enableFtdi "ftdi")
    (lib.enableFeature stdenv.isLinux "linuxgpiod")
    (lib.enableFeature stdenv.isLinux "sysfsgpio")
  ] ++
    map (hardware: "--enable-${hardware}") extraHardwareSupport
  ;

  enableParallelBuilding = true;

  env.NIX_CFLAGS_COMPILE = toString (lib.optionals stdenv.cc.isGNU [
    "-Wno-error=cpp"
    "-Wno-error=strict-prototypes" # fixes build failure with hidapi 0.10.0
  ]);

  postInstall = lib.optionalString stdenv.isLinux ''
    mkdir -p "$out/etc/udev/rules.d"
    rules="$out/share/openocd/contrib/60-openocd.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi
    ln -s "$rules" "$out/etc/udev/rules.d/"
  '';

  meta = with lib; {
    description = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing";
    longDescription = ''
      OpenOCD provides on-chip programming and debugging support with a layered
      architecture of JTAG interface and TAP support, debug target support
      (e.g. ARM, MIPS), and flash chip drivers (e.g. CFI, NAND, etc.).  Several
      network interfaces are available for interactiving with OpenOCD: HTTP,
      telnet, TCL, and GDB.  The GDB server enables OpenOCD to function as a
      "remote target" for source-level debugging of embedded systems using the
      GNU GDB program.
    '';
    homepage = "https://openocd.sourceforge.net/";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    mainProgram = "openocd";
  };
}


# { lib, fetchFromGitHub, automake, autoconf, libtool, which, openocd, capstone, jimtcl }:

# openocd.overrideAttrs (old: {
#   version = "riscv";
#   name = "openocd-riscv";
#   src = fetchFromGitHub {
#     owner = "riscv";
#     repo = "riscv-openocd";
#     fetchSubmodules = true;
#     rev = "ee5c5c292fd04f62f88fc0ae3a8d69c403aa2803";
#     sha256 = "sha256-H5SrnbvQ2auqoUfGYYB1QaAgZqR/Nyop7Xx7rpf2yYk=";
#   };
#   env.NIX_CFLAGS_COMPILE = old.env.NIX_CFLAGS_COMPILE + toString [
#     ""
#     "-Wno-unused-variable"
#     "-Wno-implicit-function-declaration"
#   #   "-Wno-return-type"
#   #   "-Wno-int-conversion"
#   #   "-Wno-implicit-function-declaration"
#   ];
#   nativeBuildInputs = old.nativeBuildInputs or [] ++ [ automake autoconf libtool which ];
#   buildInputs = old.buildInputs or [] ++ [ capstone jimtcl ];
#   preConfigure = ''
#     SKIP_SUBMODULE=1 ./bootstrap
#   '';
#   HOME = "/build/home";
#   preBuild = ''
#     mkdir -p $HOME
#   '';
#   ## libusb patch is already applied in riscv fork
#   patches = [ ];
# })
