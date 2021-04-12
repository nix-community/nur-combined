{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "grit";
  version = "3c0dca6a6bf140fcd59900337130776f12de7fa2";

  src = fetchFromGitHub {
    owner = "sehqlr";
    repo = "grit";
    rev = "${version}";
    sha256 = "1jzm60pxnsk0nqss8livwcfbkhfhmxfcpw9jzza9zis98c04rwca";
  };

  vendorSha256 = null;
  
  meta = with lib; {
    description = ''
      Grit is an experimental personal task manager that represents tasks as nodes of a multitree, a class of directed acyclic graphs. The structure enables the subdivision of tasks, and supports short-term as well as long-term planning.
    '';
    homepage = "https://github.com/climech/grit";
    license = licenses.mit;
  };
}
