{
  lib,
  melpaBuild,
  fetchFromGitHub,
  libjxl,
}:

melpaBuild {
  pname = "org-jxl-images";
  version = "0-unstable-2026-08-02";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "org-jxl-images.el";
    rev = "8c72ff9f7e8726ea6a149e8d343c6c381d6971d5";
    hash = "sha256-2D9dlJal0NZ25h6BUZI2+jAkeZHjnh2HZmMZqkmUui8=";
  };

  postPatch = ''
    substituteInPlace org-jxl-images.el \
      --replace-fail 'org-jxl-djxl-program "djxl"' \
                       'org-jxl-djxl-program "${lib.getBin libjxl}/bin/djxl"' \
      --replace-fail 'org-jxl-cjxl-program "cjxl"' \
                       'org-jxl-cjxl-program "${lib.getBin libjxl}/bin/cjxl"'
  '';

  turnCompilationWarningToError = true;

  checkPhase = ''
    runHook preCheck

    # The tests decode real JXL data, so djxl must be reachable via PATH
    # (the package's defcustom points at the absolute libjxl path after
    # postPatch, but the tests use `executable-find`).
    export PATH=${lib.getBin libjxl}/bin:$PATH

    emacs --batch -L . \
      -l org-jxl-images-tests.el \
      -f ert-run-tests-batch-and-exit

    runHook postCheck
  '';

  doCheck = true;

  meta = {
    homepage = "https://github.com/nagy/org-jxl-images.el";
    description = "Inline JPEG XL images in Org mode";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
