{
  stdenvNoCC,
  vscode-fhs,
  vscode,
  ...
}:
if stdenvNoCC.hostPlatform.isDarwin
then vscode
else vscode-fhs
