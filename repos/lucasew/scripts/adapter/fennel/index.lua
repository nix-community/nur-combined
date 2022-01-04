local fennel = require 'fennel'

table.insert(_G.package.loaders or _G.package.searchers, fennel.searcher)

fennel.path = package.path:gsub(".lua", ".fnl")

error("not today")
return require 'adapter'

