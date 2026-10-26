{ lib
, buildPythonApplication
, fetchFromGitHub
, setuptools
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "followcheck";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "theluckystrike";
    repo = "followcheck";
    rev = "v${version}";
    hash = "sha256-vd575r28hTorLFj3PcBmoilP/i0Zrwqjm+5jZbW8U7g=";
  };

  build-system = [ setuptools ];

  # Standard library only; no runtime dependencies.
  dependencies = [ ];

  # The test suite runs against a real HTTP server bound to 127.0.0.1.
  __darwinAllowLocalNetworking = true;
  nativeCheckInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "followcheck" ];

  meta = with lib; {
    description = "Decide whether an outbound link on a page is really followable and really crawlable";
    longDescription = ''
      followcheck fetches a page and reports whether a link to a given target is
      actually followable and crawlable, instead of assuming it from an HTTP 200.
      It checks six independent failure modes: the anchor missing from the served
      HTML, rel=nofollow/ugc/sponsored on the anchor, a robots meta tag, an
      X-Robots-Tag response header, a robots.txt disallow on the path, and a body
      that varies by Accept header. A 403, 503 or challenge body is reported as
      UNVERIFIED-BOT-WALLED rather than as a negative verdict. The CLI exits 0
      only on DOFOLLOW, so it can gate CI. Standard library only.
    '';
    homepage = "https://handsofflinks.com/dofollow-nofollow-checker/";
    downloadPage = "https://github.com/theluckystrike/followcheck";
    changelog = "https://github.com/theluckystrike/followcheck/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "followcheck";
    platforms = platforms.all;
  };
}
