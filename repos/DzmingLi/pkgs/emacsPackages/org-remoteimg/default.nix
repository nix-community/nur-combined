{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

emacsPackages.trivialBuild {
  pname = "org-remoteimg";
  version = "0-unstable-2026-08-28";

  # TODO: After https://github.com/gaoDean/org-remoteimg/pull/8 is merged,
  # switch back to the upstream owner and pin the resulting upstream commit.
  # This pull-request revision completes the Org 9.8 preview migration and
  # makes remote images respect org-image-max-width.
  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "org-remoteimg";
    rev = "2eb342ebffc8171463dbc9b6d7b681f07976e57e";
    hash = "sha256-ggITA7CRP1wPpEWqaiYer3iYT4CZYvutwkzMMJd2gGo=";
  };

  packageRequires = [ emacsPackages.org ];
  turnCompilationWarningToError = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    emacs --batch -Q -L . \
      -l test/org-remoteimg-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  meta = with lib; {
    description = "Display remote inline images in Org with automatic caching";
    homepage = "https://github.com/gaoDean/org-remoteimg";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
