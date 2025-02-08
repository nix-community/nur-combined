{stdenv, lib, fetchFromGitHub, maintainers}: stdenv.mkDerivation {
    pname = "libShake";
    version = "0.3.2-unstable-2021-02-14";
    src = fetchFromGitHub {
        owner = "zear";
        repo = "libShake";
        rev = "7183e30cbc2d613333c85eaf50e01e82138e529a";
        hash = "sha256-YG+qP2l2GE5czg+CkMUiR108c2UYAIhTpEht93W/O0o=";
    };
    makeFlags = ["BACKEND=${if stdenv.hostPlatform.isDarwin then "OSX" else "LINUX"}" "PREFIX=$(out)"];
    meta = {
        description = "Simple, cross-platform haptic library";
        homepage = "https://github.com/zear/libShake";
        license = lib.licenses.mit;
        platforms = with lib.platforms; linux ++ darwin;
        maintainers = [maintainers.Rhys-T];
    };
}
