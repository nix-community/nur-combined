{stdenvNoCC, lib, fetchurl, perl, maintainers}: stdenvNoCC.mkDerivation rec {
    pname = "man2html";
    version = "3.0.1-unstable-2024-01-05";
    src = let
        shortDate = lib.concatStrings (lib.lists.drop 4 (builtins.splitVersion version));
    in fetchurl {
        url = "https://invisible-island.net/archives/${pname}/${pname}-${shortDate}.tgz";
        hash = "sha256-qtc069gmJeh84zR0iVUvV4D6ZTnf7aq2dv/5V+wZFVs=";
    };
    nativeBuildInputs = [perl];
    buildInputs = [perl];
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/{bin,share/man/man1}
        perl install.me -batch -binpath "$out/bin" -manpath "$out/share/man"
        install -Dm644 COPYING "$out/share/licenses/man2html/COPYING"
        runHook postInstall
    '';
    meta = {
        description = "Unix manpage-to-HTML converter";
        homepage = "https://invisible-island.net/scripts/man2html.html";
        changelog = "https://raw.githubusercontent.com/ThomasDickey/man2html/master/CHANGES";
        mainProgram = "man2html";
        license = lib.licenses.gpl2Plus;
        maintainers = [maintainers.Rhys-T];
    };
}
