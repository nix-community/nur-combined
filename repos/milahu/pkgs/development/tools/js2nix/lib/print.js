// @ts-check

const lockfile = require('@yarnpkg/lockfile');
const { promises: fs } = require('fs');
const { strict: assert } = require('assert');
const parse = require('parse-package-name');
const { URL } = require('url');
const path = require('path');
const semver = require('semver');

/**
 * @typedef {{
 *  type: 'success' | 'merge' | 'conflict',
 *  object: import('@yarnpkg/lockfile').LockFileObject,
 * }} YarnLockJSON
 */

/**
 * @typedef {{
 *   lock: string,
 *   out: string,
 * }} PrintArgs
 */

/**
 * @typedef {{ render(): string }} Renderable
 */

/**
 * @template {Renderable} T
 * @typedef {Record<string, T>} DepTree
 */

const hostDelimiter = '+';

class Id {
  /**
   * @param {{
   *   scope?: string,
   *   name: string,
   * }} data - input data
   */
  constructor({ scope, name }) {
    /** @type { typeof scope } */
    this.scope = scope;
    /** @type { typeof name } */
    this.name = name;
  }

  /**
   * @returns {string}
   */
  toString() {
    return this.scope ? `@${this.scope}/${this.name}` : `${this.name}`;
  }

  /**
   * @returns {Id}
   */
  clone() {
    return new Id(this);
  }

  /**
   * @param {string} n - input data
   */
  static parse(n) {
    const reName = /(?:^@(.+)\/)?([^\/]+)$/;
    const [_, scope, name] = reName.exec(n);
    return new Id({ scope, name });
  }
}

class Key {
  /**
   * @param {{
   *   id: Id,
   *   version: string,
   * }} data - input data
   */
  constructor({ version, id }) {
    /** @type Id */
    this.id = id;
    /** @type { typeof version } */
    this.version = version;
  }

  /**
   * @returns {string}
   */
  toString() {
    return Key.key(this.id.toString(), this.version);
  }

  /**
   * @returns {Key}
   */
  clone() {
    return new Key({
      id: this.id.clone(),
      version: this.version,
    });
  }

  /**
   * @param {string} name
   * @param {string} version
   * @returns {string}
   */
  static key(name, version) {
    return `${name}@${version}`;
  }
}

/**
 * An alias that can be used to refer to a package. For example, the 'toposort@2.0.3' can
 * be refered from a package.json file as 'toposort@^2.0.2' so the Reference class make
 * such type of data a first-class citizen in the resulting Nix expression.
 */
class Reference {
  /**
   * @param {{
   *   key: Key,
   *   ref: string,
   * }} data - input data
   */
  constructor({ key, ref }) {
    /** @type Key */
    this.key = key;
    /** @type { typeof ref } */
    this.ref = ref;
  }

  /**
   * @returns {string}
   */
  render() {
    return `  "${this.ref}" = self."${this.key.toString()}";`;
  }

  /**
   * A type guard for the Reference
   *
   * @param {any} obj
   * @returns {obj is Reference}
   */
  static is(obj) {
    return obj && typeof obj === 'object' && !!obj.ref;
  }
}

/**
 * An alias that cannot be used to refer to a package because of name is too generic
 * so it matches with more that on package  from the tree with different versions.
 *
 * Like:
 * - toposort@2.0.2
 * - toposort@1.5.0
 *
 * So, the short reference 'toposort' cannot be used within this tree.
 */
class BrokenReference {
  /**
   * @param {{
   *   keys: Set<Key>,
   *   ref: string,
   * }} data - input data
   */
  constructor({ keys, ref }) {
    /** @type Set<Key> */
    this.keys = keys;
    /** @type { typeof ref } */
    this.ref = ref;
  }

  /**
   * @returns {string}
   */
  render() {
    return `  "${this.ref}" = abort ''


    Unable to refer to the package via the \`${this.ref}\` name due to versions' clash.
    Consider referring the package directly via one of these names:

      - \`${Array.from(this.keys).join('`\n      - `')}\`


  '';`;
  }

  /**
   * A type guard for the Reference
   *
   * @param {any} obj
   * @returns {obj is BrokenReference}
   */
  static is(obj) {
    return obj && typeof obj === 'object' && !!obj.keys;
  }
}

class Package {
  /**
   * @param {{
   *   host?: Key,
   *   key: Key,
   *   src: {
   *    type: 'url',
   *    url: string,
   *    sha1?: string
   *   } | {
   *    type: 'local',
   *   },
   *   modules: string[],
   * }} data - input data
   */
  constructor({ src, modules, key, host }) {
    /** @type {Key} */
    this.key = key;
    if (host) {
      /** @type { typeof host } */
      this.host = host;
    }
    /** @type { typeof src } */
    this.src = { ...src };
    /** @type { typeof modules } */
    this.modules = modules.slice();
  }

  /**
   * @param {?Partial<Package>} overrides
   * @returns {Package}
   */
  clone(overrides = {}) {
    return new Package({
      key: this.key.clone(),
      host: this.host ? this.host.clone() : undefined,
      src: { ...this.src },
      modules: this.modules.slice(),
      ...overrides,
    });
  }

  /**
   * Produces a package object that can be used to generate nix expression.
   *
   * @param {ReturnType< typeof import('parse-package-name')>} pkgInfo
   * @param {YarnLockJSON['object'][string]} yarnLockPackage
   * @returns {Package}
   */
  static create(
    pkgInfo,
    // @ts-ignore because there is no optionalDependencies in the type
    { version, resolved, dependencies = {}, optionalDependencies = {} }
  ) {
    const { scope = '', name } = Id.parse(pkgInfo.name);

    /** @type {Package['src']} */
    let src;
    if (resolved && resolved.startsWith('https')) {
      const parsedUrl = new URL(resolved);
      // prettier-ignore
      if (['registry.yarnpkg.com', 'registry.npmjs.org'].includes(parsedUrl.host)) {
        src = { 
          sha1: parsedUrl.hash.slice(1), // cut off the first ('#') character
          url: parsedUrl.origin + parsedUrl.pathname, 
          type: 'url',
        };
      } else {
        src = { 
          sha1: undefined, // We don't provide sha in order to force to override it manually
          url: parsedUrl.origin + parsedUrl.pathname, 
          type: 'url',
        }; 
      }
    } else if (isPath(pkgInfo.version)) {
      src = { type: 'local' };
    } else {
      throw new Error('Failed to parse resolved source: ' + resolved);
    }

    return new Package({
      key: new Key({
        id: new Id({ scope, name }),
        version,
      }),
      src,
      modules: [
        ...Object.keys(dependencies).map((key) => Key.key(key, dependencies[key])),
        ...Object.keys(optionalDependencies).map((key) => Key.key(key, optionalDependencies[key])),
      ].sort(),
    });
  }

  /**
   * A type guard for the Reference
   *
   * @param {any} obj
   * @returns {obj is Package}
   */
  static is(obj) {
    return obj && typeof obj === 'object' && !!obj.src;
  }

  /**
   * @returns {string}
   */
  render() {
    // A stub case
    if (this.host && this.host.toString() === this.key.toString()) {
      return `  "${this.renderKey()}" =
    let id = { scope = "${this.key.id.scope || ''}"; name = "${this.key.id.name}"; };
    in { inherit id; host = id; };`;
    }

    // Override case, for hosted modules
    if (this.host) {
      return `  "${this.renderKey()}" = 
    self."${this.key.toString()}".override {
      host = { scope = "${this.host.id.scope || ''}"; name = "${this.host.id.name}"; };
      modules = [
        ${this.modules.map((dep) => `self."${dep}"`).join('\n        ')}
      ];
    };`;
    }

    return `  "${this.renderKey()}" = self.buildNodeModule {${
      this.host
        ? `
    host = { scope = "${this.host.id.scope || ''}"; name = "${this.host.id.name}"; };`
        : ''
    }
    id = { scope = "${this.key.id.scope || ''}"; name = "${this.key.id.name}"; };
    version = "${this.key.version}";
    src = ${this.renderSrc()};${
      this.modules.length
        ? `
    modules = [
      ${this.modules.map((dep) => `self."${dep}"`).join('\n      ')}
    ];`
        : ''
    }
  };`;
  }

  /**
   * @param {boolean} asNixName - render Nix derivation compatible name, defaults to false
   * @returns {string}
   */
  renderKey(asNixName = false) {
    const keys = [this.host, this.key].filter(Boolean);
    return !asNixName
      ? keys.join(hostDelimiter)
      : keys.map((k) => k.id.toString().replace('@', '').replace('/', '-')).join('-');
  }

  /**
   * @returns {string}
   */
  renderSrc() {
    switch (this.src.type) {
      case 'url':
        const { url, sha1 } = this.src;
        // Some of the urls can look like "https://codeload.github.com/xolvio/cucumber-js/tar.gz/cf953cb5b5de30dbcc279f59e4ebff3aa040071c",
        // i.e. no extention given. That's why Nix unable to recognize the type of archive so we need to have
        // name specified explicitly to all Nix to infer the archive type.
        /** @type {string | undefined} */
        const name = !path.extname(url)
          ? `abort ''
        
        
        Failed to recognise the type of the archive of the \`${this.renderKey()}\` package served from
        \`${url}\`

        Override \`"${this.renderKey()}".src.name\` attribute in order to provide a file name extension
        to let Nix recognise the type of the archive and unpack it appropriately. For example:

          self: super: {
            "${this.renderKey()}" = super."${this.renderKey()}".override (x: {
              src = x.src.override {
                # Let Nix to recognise the type of archive so it unpacks it appropriately
                name = "${path.basename(url)}.tgz";
              };
            });
          }
        
      ''`
          : undefined;
        return `self.fetchurl { ${
          name
            ? `
      name = ${name};`
            : ''
        } 
      url = "${url}"; 
      ${
        sha1
          ? `sha1 = "${sha1}"`
          : `sha256 = abort ''
        
        
        Failed to infer \`sha256\` hash of the \`${this.renderKey()}\` package source from
        \`${url}\`.

        Override \`"${this.renderKey()}".src.sha256\` attribute in order to provide this missing piece to Nix.
        For example:
          
          self: super: {
            "${this.renderKey()}" = super."${this.renderKey()}".override (x: {
              # The sha256 value is obtained via
              #   nix-prefetch-url ${url}
              src = x.src.override { 
                sha256 = "<sha256>";
              };
            });
          }

      ''`
      }; 
    }`;

      case 'local':
        return `abort ''
      
      
      The \`${this.renderKey()}\` package is a local package. Override the \`"${this.renderKey()}".src\` attribute 
      in order to point Nix to the source of the package. For example:

        self: super: {
          "${this.renderKey()}" = super."${this.renderKey()}".override (x: {
            # See: https://nixos.org/manual/nix/stable/#builtin-path
            src = builtins.path {
              name = "${this.renderKey(true)}";
              path = ../../${this.key.id.toString()};
              # A filter function that can be used to limit the source that will be used.
              # Filter out node_modules folders form the package's source
              filter = p: t: ! (t == "directory" && lib.hasSuffix "node_modules" p);
            };
          });
        }

    ''`;
      default:
        throw new Error(`unhandled case: ${JSON.stringify(this.src)}`);
    }
  }
}

/**
 * @param {string} maybePath - maybe a path
 * @returns {boolean}
 */
function isPath(maybePath) {
  return maybePath.startsWith('file:') || maybePath.startsWith('.');
}

/**
 * @param {YarnLockJSON['object']} lock - a lock file content
 * @returns {{ tree: DepTree<Renderable> }}
 */
function generateDepTree(lock) {
  /**
   * @type DepTree<Package | Reference>
   */
  const tree = Object.keys(lock).reduce((acc, curr) => {
    const currData = lock[curr];
    const ref = parse(curr);
    const pinnedName = Key.key(ref.name, currData.version);

    try {
      if (!acc[pinnedName] || !!acc[pinnedName].ref) {
        acc[pinnedName] = Package.create(ref, currData);
      }

      // Replace an original package with its reference (alias).
      if (curr !== pinnedName) {
        acc[curr] = new Reference({
          key: new Key({
            id: Id.parse(ref.name),
            version: currData.version,
          }),
          ref: curr,
        });
      }
    } catch (e) {
      if (e.code !== 'ENOENT') {
        // Catch broken references of local packages.
        throw e;
      }
    }
    return acc;
  }, {});

  // Resolve references
  Object.entries(tree).forEach(([, value]) => {
    if (!Reference.is(value)) value.modules = value.modules.map((key) => resolveRef(key, tree)).filter(Boolean);
  });

  /**
   * Create dependency tree with direct links, i.e. no aliases.
   * @type DepTree<Package>
   */
  const pkgs = Object.entries(tree).reduce((acc, [key, value]) => {
    if (!Reference.is(value)) acc[key] = value;
    return acc;
  }, {});

  /**
   * Save short (without a version) references (aliases) for further use.
   * @type DepTree<Reference | BrokenReference>
   */
  const shortRefs = Object.entries(pkgs).reduce((acc, [key, value]) => {
    // if (!Reference.is(value)) acc[key] = value;
    const short = value.key.id.toString();
    if (acc[short]) {
      const keys = BrokenReference.is(acc[short]) ? Array.from(acc[short].keys) : [acc[short].key];
      return {
        ...acc,
        [short]: new BrokenReference({
          keys: new Set([...keys, value.key]),
          ref: short,
        }),
      };
    } else
      return {
        ...acc,
        [short]: new Reference({
          key: value.key,
          ref: short,
        }),
      };
  }, {});

  /**
   * Save references (aliases) for further use.
   * @type DepTree<Reference>
   */
  const refs = Object.entries(tree).reduce((acc, [key, value]) => {
    if (Reference.is(value)) acc[key] = value;
    return acc;
  }, {});

  return {
    tree: {
      ...refs,
      ...shortRefs,
      ...hostDependencyCycles(pkgs),
    },
  };
}

/**
 * Since Nix supports only a dependency tree that is a DAG, while Node.js ecosystem
 * allows dependency cycles, the cycles need to be resolved in a way so Nix can handle
 * it. It's possible to make that happen by localising such dependency cycles and merging
 * them in a single Nix derivation rather than as separate ones. That is, only dependency
 * cycles will be non-granular and the rest of the dependency tree will be granular.
 * Please note that such cycles are a quite rare case, however, it still needs to be
 * handled appropriately.
 *
 * This function traverses the tree in order to fix up dependency cycles in a way that
 * the package that is an entry point to a dependency cycle hosts the dependencies that are
 * part of the cycle inside of it.
 *
 * For example, assume the following dependency graph:
 *
 *   A → B → C → ╮
 *       ╰ ← ← ← D
 *
 * Where the B package transitively depends on itself. This function transforms the dependency
 * tree by cloning and modifying dependencies C and D so they will be hosted by package B. That
 * means that the dependency tree will contain two versions of package C and D: the original ones
 * and the ones that are modified to be hosted by B.
 *
 * Original packages have identifiers made of their name and version. In the example above the
 * original C package will be identified as:
 *
 *   C@1.0.0
 *
 * Hosted packages have identifiers of form <HOST>+<PACKAGE>. In the example above the hosted
 * C package will be identified as:
 *
 *   B@1.0.0+C@1.0.0
 *
 * The hosted C package will refer to hosted dependencies appropriately. For example it will depend
 * on the hosted D package identified as B@1.0.0+D@1.0.0 package, but not the original D package
 * identified as D@1.0.0.
 * The hosted D package, which depends on B, will identify it as:
 *
 *   B@1.0.0+B@1.0.0
 *
 * that doesn't refer to the source of package B@1.0.0 but rather indicates that the hosted package
 * needs to depend on its host. This type of package identifier is called a 'stub'. This is how a
 * cycle is broken so the dependency tree can be installed by Nix.
 *
 * @param {DepTree<Package>} tree
 * @returns {DepTree<Package>}
 */
function hostDependencyCycles(tree) {
  /** @type Set<Package> */
  const visited = new Set();

  /**
   * Traverses the tree rooted at a given node and transforms all packages that are entry points
   * to dependency cycles to host the dependencies that are part of the cycle in a single Nix
   * derivation so Nix can handle it. DFS implementation.
   *
   * @callback Traverse
   * @param {Package} node - a tree node
   * @param {string[]} tp - current traverse path, parent exclusively
   * @returns {?string[]} - a cycle as an array of serialized keys of modules, if found
   */

  /** @type {Traverse} */
  function traverse(node, tp = []) {
    assert.ok(node, 'Tree node not found!');
    if (visited.has(node)) return;
    // The node is a stub node so it already handles cycles it's part of.
    if (node.host && node.host.toString() === node.key.toString()) {
      visited.add(node);
      return;
    }

    const found = tp.find((key) => key.split(hostDelimiter).pop() === node.key.toString());
    if (found) {
      // The entry point into the cycle is already hosted by another entry point.
      if (found === node.renderKey() && node.host) {
        visited.add(node);
        return;
      }
      return [...tp.slice(tp.indexOf(found)), node.renderKey()];
    }
    const dtp = [...tp, node.renderKey()];
    /**
     * Collect possible cycles in this variable
     * @type {string[] | undefined}
     */
    let cycle;

    // Iterate over the node.modules in order to find a cycle. The first found cycle will be
    // presented in `cycle` variable. That is an array that contains serialized keys of all
    // the nodes within the cycle including the top-level (the beginning of the cycle) node
    // as the first and the last (the end of the cycle) elements of this array, inclusively.
    // So the first and the last elements point to the same original node in the dependency
    // tree.
    //
    // prettier-ignore
    while (node.modules.map(k => tree[k]).find(m => (cycle = traverse(m, dtp)))) {
      if (cycle[0].split(hostDelimiter).pop() === node.key.toString()) hostCycle(cycle);
      else return cycle;
    }

    visited.add(node);
    return;
  }

  /**
   * Modifies the dependency tree in a way that the package that is an entry point
   * to a dependency cycle, hosts cycled dependencies inside a single Nix derivation,
   * so Nix can handle it.
   *
   * @param {string[]} cycle - path of the cycle, where the first and thte last elements
   *                           are the same node with, potentially, different host
   */
  function hostCycle(cycle) {
    assert.ok(cycle.length > 1, 'Unable to handle a cycle with a length less that 2');
    const [parent, child] = cycle.slice(0, 2).map((key) => tree[key]);
    if (cycle.length === 2) {
      parent.modules = parent.modules.filter((k) => {
        return k.split(hostDelimiter).pop() !== child.key.toString();
      });
      const maybeStub = child.clone({ host: parent.host.clone(), modules: [] });
      tree[maybeStub.renderKey()] = tree[maybeStub.renderKey()] || maybeStub;
      parent.modules.push(maybeStub.renderKey());
      return;
    } else {
      const hostedChild = child.clone({
        host: parent.host ? parent.host.clone() : parent.key.clone(),
      });
      tree[hostedChild.renderKey()] = hostedChild;
      parent.modules[parent.modules.indexOf(child.renderKey())] = hostedChild.renderKey();
      return hostCycle([hostedChild.renderKey(), ...cycle.slice(2)]);
    }
  }

  // Mimic the top level modules as modules of a single
  // package to satisfy the `traverse` function's API.
  traverse(
    new Package({
      key: new Key({
        id: Id.parse('top-level'),
        version: 'N',
      }),
      src: { type: 'local' },
      modules: Object.keys(tree),
    })
  );

  return tree;
}

/**
 * Resolves package alias to it's direct name withinn the context of a
 * particular yarn.lock file.
 *
 * @example
 *   resolveRef('toposort@^2.0.2', tree) // -> 'toposort@2.0.3';
 *
 * @param {string} ref
 * @param {DepTree<Package | Reference>} tree
 * @returns {string | undefined}
 */
function resolveRef(ref, tree) {
  let refOrPkg = tree[ref];
  if (refOrPkg === undefined) {
    const { name, version } = parse(ref);
    const found = Object.keys(tree).filter((n) => n.startsWith(`${name}@`) && !Reference.is(tree[n]));
    if (isPath(version)) {
      // local package resolution
      assert.equal(found.length, 1, 'Found more that one local package with the same name');
      const direct = found.pop();
      refOrPkg = tree[direct];
      if (!refOrPkg) {
        throw new Error(`Unable to resolve: ${ref} agains the tree`);
      } else {
        return direct;
      }
    } else {
      // semver
      const availableCoercedVersions = found.map(parse).map(({ version: v }) => semver.coerce(v).version);
      const resolvedVersion = semver.minSatisfying(availableCoercedVersions, version);
      assert.notEqual(
        resolvedVersion,
        null,
        `Unable to resolve the '${version}' version of '${name}' against ${JSON.stringify(
          availableCoercedVersions,
          null,
          2
        )}, got ${resolvedVersion}.`
      );
      const direct = found[availableCoercedVersions.indexOf(resolvedVersion)];
      refOrPkg = tree[direct];
      if (!refOrPkg) {
        throw new Error(`unable to resolve: ${ref} agains the tree`);
      } else {
        return direct;
      }
    }
  }
  // assert.notEqual(refOrPkg, undefined);
  return Reference.is(refOrPkg) ? refOrPkg.key.toString() : ref;
}

/**
 * @param {{ tree: DepTree<Renderable> }} args
 * @returns {string}
 */
function render({ tree }) {
  return `# THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

self: super: {
${Object.keys(tree)
  .sort()
  .map((curr) => tree[curr].render())
  .join('\n')}
  
  # This information is required for automatic overlays generation logic.
  # It's not possible to inspect/reflect on the attrset that is being built via
  # fixed-point function without getting blocked by infinite recursion.
  # See https://github.com/NixOS/nixpkgs/blob/ee7722a7/lib/fixed-points.nix#L19
  #
  __meta__.aliases = {
  ${Object.keys(tree)
    .sort()
    .filter((curr) => Reference.is(tree[curr]) && !BrokenReference.is(tree[curr]))
    .map((curr) => tree[curr].render().replace('self.', ''))
    .join('\n')
    .split('\n')
    .join('\n  ')}

    # Loopback links, for convenience.
  ${Object.keys(tree)
    .sort()
    .filter((curr) => Package.is(tree[curr]))
    .map((curr) => `  "${curr}" = "${curr}";`)
    .join('\n')
    .split('\n')
    .join('\n  ')}
  };
}
`;
}

/**
 * Prints generated nix expression into stdout.
 *
 * @param {PrintArgs} args - a set of arguments to generate nix expression
 */
module.exports = async function print({ lock, out }) {
  /** @type YarnLockJSON */
  const { type, object: parsed } = lockfile.parse(await fs.readFile(lock, 'utf8'));
  assert.equal(type, 'success', 'Failed to parse yarn.lock file.');

  const { tree } = generateDepTree(parsed);
  await fs.writeFile(out, render({ tree }), 'utf8');
};

// For testing purposes
module.exports.hostDependencyCycles = hostDependencyCycles;
module.exports.render = render;
module.exports.Package = Package;
module.exports.Key = Key;
module.exports.Id = Id;
module.exports.BrokenReference = BrokenReference;
