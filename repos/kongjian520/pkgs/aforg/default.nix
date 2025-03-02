{
  lib,
  buildGoModule,
  fetchFromGitHub,

}:

buildGoModule rec {
  pname = "aforg";
  version = "3.1.5";

  src = fetchFromGitHub {
    "owner" = "zan8in";
    "repo" = "afrog";
    "rev" = "3b9a347f38b48c37b96082fa9de907005e636a1a";
    "hash" = "sha256-5Lpus2ERNOM+xQ8M8oz38Vj5r+o5o6Eg8nI1QgwtueQ=";
  };

  vendorHash = "sha256-oViWLisz4/b/x9USrF9KYT9ecI28AvyVZHhIWuzWtr0=";

  ldflags = [
    "-w"
    "-s"
  ];

  meta = with lib; {
    description = "aforg";
    mainProgram = "aforg";
    longDescription = ''

    '';
    homepage = "https://github.com/zan8in/afrog";
    # changelog = "https://github.com/ffuf/ffuf/releases/tag/v${version}";
    license = licenses.mit;
  };
}
