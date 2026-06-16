export default {
  overrides: [
    {
      "files": "*.astro",
      "options": {
        "parser": "astro"
      }
    }
  ],

  plugins: ['prettier-plugin-astro'],

  //#region prettier-plugin-organize-attributes
   attributeGroups: [
    "^(id|key|ref)$",
    "^class$",
    "^data-",
    "^aria-",
    "^role$",
    "^type$",
    "^tabIndex$",
    "^style$",
    "^on[A-Z]",
    "^children$"
  ]
  //#endregion
};
