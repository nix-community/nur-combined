{
	lib,
	pkgs,
	stdenv,
	cmake,
	ctestCheckHook,
	opencv,
	glfw,
}:
stdenv.mkDerivation (finalAttrs: {
	pname = "libcimbar";
	version = "0.6.9";
	src = pkgs.fetchFromGitHub {
		owner = "sz3";
		repo = "libcimbar";
		rev = "v${finalAttrs.version}";
		hash = "sha256-un1LjyPMjHUijYicpP3xDNXAlMD5bSJHX142cFkRDPE=";
	};
	# TODO filesystem path problem
	doCheck = false;
	nativeBuildInputs = [
		cmake
	];
	nativeCheckInputs = [
		ctestCheckHook
	];
	buildInputs = [
		opencv.cxxdev
		glfw.dev
	];
	cmakeFlags = [
		"-DCMAKE_CXX_FLAGS=\"-mssse3\""
	];
	
	meta = {
		description = "Color-icon-matrix barcode implementation";
		homepage = "https://github.com/sz3/libcimbar";
		license = lib.licenses.mpl20;
	};
})
