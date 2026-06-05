{ ... }:
{
  sane.programs.nanogpt-api = {
    sandbox.net = "clearnet";
    secrets.".config/nanogpt/nanogpt_api_key" = ../../../../secrets/common/nanogpt_api_key.bin;
  };
}
