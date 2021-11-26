{ lib, stdenv, qtbase, wrapQtAppsHook, elfutils, fetchFromGitHub }:

let
  makeQtMips = { version, sha256, rev ? "v${version}", unstable ? false, doCheck ? false }:
    stdenv.mkDerivation {
      name = "qtmips" + lib.optionalString unstable "-unstable";
      inherit version doCheck;

      src = fetchFromGitHub {
        owner = "cvut";
        repo = "QtMips";
        inherit rev sha256;
      };
      nativeBuildInputs = [ wrapQtAppsHook elfutils ];
      buildInputs = [ qtbase ];

      configurePhase = ''
        mkdir build
        pushd build
        qmake .. "QMAKE_RPATHDIR += ../qtmips_machine ../qtmips_osemu"
        popd
      '';
      buildPhase = "make -C build";
      installPhase = ''
        mkdir -p $out/bin
        install -Dm755 build/qtmips_gui/qtmips_gui $out/bin
        install -Dm755 build/qtmips_cli/qtmips_cli $out/bin
      '';
      checkPhase = "tests/run-all.sh";

      meta = with lib; {
        description = "MIPS CPU simulator for educational purposes";
        homepage = "https://github.com/cvut/QtMips";
        license = licenses.gpl3;
        maintainers = "VojtechStep";
        platforms = platforms.unix;
      };
    };
in
{
  qtmips-unstable = makeQtMips {
    version = "2021-08-14";
    unstable = true;
    rev = "774757c50faf16bb759900dbd9ae685d50b89a85";
    sha256 = "0x15q061pg2h4p5jn8isnzy62x2pk9wb0g32ldayyi5i09a0z3ly";
    doCheck = true;
  };
  qtmips-075 = makeQtMips rec {
    version = "0.7.5";
    sha256 = "1fal7a8y5g0rqqjrk795jh1l50ihz01ppjnrfjrk9vkjbd59szbp";
  };
}
