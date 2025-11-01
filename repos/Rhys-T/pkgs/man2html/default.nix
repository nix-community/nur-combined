{stdenvNoCC, lib, fetchurl, perl, maintainers}: stdenvNoCC.mkDerivation rec {
    pname = "man2html";
    version = "3.0.1-unstable-2025-10-05";
    src = let
        shortDate = lib.concatStrings (lib.lists.drop 4 (builtins.splitVersion version));
    in fetchurl {
        url = "https://invisible-island.net/archives/man2html/man2html-${shortDate}.tgz";
        hash = "sha256-O8wWQoZfyU7qIyrUZTpvVAZhfpZ+AT3IRoTQo8/22zw=";
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
    passthru.updateScript = ./update.sh;
    meta = {
        description = "Unix manpage-to-HTML converter";
        homepage = "https://invisible-island.net/scripts/man2html.html";
        changelog = "https://raw.githubusercontent.com/ThomasDickey/man2html/master/CHANGES";
        mainProgram = "man2html";
        license = lib.licenses.gpl2Plus;
        maintainers = [maintainers.Rhys-T];
    };
}
