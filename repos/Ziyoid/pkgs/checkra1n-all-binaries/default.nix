{ lib, stdenv, fetchurl, }:

let
  binaries = {
    "x86_64-darwin" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/macos/754bb6ec4747b2e700f01307315da8c9c32c8b5816d0fe1e91d1bdfc298fe07b/checkra1n%20beta%200.12.4.dmg";
      sha256 = "0yz0iwlzrgfij4ggxl0nb25jrhy9m1fk21qky00fgcj78znbcjvm";
    };

    "x86_64-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/linux/cli/x86_64/dac9968939ea6e6bfbdedeb41d7e2579c4711dc2c5083f91dced66ca397dc51d/checkra1n";
      sha256 = "07f5glwwlrpdvj8ky265q8fp3i3r4mz1vd6yvvxnnvpa764rdjfs";
    };

    "armv7l-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/linux/cli/arm/ff05dfb32834c03b88346509aec5ca9916db98de3019adf4201a2a6efe31e9f5/checkra1n";
      sha256 = "1xg967z6wahs43sas69hvscdn5lrrb2sw2b56j43ph1l52rxy1gz";
    };

    "aarch64-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/linux/cli/arm64/43019a573ab1c866fe88edb1f2dd5bb38b0caf135533ee0d6e3ed720256b89d0/checkra1n";
      sha256 = "1l49dcjj1mrydq6ywcsm2fphr2xkbgfz5cgdi3z6dj5i79brl0a3";
    };

    "i686-linux" = fetchurl {
      url =
        "https://assets.checkra.in/downloads/linux/cli/i486/77779d897bf06021824de50f08497a76878c6d9e35db7a9c82545506ceae217e/checkra1n";
      sha256 = "0zi1mv70cmalhaf7mnrmkrnqr1vng94hh3z59n122q7hgf4rsxvp";
    };
  };

in stdenv.mkDerivation rec {
  pname = "checkra1n-all-binaries";
  version = "0.12.4";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    ${lib.concatStringsSep "\n" (map (arch: ''
      cp ${binaries.${arch}} $out/bin/checkra1n-${arch}
    '') (builtins.attrNames binaries))}
  '';

  meta = with lib; {
    description = "Jailbreak for iPhone 5s though iPhone X, iOS 12.0 and up";
    homepage = "https://checkra.in/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ onny ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-linux"
    ];
  };
}
