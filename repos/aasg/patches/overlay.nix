self: super:

{

  haunt = import ./haunt { inherit (super) haunt; };

  zoxide = import ./zoxide { inherit (super) fetchFromGitHub zoxide; };

}
