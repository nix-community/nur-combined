# Maintainers of the packages in this repository.
#
# The schema is the same as nixpkgs' `lib/maintainers.nix`, so entries can be
# copied verbatim into a nixpkgs pull request. `githubId` is the immutable
# numeric account id (not the login), fetchable with:
#
#     curl -s https://api.github.com/users/<handle> | jq .id
#
# It is exposed to every package as the `maintainers` argument, see
# ../default.nix. Usage in a package:
#
#     meta.maintainers = with maintainers; [ greep ];
{
  greep = {
    name = "Matthieu";
    email = "greep@greep.fr";
    github = "GreepTheSheep";
    githubId = 42576124;
  };
  bensuperpc = {
    name = "Bensuperpc";
    email = "bensuperpc@protonmail.com";
    github = "bensuperpc";
    githubId = 28039927;
  };
}
