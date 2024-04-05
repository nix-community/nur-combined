{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ...
}:
buildGoModule {
  pname = "copilot-gpt4-service";
  version = "rolling";

  src = fetchFromGitHub {
    owner = "newskyforest";
    repo = "copilot-gpt4-service";
    rev = "f86509850e23265fa16588a6f7098d2a51e448a3";
    hash = "sha256-LfUnJMWviSh7+socVZRBNiirsCJXPOR0XhohPTEZOGc=";
  };

  vendorHash = "sha256-oy/LjwAcMiPHpowxwFo8HRspAYMeTID4pa5u+uRyeWM=";

  doCheck = false;

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ oluceps ];
  };
}
