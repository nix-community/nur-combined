{stdenv, lib, fetchFromGitHub, xcbuildHook, unstableGitUpdater, maintainers}: stdenv.mkDerivation {
    pname = "impluse";
    version = "0-unstable-2025-12-24";
    src = fetchFromGitHub {
        owner = "boredzo";
        repo = "impluse-hfs";
        rev = "39c5943e6e2fc7884f87cda8ad51e0d5394f5a87";
        hash = "sha256-VdZa/k4qPrk9V20TPjC1tNIwciW6hm5ZpkTDPpzpdPU=";
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
    passthru.updateScript = unstableGitUpdater {};
}
