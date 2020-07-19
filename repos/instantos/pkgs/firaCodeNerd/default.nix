{ stdenv, fetchzip }:

let
  pname = "FiraCode";
  version = "v2.1.0";
  # version = "v2.0.0"; # sha256    = "1bnai3k3hg6sxbb1646ahd82dm2ngraclqhdygxhh7fqqnvc3hdy";
in
stdenv.mkDerivation rec {
  name = "${pname}-nerdfont-${version}";

  src = fetchzip {
    url       = "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${pname}.zip";
    sha256    = "0k064h89ynbbqq5gvisng2s0h65ydnhr6wzx7hgaw8wfbc3qayvp";
    stripRoot = false;
  };

  buildCommand = ''
    install -d "$out/usr/share/fonts/opentype"
    install -d "$out/usr/share/licenses/otf-nerd-fonts-fira-code"
    find "$src" -not -name "*Windows Compatible*" -a -name "*.otf" \
      -exec install -D "{}" --target "$out/usr/share/fonts/opentype" \;
    #install -Dm644 "$src/otf-nerd-fonts-fira-code-LICENSE" "$out/usr/share/licenses/otf-nerd-fonts-fira-code/LICENSE"
  '';

  meta = with stdenv.lib; {
    description = "Nerdfont version of Fira Code";
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
  };
}

