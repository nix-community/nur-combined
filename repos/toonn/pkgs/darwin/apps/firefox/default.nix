{ stdenv, lib, fetchurl, undmg
, version ? "93.0"
}:
stdenv.mkDerivation rec {
  inherit version;

  name = "firefox-app-${version}";

  pname = "Firefox";

  # To update run:
  # nix-prefetch-url --name 'firefox-app-<version>.dmg' 'https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US'
  src = let
    versions = {
      "86.0" = {
        sha256 = "04jslsfg073xb965hvbm7vdrdymkaiyyrgclv9qdpcyplis82rxc";
      };
      "86.0.1" = {
        sha256 = "1cd55z11wpkgi1lnidwg8kdxy8b6p00arz07sizrbyiiqxzrmvx3";
      };
      "87.0" = {
        sha256 = "1cih6i2p53mchqqrw2wlqhfka59p5qm4a7d0zc9ism0gvq5zpiz2";
      };
      "88.0" = {
        sha256 = "0cqgizwfhh9vh49swpi2vbdrqr5ri6jlir29bsf397ijvgss24lf";
      };
      "88.0.1" = {
        sha256 = "0z9p6jng7is8pq21dffjr6mfk81q08v99fwmhj22g9b1miqxrvcz";
      };
      "89.0" = {
        sha256 = "0z86q1hlwmhfwrddhapwiy8qrn3v03d7nbsnzhnkr3fc9vz58ga3";
      };
      "89.0.1" = {
        sha256 = "02pvwsjaz60graha7hz25z3kx24ycvcfgwpzzdv5xpb3cfmlvis9";
      };
      "89.0.2" = {
        sha256 = "0hwhnmd88ymy0binw10azq81f09qmdz6gmd2jlvh7q234cy168nc";
      };
      "90.0" = {
        sha256 = "0qw8biv5p7j1gqz0ziadj7hd0kh86nlndwxvc39ifq52w8w81h6v";
      };
      "90.0.1" = {
        sha256 = "018zfpgc16k7g6hpixv72f21haknsfvrhahi9jzfbisj5g2bkhbn";
      };
      "90.0.2" = {
        sha256 = "00yxk43pa2f7s565b4g6cs0nv5wr023xmw1ajq45ksacp2kzp93k";
      };
      "91.0" = {
        sha256 = "1yx647d1aibw3ydjpl8ysgz2smim48x6bykq2lq3y2rjj3s46v6j";
      };
      "91.0.1" = {
        sha256 = "0a7snz0qxbzhwbqkwmbivfx9zn4b009qy8xz74wk47an60dschz7";
      };
      "91.0.2" = {
        sha256 = "0c5b7k4q7k3q9lk0k22h6csk3bwqxkkfya6rskb5k9knn7qzyis1";
      };
      "92.0" = {
        sha256 = "0kln28330jhmpdvsdsnrqnl0fkpb18i9vi1n98v99aq61ncqr5v8";
      };
      "92.0.1" = {
        sha256 = "1sy856rbfavzbyhrb7kii0k32v674nv67vqr7a6211db2nii297q";
      };
      "93.0" = {
        sha256 = "1ihb85kxnwxsgbr4iy0nm6zqs5mn7ww9in8m3r1yws5zq8l8dixl";
      };
    };
    hash = versions."${version}";
  in fetchurl {
    inherit (hash) sha256;
    url =
      "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
    name = "${name}.dmg";
  };

  buildInputs = [ undmg ];

  # The dmg contains the app and a symlink, the default unpackPhase tries to cd
  # into the only directory produced so it fails.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    mv ${pname}.app $out/Applications
    '';

  meta = with lib; {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "http://www.mozilla.org/firefox/";
    license = {
      free = false;
      url = "http://www.mozilla.org/en-US/foundation/trademarks/policy/";
    };
    maintainers = with maintainers; [ toonn ];
    platforms = [ "x86_64-darwin" ];
  };
}
