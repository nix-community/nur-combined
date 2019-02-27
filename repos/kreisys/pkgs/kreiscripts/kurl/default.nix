{ mkBashCli, jq }:

mkBashCli "kurl" "a can of curls... just some interactions with REST APIs and such that I might need again in the future." {} (mkCmd: [
  (mkCmd "godaddy" "Useful interactions with the GoDaddy API" { aliases = [ "gd" ]; } [
    (mkCmd "addmx" "Add MX records to multiple domains. This is tedious to do manually." {
      aliases   = [ "amx" ];
      options   = o: [ (o "p" "provider" "google" "the provider whose mx records we are going to add") ];
      arguments = a: [ (a     "domains"           "one or more domains to add mx records to") ];
    } ''
      if ! [[ -f ${./.}/$PROVIDER.json ]]; then
        err "provider '$PROVIDER' is not supported"
        exit 1
      fi

      for domain in $DOMAINS "$@"; do
        cat ${./.}/$PROVIDER.json | curl -X PUT --data @- -H "Content-Type: application/json" -H "Authorization: sso-key $(security find-generic-password -a default -s godaddy-api -w)" "https://api.godaddy.com/v1/domains/''${domain}/records/MX/@"
      done
    '')

    (mkCmd "domains" "list domains" {
      aliases = [ "lsd" ];
      flags   = f: [ (f "t" "test" "print canned sample data instead of actually contacting the api") ];
    } ''
      if $TEST; then
        cat ${./sample.json}
      else
        curl -X GET -H "Content-Type: application/json" -H "Authorization: sso-key $(security find-generic-password -a default -s godaddy-api -w)" "https://api.godaddy.com/v1/domains"
      fi
    '')
  ])

  (mkCmd "github" "Useful interactions with the GoDaddy API" { aliases = [ "gh" ]; } [
    (mkCmd "commits" "list latest commit hashes" {
      arguments = a: [ (a "repo" "the repository whose commits we want to list") ];
      options   = o: [
        (o "b" "branch" "master" "the branch whose commits we want to list")
        (o "p" "page"   "1"      "github's API is paginated; we only get one page at a time")
      ];
    } ''
      curl --silent "https://api.github.com/repos/$REPO/commits?sha=$BRANCH&page=$PAGE" | ${jq}/bin/jq -r .[].sha
    '')
  ])
])

