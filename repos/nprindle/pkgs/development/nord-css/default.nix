{ stdenv, fetchurl
, minify
, minifyCSS ? true # whether or not to minify the CSS
}:

let
  fetchGitHubFile = { owner, repo, rev, sha256, path }: fetchurl {
    url = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}/${path}";
    inherit sha256;
  };
in

stdenv.mkDerivation {
  pname = "nord";
  version = "unstable-2019-03-16";

  src = fetchGitHubFile {
    owner = "arcticicestudio";
    repo = "nord";
    rev = "b7146acd87547b59810b3499d87f55dbfc25f105";
    sha256 = "0agmh4xb0fsl39lvn0714lq47vs5cc81kp5r009863l133z5b8r7";
    path = "src/nord.css";
  };

  phases = [ "installPhase" ];
  installPhase =
    let minifyPhase =
      if minifyCSS then
        ''${minify}/bin/minify --mime text/css "$src" > "$out/nord.css"''
      else
        ''cp "$src" "$out/nord.css"'';
    in ''
      mkdir -p "$out"
      ${minifyPhase}
    '';

  meta = with stdenv.lib; {
    description = "An arctic, north-bluish color palette";
    homepage = "https://www.nordtheme.com";
    platforms = platforms.all;
    license = licenses.mit;
  };
}
