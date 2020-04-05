{ lib, stdenv, fetchFromGitHub, makeWrapper, python2Packages }:

stdenv.mkDerivation rec {
  pname = "gmpydl";
  version = "2019-09-12";

  src = fetchFromGitHub {
    owner = "stevenewbs";
    repo = pname;
    rev = "3022a6613547e1b08ea884a9323d6f0e2cf91a43";
    sha256 = "0jxwyp4rk51573x4is9ncjrgx3gzxzvfi4h53nd07lwkg6g7ng18";
  };

  nativeBuildInputs = [ python2Packages.wrapPython ];
  propagatedBuildInputs = with python2Packages; [ gmusicapi ];

  # TODO: The wrapper doesn't quite work yet. This works just fine though:
  # cd $(nix-build -A gmpydl.src)
  # nix-shell -p 'python.withPackages(p: with p; [ gmusicapi ])'
  # ./gmpydl.py
  installPhase = ''
    mkdir -p $out/bin
    cp gmpydl.py $out/bin/

    wrapProgram $out/bin/gmpydl.py \
        --prefix PATH : "$PATH" \
        --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  meta = with stdenv.lib; {
    description = "Google Music Python Downloader";
    homepage = "https://github.com/stevenewbs/gmpydl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bhipple ];
  };
}
