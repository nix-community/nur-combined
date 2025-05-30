{ pkgs, nodejs }:
{
  CRA = (import ./create-react-app { inherit pkgs nodejs; }).package;
  eslint = (import ./eslint { inherit pkgs nodejs; }).package;
  jspm = (import ./jspm { inherit pkgs nodejs; }).package;
  npe = (import ./npe { inherit pkgs nodejs; }).package;
  parcel = (import ./parcel-bundler { inherit pkgs nodejs; }).package;
  pnpm = (import ./pnpm { inherit pkgs nodejs; }).package;
  preact-cli = (import ./preact-cli { inherit pkgs nodejs; }).package;
  rollup = (import ./rollup { inherit pkgs nodejs; }).package;
  tern = (import ./tern { inherit pkgs nodejs; }).package;
  tldr = (import ./tldr { inherit pkgs nodejs; }).package;
  typescript = (import ./typescript { inherit pkgs nodejs; }).package;
  webpack = (import ./webpack-cli { inherit pkgs nodejs; }).package;

  # expose this attribute set as a package set
  # recurseForDerivations = true;
}
