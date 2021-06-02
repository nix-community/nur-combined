{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, llvmPackages
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "wasmer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "wasmerio";
    repo = pname;
    rev = version;
    sha256 = "1mijxfrfpmjqy2axdbybfw4l4hpyc6qvvsda80cvh0xdj7z6hfzn";
    fetchSubmodules = true;
  };

  cargoSha256 = "0n3pbpydzy6l94i2scc7mz3cw43i89m8lsa2mkjbkan8i3gnvshk";

  nativeBuildInputs = [ cmake pkg-config ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";

  meta = with lib; {
    description = "The Universal WebAssembly Runtime";
    longDescription = ''
      Wasmer is a standalone WebAssembly runtime for running WebAssembly outside
      of the browser, supporting WASI and Emscripten. Wasmer can be used
      standalone (via the CLI) and embedded in different languages, running in
      x86 and ARM devices.
    '';
    homepage = "https://wasmer.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne ];
  };
}
