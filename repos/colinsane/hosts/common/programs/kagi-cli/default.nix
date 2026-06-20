# <https://github.com/Microck/kagi-cli>
{
  sane.programs.kagi-cli = {
    sandbox.net = "all";
    secrets.".config/kagi-cli/config.toml" = ../../../../secrets/common/kagi-cli-config.toml.bin;
  };
}
