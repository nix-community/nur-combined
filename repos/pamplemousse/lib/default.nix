{ pkgs }:

with pkgs.lib; {
  /*  Returns the list of public SSH keys for the given user.

      Example:
        fetchGitHubKeys { username = "Pamplemousse"; sha256 = "..." }
        => [ "ssh-ed25519 ..." "ssh-ed25519 ..." ]
  */
  fetchGitHubKeys = (import ./fetchGitHubKeys.nix) { lib = pkgs.lib; };
}
