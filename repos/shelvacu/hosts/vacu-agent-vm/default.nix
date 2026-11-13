{ vaculib, vacuModules, ... }: {
  imports = [ vacuModules.agentVm ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "vacu-agent-vm";
  system.stateVersion = "25.11";

  fileSystems."/bigdata" = {
    device = "bigdata";
    fsType = "virtiofs";
    options = [
      "nofail"
      "X-mount.mkdir"
    ];
  };

  fileSystems."/t-pictures" = {
    device = "t-pictures";
    fsType = "virtiofs";
    options = [
      "nofail"
      "X-mount.mkdir"
    ];
  };

  vacuvmGuest.ip = "10.78.77.2";
  vacuvmGuest.publicIp = "205.201.63.130";
  vacuvmGuest.ipv6 = "2602:fce8:106:10::2";

  vacu.agentsMd.contents = ''
    ## nixos config

    this machine's config is in the repo @ https://git.uninsane.org/shelvacu/nix-stuff

    you don't have push access to nix-stuff. Prefer temporary/isolated methods (ie using `nix shell`, `nix develop`).

    Please do not deploy (`nixos-rebuild`) changes to this machine unless they are committed and pushed somewhere; can be to your fork. Any changes to nix-stuff should become a PR, but it doesn't need to be immediately, so if for example it makes more sense to group multiple changes into one PR you can wait to make the PR.

    ## per-repo instructions

    In general, you should commit&push as you go.

    When I talk about 'your fork', if you haven't already created a fork, I probably want you to create one, but ask.

    all in `~/dev`

    ### others' repos

    For repos not owned by me (shelvacu), push to your fork, don't PR by default. I'll usually want to do the PR myself:

    - `bambanah-deemix`
    - `nixpkgs`
    - `colin-nix-files` (`colin/nix-files`)

    ### our repos

    There should be a `agent-doc` folder: this is general, open-ended docs/notes, primarily for you and other agents, and secondarily for me. The idea is that "memories" commited to the repo make the repo a much better autoritative source of information. If the folder isn't there it probably needs to be renamed, look for a folder with a bunch of markdown files and then ask me.

    push straight to master; commits can always be reverted, don't worry too much:
    - `beatblock-dissection` aka `game-dissection`
    - `beatblock-mods`
    - `cs101`
    - `goodtop-firmware`
    - `inv6`
    - `labelwriter-re`
    - `scanitall`
    - `toyota-navdisc`

    push to your fork and PR (that is, assume asking for a change is also asking for a PR), I can always just close it if that's not what I wanted:
    - `gallery-dl`
    - `nix-stuff`
    - `padtype`
  '';
}
