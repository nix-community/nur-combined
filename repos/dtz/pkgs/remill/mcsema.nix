{ fetchFromGitHub }:

{
  version = "2018-09-23";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "16cdff4f3bb5b7bef23bdb6ec3d335e90de27067";
    sha256 = "12x9a733662lsikgaia4qjyxbrjzc25ccc1z06lxlgs9m7sl24nw";
    name = "mcsema-source";
  };
}
