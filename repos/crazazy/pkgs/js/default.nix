{ pkgs }:
{
  CRA = (import ./create-react-app { inherit pkgs; }).package;
  eslint = (import ./eslint { inherit pkgs; }).package;
  jspm = (import ./jspm { inherit pkgs; }).package;
  npe = (import ./npe { inherit pkgs; }).package;
  parcel = (import ./parcel-bundler { inherit pkgs; }).package;
  pnpm = (import ./pnpm { inherit pkgs; }).package;
  preact-cli = (import ./preact-cli { inherit pkgs; }).package;
  rollup = (import ./rollup { inherit pkgs; }).package;
  tldr = (import ./tldr { inherit pkgs; }).package;
  typescript = (import ./typescript { inherit pkgs; }).package;
  webpack = (import ./webpack-cli { inherit pkgs; }).package;

  # expose this attribute set as a package set
  recurseForDerivations = true;
}
