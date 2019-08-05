let
  version = "1.00";
  fn = variant: sha256: { stdenvNoCC, fetchzip, lib }: stdenvNoCC.mkDerivation {
    name = "droid-sans-mono-${lib.toLower variant}-${version}";
    inherit version;
    src = fetchzip {
      url = "http://www.cosmix.org/software/files/DroidSansMono${variant}.zip";
      inherit sha256;
    };
    phases = ["installPhase"];
    installPhase = ''
      install -Dm0644 -t $out/share/fonts/truetype/ $src/DroidSansMono${variant}.ttf
    '';
  };
in {
  droid-sans-mono-dotted = (fn "Dotted" "0l8icqrx6hxqrlz8kbwcynma2nrbcay8gpn1myfhr2hwc1zlp92x");
  droid-sans-mono-slashed = (fn "Slashed" "1vs81lrfzd7wfhs5mp976h06nfl4ym6kl4n6pzzsp0d769891x4d");
}
