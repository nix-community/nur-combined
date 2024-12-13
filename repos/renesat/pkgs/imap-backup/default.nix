{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:
bundlerApp {
  pname = "imap-backup";
  gemdir = ./.;

  exes = ["imap-backup"];

  passthru.updateScript = bundlerUpdateScript "imap-backup";

  meta = with lib; {
    description = "Backup and Migrate IMAP Email Accounts";
    homepage = "https://github.com/joeyates/imap-backup";
    mainProgram = "imap-backup";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
  };
}
