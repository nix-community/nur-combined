{ python3Packages }:

python3Packages.toPythonApplication (
  python3Packages.busylight-for-humans.overridePythonAttrs (busylight-for-humans: {
    pname = "busyserve";
    meta = busylight-for-humans.meta // {
      mainProgram = "busyserve";
    };

    dependencies = busylight-for-humans.dependencies ++ busylight-for-humans.optional-dependencies.webapi;
  })
)
