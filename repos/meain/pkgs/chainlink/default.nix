{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "chainlink";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "chainlink";
    rev = "v${version}";
    hash = "sha256-sI7958Y14nlZvuv5SU9S/753GuNfajrxLDJEoKRQVMI=";
  };

  vendorHash = "sha256-w5kWxb0nzDzpM//eSiCozyWHgB9epYVxwmid4ZV6tSc=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Get a handle on PR chains on GitHub";
    homepage = "https://github.com/meain/chainlink";
    license = licenses.asl20;
    maintainers = with maintainers; [ meain ];
    mainProgram = "chainlink";
  };
}
