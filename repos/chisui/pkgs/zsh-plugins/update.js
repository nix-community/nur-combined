const { readFileSync, writeFileSync } = require('fs')
const { request } = require('https')
const { exec } = require("child_process")

const pluginsOld = JSON.parse(readFileSync("./plugins.json", "utf-8"))

const githubOpts = {
  headers: {
    "user-agent": "node.js",
    "accept": "*/*",
  }
}
const get = (url) => new Promise((res, rej) => {
  const req = request(url, githubOpts, req => {
    let data = ""
    req.on("data", chunk => { data += chunk })
    req.on("end", () => {
      try {
        res(JSON.parse(data))
      } catch (e) {
        rej(e)
      }
    })
    req.on("error", err => rej(err))
  })
  req.end()
})

const nixPrefetchUrl = url => new Promise((res, rej) => 
  exec(`nix-prefetch-url --unpack ${url}`, (err, stdout) => {
    if (err) {
      rej(err)
    } else {
      res(stdout)
    }
  }))
  .then(str => str.trim())

const updateSrcGithub = async src => {
  const { owner, repo, rev } = src
  const { tag_name } = await get(`https://api.github.com/repos/${owner}/${repo}/releases/latest`)
  if (tag_name === rev) {
    return src
  } else {
    const sha256 = await nixPrefetchUrl(`https://github.com/${owner}/${repo}/archive/refs/tags/${tag_name}.tar.gz`)
    return {
      ...src,
      sha256,
      rev: tag_name,
    }
  }
}

const updateSrc = src => {
  switch (src.type) {
    case "github":
      return updateSrcGithub(src)
    default:
      return Promise.reject(`unknown plugin type ${src.type}`)
  }
}

Promise.all(Object.keys(pluginsOld)
  .map(async key => {
    const pluginOld = pluginsOld[key]
    const src = await updateSrc(pluginOld.src)
    console.log(key, src)
    return { 
      [key]: { ...pluginOld, src }
    }
  }))
  .then(ps => Object.assign.apply(null, ps))
  .then(pluginsNew => writeFileSync("./plugins.json", JSON.stringify(pluginsNew, null, 2)))
