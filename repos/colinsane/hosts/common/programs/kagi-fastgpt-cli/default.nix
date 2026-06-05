{
  sane.programs.kagi-fastgpt-cli = {
    sandbox.net = "all";
    secrets.".config/fastgpt/config.toml" = ../../../../secrets/common/kagi-fastgpt-cli-config.toml.bin;
  };
}

