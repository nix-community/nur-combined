{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.eownerdead.agents;

  # https://github.com/semi710/ndots/blob/672c8f0e4f353c3b42fc22755d3ef810b9de4a47/modules/home/ai/opencode.nix
  # Fetch the OpenAgentsControl repository
  openagents-control = pkgs.fetchFromGitHub {
    owner = "darrenhinde";
    repo = "OpenAgentsControl";
    rev = "ef3836efd659e451b6dbb8eee7d3213ba39f5aec";
    sha256 = "sha256-H5O08YjxzJMYva1sjMgCl5GTDrx9pR1ELBtO5bqGV/Y=";
  };

  # Read registry
  registry = builtins.fromJSON (
    builtins.readFile "${openagents-control}/registry.json"
  );

  # Profile to install
  profile = "developer";

  # Get components for the profile
  allComponents = registry.profiles.${profile}.components or [ ];

  # Convert component spec to file mapping
  componentToFile =
    spec:
    let
      parts = lib.splitString ":" spec;
      compType = lib.elemAt parts 0;
      compId = lib.elemAt parts 1;
      # Registry uses plural keys
      registryKey = if lib.hasSuffix "s" compType then compType else compType + "s";
      components = registry.components.${registryKey} or [ ];
      matches = c: c.id == compId || lib.elem compId (c.aliases or [ ]);
      component = lib.findFirst matches null components;
    in
    if component == null then
      null
    else
      {
        name = ".config/opencode/${lib.removePrefix ".opencode/" component.path}";
        value.source = "${openagents-control}/${component.path}";
      };
in
{
  options.eownerdead.agents = {
    mcp.enable = lib.mkEnableOption "Enable some mcp servers for coding agents";
    opencode.enable = lib.mkEnableOption "Enable opencode";
  };

  config = {
    home.packages = lib.mkIf cfg.mcp.enable [ pkgs.mcp-nixos ];

    programs.mcp = lib.mkIf cfg.mcp.enable {
      enable = true;
      servers = {
        context7.url = "https://mcp.context7.com/mcp";
        grep-app.url = "https://mcp.grep.app";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
        exa.url = "https://mcp.exa.ai/mcp?tools=web_search_exa,web_search_advanced_exa,get_code_context_exa,crawling_exa,company_research_exa,people_search_exa,deep_researcher_start,deep_researcher_check";
        nixos.command = "mcp-nixos";
      };
    };

    programs.opencode = lib.mkIf cfg.opencode.enable {
      enable = true;
      enableMcpIntegration = true;
      package = pkgs.unstable.opencode;
    };

    home = {
      sessionVariables = {
        OPENCODE_EXPERIMENTAL = "true";
        OPENCODE_ENABLE_EXA = 1;
      };
      file = lib.listToAttrs (
        lib.filter (x: x != null) (map componentToFile allComponents)
      );
    };
  };
}
