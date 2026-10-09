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
    };

    profiles.web.plugins = [
      "npm:@deepseek-ai/dsh-base"
      "npm:@deepseek-ai/dsh-web-app"
      "npm:dsh-context"
    ];
  };
}
```

Set `DEEPSEEK_API_KEY`, then start dsh:

```sh
dsh --profile web
```

## Plugins

Choose from the [plugin list](../dsh-plugins/README.md) and add their `npm:` or
`github:` names to `profiles.<name>.plugins`. They apply in the listed order.

Manage declared profiles in Nix. For manual plugin installation, use a profile
not declared here; pnpm, Git and Node.js are included.
