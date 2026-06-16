export default {
  overrides: [
    {
      files: "*.html",
      options: {
        parser: "angular",
      },
    },
  ],

  //#region prettier-plugin-organize-attributes
  attributeGroups: [
    "^(id|name)$",
    "$ANGULAR_STRUCTURAL_DIRECTIVE",
    "^app",
    "$ANGULAR_ELEMENT_REF",
    "data-testid",
    "tabindex",
    "$ALT",
    "$ARIA",
    "$ROLE",
    "$TYPE",
    "$CLASS",
    "ngClass",
    "Class$",
    "^\\[style",
    "$ANGULAR_ANIMATION",
    "$ANGULAR_ANIMATION_INPUT",
    "^\\[attr",
    "$ANGULAR_TWO_WAY_BINDING",
    "$ANGULAR_INPUT",
    "^(\\(blur\\)|\\(focus\\)|)$",
    "^(\\(click\\)|\\(dbclick\\)|\\(submit\\))$",
    "^(\\(cut\\)|\\(copy\\)|\\(paste\\))$",
    "^(\\(keyup\\)|\\(keypress\\)|\\(keydown\\))$",
    "^(\\(mouseup\\)|\\(mousedown\\)|\\(mouseenter\\)|\\(scroll\\))$",
    "^(\\(drag\\)|\\(drop\\)|\\(dragover\\))$",
    "$ANGULAR_OUTPUT",
  ],
  //#endregion
};
