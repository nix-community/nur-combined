package = "seowebchecker"
version = "1.0.0-1"
source = {
   url = "git+https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk.git",
   tag = "v1.0.2"
}
description = {
   summary = "Lightweight on-page technical SEO audit client SDK for Lua.",
   detailed = [[
      Automated on-page technical SEO diagnostic engine and client SDK for meta tag validations,
      heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics.
      Powered by SEOWebChecker (https://seowebchecker.com/).
   ]],
   homepage = "https://seowebchecker.com/",
   license = "MIT",
   maintainer = "Rahul Gupta <jaiganesh6999@gmail.com>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      seowebchecker = "lua/seowebchecker.lua"
   }
}
