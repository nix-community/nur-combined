{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.shells;
in
{
  options.nixcfg.shells.enable = lib.mkEnableOption "shell tools";

  config = lib.mkIf cfg.enable {
    home.sessionVariables._ZO_ECHO = 1;
    programs = {
      starship = {
        enable = true;
        extraPackages = [ pkgs.jj-starship ];
        settings = {
          time.disabled = false;
          os.disabled = false;
          shell.disabled = false;
          git_status = {
            ahead = "⇡$count";
            behind = "⇣$count";
            diverged = "⇡$ahead_count⇣$behind_count";
            stashed = "📦$count";
          };
          custom.jj = {
            when = "jj-starship detect";
            shell = [ "jj-starship" ];
            format = "$output ";
          };
          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$localip"
            "$shlvl"
            "$singularity"
            "$kubernetes"
            "$nats"
            "$directory"
            "$vcsh"
            "$fossil_branch"
            "$fossil_metrics"
            "\${custom.jj}"
            "$git_branch"
            "$git_commit"
            "$git_state"
            "$git_metrics"
            "$git_status"
            "$hg_branch"
            "$hg_state"
            "$pijul_channel"
            "$docker_context"
            "$package"
            "$bun"
            "$c"
            "$cmake"
            "$cobol"
            "$cpp"
            "$daml"
            "$dart"
            "$deno"
            "$dotnet"
            "$elixir"
            "$elm"
            "$erlang"
            "$fennel"
            "$fortran"
            "$gleam"
            "$golang"
            "$gradle"
            "$haskell"
            "$haxe"
            "$helm"
            "$java"
            "$julia"
            "$kotlin"
            "$lua"
            "$maven"
            "$mojo"
            "$nim"
            "$nodejs"
            "$ocaml"
            "$odin"
            "$opa"
            "$perl"
            "$php"
            "$pulumi"
            "$purescript"
            "$python"
            "$quarto"
            "$raku"
            "$rlang"
            "$red"
            "$ruby"
            "$rust"
            "$scala"
            "$solidity"
            "$swift"
            "$terraform"
            "$typst"
            "$vlang"
            "$vagrant"
            "$xmake"
            "$zig"
            "$buf"
            "$guix_shell"
            "$nix_shell"
            "$conda"
            "$pixi"
            "$meson"
            "$spack"
            "$memory_usage"
            "$aws"
            "$gcloud"
            "$openstack"
            "$azure"
            "$direnv"
            "$env_var"
            "$mise"
            "$crystal"
            "$custom"
            "$sudo"
            "$cmd_duration"
            "$jobs"
            "$battery"
            "$time"
            "$status"
            "$container"
            "$netns"
            "$os"
            "$shell"
            "$line_break"
            "$character"
          ];
        };
      };
      zoxide.enable = true;
      bat.enable = true;
      eza.enable = true;
      zsh.enable = true;
      bash.enable = true;
      fish.enable = true;
      ion.enable = true;
      nushell.enable = true;
      powershell.enable = true;
    };
  };
}
