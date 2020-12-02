{ stdenv, lib, fetchzip, makeWrapper, pkgconfig, guile, guile-commonmark, guile-reader }:

stdenv.mkDerivation rec {
  pname = "haunt";
  version = "0.2.4";

  src = fetchzip {
    url = "https://files.dthompson.us/haunt/haunt-${version}.tar.gz";
    sha256 = "1l8sjqm9yby92dkzbk0s6gfasmyab1ipq6qlnmyfvbralvmnvchz";
  };

  nativeBuildInputs = [ makeWrapper pkgconfig ];
  buildInputs = [ guile guile-commonmark guile-reader ];

  doCheck = true;

  postInstall = ''
    # There doesn't seem to be a way to query the right version suffix.
    loadPath=$(echo $out/share/guile/site/*)
    compiledLoadPath=$(echo $out/lib/guile/*/site-ccache)
    wrapProgram $out/bin/haunt \
      --prefix GUILE_LOAD_PATH : "$loadPath:$GUILE_LOAD_PATH" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$compiledLoadPath:$GUILE_LOAD_COMPILED_PATH"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/haunt --version
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Functional static site generator";
    longDescription = ''
      Haunt is a static site generator written in Guile Scheme.
      Haunt features a functional build system and an extensible
      interface for reading articles in any format.
    '';
    homepage = "https://dthompson.us/projects/haunt.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
