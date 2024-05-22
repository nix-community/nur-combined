// @ts-check

const { Package, Key, Id } = require('../../lib/print');

/**
 * @typedef {({
 *   name: string,
 *   modules: string[]
 * })[]} TestTree
 */

/**
 * @param {TestTree} testTree
 * @returns {import('../../lib/print').DepTree<Package>}
 */
function createTree(testTree) {
  const nameToKey = {};
  const tree = testTree
    .map(({ name, modules }, i) => {
      i++;
      const pkg = new Package({
        key: new Key({
          id: new Id({ name }),
          version: [i, i, i].join('.'),
        }),
        src: {
          type: 'url',
          url: `https://registry.yarnpkg.com/${name}/${name}.tgz`,
          sha1: 'sha1',
        },
        modules,
      });
      nameToKey[name] = pkg.renderKey();
      return pkg;
    })
    .reduce((acc, curr) => {
      acc[curr.renderKey()] = curr;
      return acc;
    }, {});

  Object.entries(tree).forEach(
    /** @param {[string, Package]} param0 */
    ([, v]) => {
      v.modules = v.modules.map(name => {
        return nameToKey[name];
      });
    }
  );

  return tree;
}

/**
 * @param {import('../../lib/print').DepTree<Package>} tree
 * @returns {string}
 */
function renderSnapshot(tree) {
  const trimVersion = m =>
    m
      .split('+')
      .map(key => key.split('@').shift())
      .join('+');
  return Object.entries(tree)
    .map(([k, v]) => {
      return `${trimVersion(k)}:${
        v.modules.length
          ? ` 
${v.modules.map(m => '- ' + trimVersion(m)).join('\n')}`
          : ''
      }
`;
    })
    .join('\n');
}

exports.createTree = createTree;
exports.renderSnapshot = renderSnapshot;
