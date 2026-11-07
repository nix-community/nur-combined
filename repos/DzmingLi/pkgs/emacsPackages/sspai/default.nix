{ lib, emacsPackages, fetchFromGitHub }:

emacsPackages.trivialBuild {
  pname = "sspai";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "sspai.el";
    rev = "2f00e64d7f78ff72dfb90d8d1c5609fbcf27f4df";
    hash = "sha256-c0Vv7tVZeVRzkEI5wO8UAyoVDy2kKNO9goKRT59QM2U=";
  };
  turnCompilationWarningToError = true;
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs --batch -Q -L . --eval "(unless (require 'sspai nil t) (error \"Failed to load sspai\"))"
    runHook postCheck
  '';
  meta = with lib; {
    description = "Publish SSPAI articles from local Org files";
    homepage = "https://github.com/DzmingLi/sspai.el";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    broken = versionOlder emacsPackages.emacs.version "31.1";
  };
}
