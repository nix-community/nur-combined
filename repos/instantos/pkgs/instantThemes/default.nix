{ lib
, stdenv
, fetchFromGitHub
, Paperbash
}:
stdenv.mkDerivation {

  pname = "instantThemes";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantTHEMES";
    rev = "890109760f29055fa52102b23355d91db2b493b1";
    sha256 = "0bj786mihagg47y03j3q9hiha5gcr38akscvnp63az9bb4y61j8n";
    name = "instantOS_instantThemes";
  };

  postPatch = ''
    substituteInPlace instantthemes \
      --replace "/usr/share/instantthemes" "$out/share/instantthemes" \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash"
    '';

  installPhase = ''
    install -Dm 555 instantthemes $out/bin/instantthemes
    mkdir -p $out/share/instantthemes
    cp -r * $out/share/instantthemes
  '';

  propagatedBuildInputs = [ Paperbash ];

  meta = with lib; {
    description = "instantOS Themes";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantTHEMES";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
