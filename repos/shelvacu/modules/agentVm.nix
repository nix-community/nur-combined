{
  lib,
  pkgs,
  config,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.vacuvmGuest ];

  vacu.systemKind = "server";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
  };

  vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

  vacu.packages = {
    # upstream wrapper exports alsa-lib in LD_LIBRARY_PATH (for voice mode), which leaks into every tool shell
    claude-code.enable = true;
    claude-code.package = pkgs.claude-code.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        sed -i '/LD_LIBRARY_PATH/d' $out/bin/claude
      '';
    });
    codex.enable = true;
  };

  vacu.git.enable = true;

  vacu.agentsMd = {
    enable = true;
    contents = ''
      ## this file

      this file is generated from the nixos config for this machine. you are not allowed to edit it, but making PRs against nix-stuff that will change it is fine

      ## general info

      ${{
        vacu-agent-vm = ''me/us = shelvacu, I'm your operator. Sometimes things say "us" because they were written to be used in multiple places'';
        savm = "your operators are shelvacu (aka shelly, @s:sv.mt) and javi (aka java, java-coffee, @javacoffee:matrix.org)";
      }.${config.vacu.hostName}}

      you're on nixos, you have sudo, this VM is just for you

      the config for this machine is in `git+https://git.uninsane.org/shelvacu/nix-stuff#${config.vacu.hostName}`

      api keys and other auth data available in ~/auth-data.toml

      when asking you to debug something, you usually don't have access to the machine in question

      ## prose style

      please keep your commit messages, code comments, and PR descriptions/comments short and to the point.

      comments should not be used as notes, use `agent-doc` or memories instead.

      comments are not for convincing the reviewer the code is good, use the PR description instead

      comments should be written (or not written) assuming the reader is generally familiar with the code, environment, and goals of the project.

      a comment is a good idea when the "obvious" solution is actually a bad idea

      ## worktrees

      when a change is requested, please use a worktree by default.

      put it inside the repo, or in a temp dir, not next to the repo. Ex: repo is cloned at `~/dev/fooproject`, and the branch is called `bar`. The worktree path should be `~/dev/fooproject/wt/bar` (or `~/dev/fooproject/.claude/worktrees/bar` or similar) or in `/tmp`. The path should not be `~/dev/fooproject-bar`.
    '';
  };
}
