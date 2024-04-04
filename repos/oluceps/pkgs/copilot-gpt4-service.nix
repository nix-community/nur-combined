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
    owner = "aaamoon";
    repo = "copilot-gpt4-service";
    rev = "b6b23a1c13d39d9f7082e318c00c16412034c593";
    hash = "sha256-ulaLQXSUV5Rr715B9Vvle6RhE6NvItcuzt3PRIuWBT8=";
  };

  vendorHash = "sha256-oy/LjwAcMiPHpowxwFo8HRspAYMeTID4pa5u+uRyeWM=";

  doCheck = false;

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ oluceps ];
  };
}
