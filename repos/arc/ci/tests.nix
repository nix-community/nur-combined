{ arc }:
let
  tests = {
    githubTest = arc.build.fetchGitHubApi {
      gitHubEndpoint = "users/octocat";
      jqFilter = "{ login, type }";
      sha256 = "1i5x5blswd3245zz1qkc1mhyk8dhmzyqbxvrk7nlxqdhh3a00743";
      env = {
        passthru.ci.eval = drv: drv.json == { login = "octocat"; type = "User"; };
      };
    };
  };
in
builtins.attrValues tests
