let
  version = "0.6.0";
in
{
  emmylua_ls = import ./crates/emmylua_ls.nix version;
  emmylua_doc_cli = import ./crates/emmylua_doc_cli.nix version;
  emmylua_check = import ./crates/emmylua_check.nix version;
}
