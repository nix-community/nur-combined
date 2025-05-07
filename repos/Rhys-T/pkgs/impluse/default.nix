{stdenv, lib, fetchFromGitHub, xcbuildHook, maintainers}: stdenv.mkDerivation {
    pname = "impluse";
    version = "0-unstable-2024-03-14";
    src = fetchFromGitHub {
        owner = "boredzo";
        repo = "impluse-hfs";
        rev = "e14dc334d6ef2f87da2fb47274a683b40a164373";
        hash = "sha256-XmmWOKSMKHxCNULoit/HtOqPrkqveqfFpdL4gxmDfm0=";
    };
    nativeBuildInputs = [xcbuildHook];
    xcbuildFlags = ["CLANG_ENABLE_MODULES=NO"];
    env.NIX_LDFLAGS = "-framework CoreServices";
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/bin
        cp Products/Release/impluse-hfs "$out"/bin/impluse
        runHook postInstall
    '';
    meta = {
        description = "Tool for converting HFS (Mac OS Standard) volumes to HFS+ (Mac OS Extended) format";
        homepage = "https://github.com/boredzo/impluse-hfs";
        platforms = lib.platforms.darwin;
        license = lib.licenses.bsd3;
        mainProgram = "impluse";
        maintainers = [maintainers.Rhys-T];
    };
}
