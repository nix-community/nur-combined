{ stdenv, git, fetchgit, ocamlPackages, makeWrapper, z3 }:

let
  solverPath = stdenv.lib.makeBinPath [ z3 ];
in
ocamlPackages.buildOcaml rec {
  name = "kittel-koat";
  version = "2017-01-15";

  src = fetchgit {
    url = "http://github.com/s-falke/kittel-koat.git";
    rev = "b8618f7f7a3cb40dd0f7bb1d60696afc32cf9986";
    sha256 = "04rpcz6l0wllzwb0vg17c3800rkq9ykc49zm7qgy7fdn4nr6pwyy";
    leaveDotGit = true;
  };

  nativeBuildInputs = [ git makeWrapper ];
  buildInputs = with ocamlPackages; [ ocamlgraph ];

  patchPhase = ''
    patchShebangs make_git_sha1.sh
  '';

  configurePhase = ''
    cat > user.cfg <<EOF
    HAVE_APRON=false
    HAVE_Z3=false
    EOF

    substituteInPlace Makefile --replace ocamlbuild "ocamlbuild -pkg ocamlgraph"
  '';

  installPhase = ''
    install -Dm755 {_build,$out/libexec}/kittel.native
    install -Dm755 {_build,$out/libexec}/koat.native

    mkdir -p $out/bin
    for x in kittel koat; do
      makeWrapper "$out/libexec/$x.native" $out/bin/$x --add-flags "-smt-solver z3" --prefix PATH : ${solverPath}
    done
  '';


  meta = with stdenv.lib; {
    description = "KITTeL/KoAT";
    homepage = https://github.com/s-falke/kittel-koat;
    license = licenses.asl20;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
