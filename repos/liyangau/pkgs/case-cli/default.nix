{ buildNpmPackage, lib, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "case-cli";
  version = "18ffbe0";

  src = fetchFromGitHub {
    owner = "jopemachine";
    repo = pname;
    rev = version;
    hash = "sha256-/37ZfoOjnw3MR02TSwG9kKzBdxQlepln7JTk3SsR+p4=";
  };

  npmDepsHash = "sha256-z7CevJI9D+azGZD/Gih/5urUu1qZ+0MZnov4TjHHEu4=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Convert string case on your terminal as you want ";
    license = lib.licenses.mit;
    homepage = "https://github.com/jopemachine/case-cli";
  };
}
