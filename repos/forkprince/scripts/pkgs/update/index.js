module.exports = {
  github: {
    repo: require("./pkgs/github/repo"),
    release: require("./pkgs/github/release")
  },
  forgejo: require("./pkgs/forgejo"),
  gitlab: require("./pkgs/gitlab"),
  api: require("./pkgs/api"),
  redirect: require("./pkgs/redirect")
}
