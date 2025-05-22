{
  lib,
  buildNobPackage,
  fetchFromGitHub,
  replaceVars,
  raylib,
}:
buildNobPackage {
  pname = "panim";
  version = "0-unstable-2024-12-23";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "panim";
    rev = "fb77e5e009c55cf677508fb7c6feeae0dfef24b7";
    hash = "sha256-Ubnsucgl4nCVFlm7ANEHKfM8Ka7dr/O5SmC1ECuw7Q4=";
  };

  patches = [
    (replaceVars ./use-nix-raylib.patch { RAYLIB = raylib; })
    ./no-c3c.patch # these are broken examples so no point in trying to package them
  ];
  outPaths = [ "build/panim" ];

  buildInputs = [ raylib ];

  postInstall = ''
    mkdir -p $out/lib
    cp build/lib{bezier,cpp,square,template,tm}.so $out/lib
  '';

  meta = {
    description = "Programming Animation Engine";
    homepage = "https://github.com/tsoding/panim";
    license = lib.licenses.mit;
    mainProgram = "panim";
    platforms = lib.platforms.all;
  };
}
