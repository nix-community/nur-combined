{ lib, stdenv, pkgs, fetchFromGitHub, ... }:

let
  src = fetchFromGitHub
    {
      owner = "sudodus";
      repo = "tarballs";
      rev = "93b43c208e902d0f8064b3b0abf461765b273a53";
      sha256 = "sha256-FcI/GKLjhIN0YxXNxE6bagGyQ7o9SwtHfIonrXc4EkE=";
    };
  xorriso = stdenv.mkDerivation (finalAttrs: {
    pname = "xorriso";
    version = "1.5.6.pl02";

    src = pkgs.fetchurl {
      url = "mirror://gnu/xorriso/xorriso-${finalAttrs.version}.tar.gz";
      hash = "sha256-eG+fXfmGXMWwwf7O49LA9eBMq4yahZvRycfM1JZP2uE=";
    };

    doCheck = true;

    preInstall = ''
      substituteInPlace "xorriso-dd-target/xorriso-dd-target" \
        --replace "xdt_init ||" "xdt_lsblk_cmd=${pkgs.util-linux}/bin/lsblk;xdt_dd_cmd=${pkgs.coreutils}/bin/dd;xdt_umount_cmd=${pkgs.umount}/bin/umount ||"
    '';

    buildInputs = [
      pkgs.bzip2
      pkgs.libcdio
      pkgs.libiconv
      pkgs.readline
      pkgs.zlib
    ]
    ++ lib.optionals stdenv.isLinux [
      pkgs.acl
      pkgs.attr
    ];

    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-include unistd.h";

    meta = {
      homepage = "https://www.gnu.org/software/xorriso/";
      description = "ISO 9660 Rock Ridge file system manipulator";
      longDescription = ''
        GNU xorriso copies file objects from POSIX compliant filesystems into Rock
        Ridge enhanced ISO 9660 filesystems and allows session-wise manipulation
        of such filesystems. It can load the management information of existing
        ISO images and it writes the session results to optical media or to
        filesystem objects.
        Vice versa xorriso is able to copy file objects out of ISO 9660
        filesystems.
      '';
      license = lib.licenses.gpl3Plus;
      maintainers = [ lib.maintainers.AndersonTorres ];
      platforms = lib.platforms.unix;
    };
  });
  mkusb-sedd = stdenv.mkDerivation {
    pname = "mkusb-sedd";
    version = "2.8.7";
    inherit src;

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    unpackPhase = ":";
    installPhase = ''
      install -d $out/bin
      tar -xvzf $src/mkusb-plug-plus-tools.tar.gz
      cp plug-dir/mkusb-sedd $out/bin/.mkusb-sedd-wrapped
      runHook postInstall
    '';
    postInstall = ''
      substituteInPlace "$out/bin/.mkusb-sedd-wrapped" \
        --replace "/bin/echo" "echo" \
        --replace "/usr/bin/" ""
      
      makeWrapper "$out/bin/.mkusb-sedd-wrapped" "$out/bin/mkusb-sedd" \
        --inherit-argv0 \
        --prefix PATH : ${lib.makeBinPath [ 
          pkgs.pv
          xorriso
          pkgs.exfatprogs
          pkgs.expect
          pkgs.util-linux
        ]}
    '';
  };
  mkusb-plug = stdenv.mkDerivation
    {
      pname = "mkusb-plug";
      version = "2.8.7";
      inherit src;

      nativeBuildInputs = with pkgs; [ makeWrapper ];

      unpackPhase = ":";
      installPhase = ''
        install -d $out/bin
        tar -xvzf $src/mkusb-plug-plus-tools.tar.gz
        cp plug-dir/mkusb-plug $out/bin/.mkusb-plug-wrapped

        runHook postInstall
      '';

      postInstall = ''
        substituteInPlace "$out/bin/.mkusb-plug-wrapped" \
          --replace "mkusb-sedd" "${mkusb-sedd}/bin/mkusb-sedd" \
          --replace "vermin=2.8" "return 0" \
          --replace "/usr/bin/" "" \
          --replace "exitnr=\$?" "exitnr=0"

        makeWrapper "$out/bin/.mkusb-plug-wrapped" "$out/bin/mkusb-plug" \
          --inherit-argv0 \
          --prefix PATH : ${lib.makeBinPath [ 
            pkgs.pv
            xorriso
            mkusb-sedd
            pkgs.exfatprogs
            pkgs.expect
            pkgs.ntfs3g
            pkgs.util-linux
          ]}
      '';

      meta = with lib; {
        homepage = "https://help.ubuntu.com/community/mkusb/plug";
        description = "Create USB devices with ISO images and persistence";
        license = licenses.gpl3Only;
        platforms = [ "x86_64-linux" ];
        mainProgram = "mkusb-plug";
      };
    };
in
mkusb-plug
