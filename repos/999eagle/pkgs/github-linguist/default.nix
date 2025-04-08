{
  lib,
  bundlerApp,
  ruby,
  cmake,
  pkg-config,
  bundlerUpdateScript,
  icu,
  openssl,
  zlib,
}:
bundlerApp {
  pname = "github-linguist";
  exes = ["github-linguist"];

  inherit ruby;
  gemdir = ./.;

  nativeBuildInputs = [cmake pkg-config];
  buildInputs = [icu openssl zlib];

  passthru.updateScript = bundlerUpdateScript "github-linguist";

  meta = with lib; {
    description = "This library is used on GitHub.com to detect blob languages, ignore binary or vendored files, suppress generated files in diffs, and generate language breakdown graphs.";
    homepage = "https://github.com/github/linguist/";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
