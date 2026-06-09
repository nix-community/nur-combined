{
  haskell,
  haskellPackages,
  installShellFiles,
  lib,
  perl,
  stdenv,
}:
let
  inherit (haskell.lib.compose) justStaticExecutables overrideCabal;

  overrides = {
    passthru.updateScript = ./update.sh;

    # nom has unit-tests and golden-tests
    # golden-tests call nix and thus can’t be run in a nix build.
    testTargets = [ "unit-tests" ];

    buildTools = [
      installShellFiles
      perl
    ];

    postPatch = ''
            # Add CPP extension
            for f in lib/NOM/IO.hs lib/NOM/Update/Monad.hs; do
              perl -i -pe 'print "{-# LANGUAGE CPP #-}\n" if $. == 1' "$f"
            done

            # Update/Monad.hs: Precise replacements
            perl -i -pe 's/^import NOM.Update.Monad.CacheBuildReports/import Control.Concurrent (threadDelay)\nimport NOM.Update.Monad.CacheBuildReports/' lib/NOM/Update/Monad.hs

            # Make System.INotify import conditional (multi-line match)
            perl -i -0777 -pe 's/import System\.INotify \(.*?\n \)/#ifdef INOTIFY\nimport System.INotify (\n  Event (MovedIn, filePath),\n  EventVariety (MoveIn),\n  INotify,\n  addWatch,\n  removeWatch,\n )\n#endif/s' lib/NOM/Update/Monad.hs

            # Make CheckStorePathEnv conditional
            perl -i -0777 -pe 's/data CheckStorePathEnv = MkCheckStorePathEnv\n  \{ iNotifyManager :: INotify\n  , pathFoundChannel :: TChan \(Host WithContext, DerivationId\)\n  \}/#ifdef INOTIFY\ndata CheckStorePathEnv = MkCheckStorePathEnv\n  { iNotifyManager :: INotify\n  , pathFoundChannel :: TChan (Host WithContext, DerivationId)\n  }\n#else\ndata CheckStorePathEnv = MkCheckStorePathEnv\n  { iNotifyManager :: ()\n  , pathFoundChannel :: TChan (Host WithContext, DerivationId)\n  }\n#endif/s' lib/NOM/Update/Monad.hs

            # IO.hs: Make System.INotify import conditional
            perl -i -pe 's/import System.INotify/#ifdef INOTIFY\nimport System.INotify\n#endif/' lib/NOM/IO.hs
            perl -i -0777 -pe 's/  withINotify \\inotify -> do/#ifdef INOTIFY\n  withINotify \\inotify -> do\n#else\n  let inotify = ()\n  do\n#endif/sg' lib/NOM/IO.hs

            # Provide polling fallback for subscribeStorePath
            cat > subscribe_fallback.hs <<EOF
        subscribeStorePath path payload = do
          check_env <- ask
          found <- newTVarIO False
          void \$ liftIO \$ async \$ bracket
      #ifdef INOTIFY
            ( addWatch (check_env.iNotifyManager) [MoveIn] (encodeUtf8 . takeDirectory \$ toString path) (\\case
                MovedIn{filePath} | (encodeUtf8 . takeDirectory \$ toString path) <> "/" <> filePath == (encodeUtf8 (toString path)) ->
                      atomically \$ writeTVar found True
                _ -> pure ()))
            removeWatch
      #else
            (pure ())
            (\\_ -> pure ())
      #endif
            \\_ -> do
              fix \\k -> do
                there <- storePathExistsIO path
                if there
                  then atomically \$ writeTVar found True
                  else do
                    threadDelay 100000
                    k
              atomically do
                found1 <- readTVar found
                unless found1 retry
                writeTChan (check_env.pathFoundChannel) payload
      EOF
            perl -i -0777 -pe 's/  subscribeStorePath path payload = do.*?writeTChan \(check_env.pathFoundChannel\) payload/`cat subscribe_fallback.hs`/se' lib/NOM/Update/Monad.hs

            # Patch .cabal file
            perl -i -pe 's/hinotify,//' nix-output-monitor.cabal
            perl -i -0777 -pe 's/source-repository head/flag inotify\n  description: Use inotify\n  default: True\n  manual: True\n\nsource-repository head/sg' nix-output-monitor.cabal
            perl -i -0777 -pe 's/default-language: GHC2021/if flag(inotify)\n    build-depends: hinotify\n    cpp-options: -DINOTIFY\n  default-language: GHC2021/sg' nix-output-monitor.cabal
    '';

    configureFlags = [
      (if stdenv.isLinux then "-finotify" else "-f-inotify")
    ];

    libraryHaskellDepends = lib.optionals stdenv.isLinux [ haskellPackages.hinotify ];
    executableHaskellDepends = lib.optionals stdenv.isLinux [ haskellPackages.hinotify ];

    postInstall = ''
      ln -s nom "$out/bin/nom-build"
      ln -s nom "$out/bin/nom-shell"
      chmod a+x $out/bin/nom-build
      installShellCompletion completions/*
    '';
  };
  raw-pkg = haskellPackages.callPackage ./generated-package.nix { };
in
lib.pipe raw-pkg [
  (overrideCabal overrides)
  justStaticExecutables
]
