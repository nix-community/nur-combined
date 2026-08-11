{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nodejs # Runtimes are system-managed; project dependencies stay in package manifests.
    bun
    prettier
  ];
}
