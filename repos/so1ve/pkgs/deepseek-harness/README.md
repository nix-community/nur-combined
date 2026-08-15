# DeepSeek Harness

This package installs the official DeepSeek Harness as `dsh`.

## Home Manager

```nix
{
  imports = [ inputs.so1ve.homeModules.deepseek-harness ];

  programs.deepseek-harness = {
    enable = true;

    settings."llm-deepseek" = {
      apiKeyEnv = "DEEPSEEK_API_KEY";
      thinking = "enabled";
      reasoningEffort = "high";
    };

    agentsFile = ''
      Follow the instructions in the repository's AGENTS.md.
    '';

    profiles.automation = {
      bundles = [
        "@deepseek-ai/dsh-base"
        "@deepseek-ai/dsh-headless"
      ];
      patch = { };
    };
  };
}
```

The upstream `web` and `headless` profiles are initialized automatically when
they are not declared here. Declarative third-party profile bundles require a
custom `package` which already contains those npm dependencies.
