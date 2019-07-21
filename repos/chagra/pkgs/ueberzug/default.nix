{ python3Packages, fetchFromGitHub, libX11, libXext }:

with python3Packages;

let
pillow-simd = pillow.overrideAttrs (_: rec {
	pname = "Pillow-SIMD";
	version = "5.4.1";

	src = fetchFromGitHub {
	owner = "uploadcare";
	repo = "pillow-simd";
	rev = version;
	sha256 = "07c4pkyfg641mb0xfqw349p5s11n4f241v3mkvba2z58w112kgmf";
	};
	});
in
buildPythonPackage rec {
    pname = "ueberzug";
    version = "18.1.3";

    src = fetchPypi {
	inherit pname version;
	sha256 = "1galc64vbi8d1nbq7d8387my87jq4kqmv30jhlcwrl8g7yph00kg";
    };

    postPatch = ''
	substituteInPlace setup.py --replace "pillow-simd" "pillow"
	'';

    buildInputs = [ libX11 libXext ];

    propagatedBuildInputs = [
	xlib
	    pillow-simd
	    psutil
	    docopt
	    attrs
    ];
}
