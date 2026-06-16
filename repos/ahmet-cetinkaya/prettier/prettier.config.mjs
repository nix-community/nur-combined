import astroConfig from './astro.config';
import jsxConfig from './prettier.jsx.config';

export default {
  semi: true,
  singleQuote: true,
  trailingComma: 'all',
  arrowParens: 'always',
  printWidth: 130,
  tabWidth: 2,
  overrides: {...astroConfig.overrides},
  plugins: [...astroConfig.plugins, 'prettier-plugin-organize-imports', 'prettier-plugin-organize-attributes', 'prettier-plugin-tailwindcss'],

  //#region prettier-plugin-organize-attributes
  attributeGroups: [ ...astroConfig.attributeGroups, ...jsxConfig.attributeGroups],
  //#endregion
};
