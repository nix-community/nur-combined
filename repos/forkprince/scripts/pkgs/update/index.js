module.exports = {
  github: {
    repo: require("./pkgs/github/repo"),
    release: require("./pkgs/github/release")
  },
  forgejo: require("./pkgs/forgejo"),
  api: require("./pkgs/api")
}
