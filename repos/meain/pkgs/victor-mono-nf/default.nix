{
  stdenv,
  lib,
  nerd-font-patcher,
  victor-mono,
}:
stdenv.mkDerivation {
  pname = "VictorMono-NF";
  version = (builtins.parseDrvName victor-mono.name).version;

  nativeBuildInputs = [nerd-font-patcher victor-mono];

  phases = ["installPhase"];

  preInstall = ''
    mkdir -p $out/share/fonts/truetype && cd "$_"
  '';

  installPhase = ''
    runHook preInstall
    find ${victor-mono}/share/fonts/truetype \
      -name \*.ttf \
      -exec ${nerd-font-patcher}/bin/nerd-font-patcher --complete --quiet --no-progressbars {} \; \
      -exec ${nerd-font-patcher}/bin/nerd-font-patcher --complete --use-single-width-glyphs --adjust-line-height --quiet --no-progressbars {} \;
  '';

  meta = with lib; {
    description = "Free programming font with cursive italics and ligatures";
    homepage = "https://rubjo.github.io/victor-mono";
    license = licenses.ofl;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
