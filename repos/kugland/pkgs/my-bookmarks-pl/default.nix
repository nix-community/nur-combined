{ pkgs
, lib
, stdenvNoCC
, fetchFromGitHub
, perlPackages
, makeWrapper
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "my-bookmarks.pl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kugland";
    repo = "my-bookmarks-pl";
    rev = "v${version}";
    hash = "sha256-RzSqoyd0vARxoaU7hcEgaycXMPbvlhOBrOuYpmNYKJk=";
  };

  propagatedBuildInputs = with pkgs; [
    libnotify
    perl
    rofi
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -m555 -Dt $out/bin my-bookmarks.pl
    install -m444 -Dt $out/share/doc/${pname}-${version} README.md screenshot.png
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/my-bookmarks.pl \
      --prefix PERL5LIB : "${with perlPackages; makePerlPath [GetoptLong URI]}"
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/kugland/my-bookmarks.pl";
    description = "Simple script to manage bookmarks in a text file and display them using rofi.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
