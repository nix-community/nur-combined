{ vimUtils
, fetchFromGitHub
, lib
,
}:
vimUtils.buildVimPlugin {
  name = "vim-ctrlspace";
  src = fetchFromGitHub {
    owner = "vim-ctrlspace";
    repo = "vim-ctrlspace";
    rev = "5e444c6af06de58d5ed7d7bd0dcbb958f292cd2e";
    sha256 = "sha256-EJFaWTVPqQpAewPq7VT0EOgMnL3+6Hl9u5oQZJqItUM=";
  };

  meta = with lib; {
    description = "Vim Space Controller";
    homepage = "https://github.com/vim-ctrlspace/vim-ctrlspace";
    license = licenses.mit; # License is only at bottom of upstream README rather than in a file
    maintainers = with maintainers; [ minion3665 ];
  };
}
