{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "htmlformat";
  version = "unstable-2023-11-08";

  src = fetchFromGitHub {
    owner = "a-h";
    repo = "htmlformat";
    rev = "5bd994fe268e4d505a9793143fa85414c7d50887";
    sha256 = "1i880gdl3vwcxwjajsxbdvjmxnjj4c62z6d1l3v44wz1qld7sab1";
    # date = "2023-11-08T12:46:58+00:00";
  };

  vendorHash = "sha256-uVfh1pPhfj6AyQDqFd1EDWshuyDRvbMDZj3SN5tCS2w=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Htmlformat";
    homepage = "https://github.com/a-h/htmlformat";
    license = licenses.mit;
    maintainers = with maintainers; [ alanpearce ];
    mainProgram = "htmlformat";
  };
}
