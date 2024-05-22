#!/usr/bin/env node

// @ts-check

const assert = require('assert');
const chalk = require('chalk');
const { promises: fs, existsSync } = require('fs');
const path = require('path');
const optimist = require('optimist');
const { spawn } = require('promisify-child-process');
const duration = require('duration');
const rimraf = require('rimraf');
const stripAnsi = require('strip-ansi');

async function proxy (){
  const config = getConfig();
  const {
    _: [command, ...commands],
    h,
    help,
    v,
    version,
  } = config.args;

  /**
   * The main command routing
   */
  if (config.ignore) {
    // Proxy is explicitly ignored
    return passthru(config);
  } else if (v || version) {
    // Just a version print
    return passthru(config);
  } else if (h || help || command === 'help') {
    await printHelp(config);
    return passthru(config);
  } else if (!config.packageNixFilePath) {
    // No package.nix file found
    // TODO: implement a strict mode where it fails in case if file hasn't been found
    return passthru(config);
  } else if (['install', undefined, null].includes(command)) {
    // Proxy the instalation
    return install(config);
  } else if (['add', 'remove'].includes(command)) {
    // Proxy the package.json/yarn.lock files' modification commands
    return modifyYarnLock(config);
  } else {
    return passthru(config);
  }
};

/**
 * Print an additional header explaining
 *
 * @param {Config} config
 * @returns {Promise<any>}
 */
async function printHelp(config) {
  // Get non-silent logger anyway since it's a handler of the help flag
  const info = getLogger({
    ...config,
    args: {
      ...config.args,
      s: false,
      silent: false,
    },
  });

  info(`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Warning!

  Yarn is being proxied by the js2nix tool in order to hijack some of the regular workflow commands and
  provide a seamless developer experience of installation of Node.js modules using the Nix package
  manager. See more about the project at https://canv.am/js2nix. If you have come into issues, pass the
  '${noYarnProxy}' flag at any time for any command to disable the proxying feature and let us know
  about the case so we can fix it!

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      `);
}

/**
 * An override of the Yarn behaviour for the 'install' command. It checks for
 * @param {Config} config
 * @returns {Promise<any>}
 */
async function install(config) {
  const startTime = new Date();
  const info = getLogger(config);

  const updateLine = (() => {
    let len = 0;
    /** @param {string} txt */
    return txt => {
      const toWrite = '\r' + txt + ' '.repeat(Math.max(0, len - txt.length));
      info(toWrite);
      len = txt.length;
    };
  })();

  let args = [
    '--show-trace',
    '--max-jobs',
    'auto',
    ...(config.args.prod || config.args.production ? ['-A', 'prod'] : []),
    '--no-out-link',
    config.packageNixFilePath,
  ];

  const initialMessage = chalk.grey('[js2nix]') + ' ❄️  Building Nix packages...';
  updateLine(initialMessage);
  const interval = setInterval(() => {
    updateLine(`${initialMessage} ${renderDuration(startTime)}`);
  }, 100);

  /**
   * @type {import('promisify-child-process').Output}
   */
  const resp = await spawn(config.nixBuild, args, {
    encoding: 'utf8',
    maxBuffer: 1 << 24, // 16Mib
    cwd: config.cwd,
    stdio: ['ignore', 'pipe', 'pipe'],
  }).catch(r => r);
  clearInterval(interval);

  if (resp.code !== 0) {
    // Even if verbosity is disabled by CLI option we need to print an exception.
    process.stderr.write(`\r${initialMessage} failed!                     

${[config.nixBuild, ...args].join(' \\\n  ')}

${resp.stderr.toString().trim()}

`);
    // We don't throw an error here to not mix the proxy tool
    // stack trace with the Nix stack trace and to not hijack
    // the original exit code.
    process.exit(resp.code);
  }

  const nodeModules = path.join(config.cwd, 'node_modules');
  const output = resp.stdout.toString().trim();

  if (existsSync(nodeModules)) {
    const realpath = await fs.realpath(nodeModules).catch(() => '');
    if (realpath !== output) {
      await new Promise((r, rj) => rimraf(nodeModules, err => (err ? rj(err) : r())));
      await fs.symlink(output, nodeModules);
    }
  } else {
    await fs.symlink(output, nodeModules);
  }

  updateLine(`${initialMessage} done!`);
  info('\n');
}

/**
 * Returns formatted human readable time duration, between the given date and `new Date()`.
 *
 * @param {Date} from
 * @param {Date} to
 * @returns {string}
 */
function renderDuration(from, to = new Date()) {
  return duration(from, to).toString(1, 1);
}

/**
 * In order to allow properly modify package.json and yarn.lock files we allow to invoke
 * the 'remove' and 'add' commands so they would be running without proxying and then invoke
 * the `install` function to create/override the `node_modules` link.
 *
 * @param {Config} config
 * @returns {Promise<any>}
 */
async function modifyYarnLock(config) {
  // We provide a stable path from within the TMPDIR in order to let yarn leverage the already
  // created node_modules folder if any, so it hits cache and doesn't create that folder every
  // single time but just modify, if possible.
  const tmpNodeModules = path.join(
    config.tmpDirPath,
    'yarn-proxy',
    config.cwd.slice(1),
    'node_modules',
  );

  const argv = [...config.argv, '--modules-folder', tmpNodeModules];

  await passthru({
    ...config,
    argv,
    args: parseYarnArgs(argv),
  });

  return install(config);
}

/**
 * @param {Config} config
 * @returns {Promise<any>}
 */
async function passthru(config) {
  return spawn(config.yarn, config.argv, {
    stdio: 'inherit',
    cwd: config.cwd,
  });
}

/**
 * @typedef { Record<string, string | string[] | boolean> & {
 *   _: string[],
 *   '$0': string,
 *   cwd: string | undefined
 *   s: boolean,
 *   silent: boolean,
 *   h: boolean,
 *   help: boolean,
 * }} YarnArgs
 */

/**
 * @typedef {{
 *   yarn: string,
 *   nixBuild: string,
 *   packageNixFilePath: string | undefined,
 *   tmpDirPath: string,
 *   argv: string[],
 *   args: YarnArgs,
 *   ignore: boolean,
 *   cwd: string,
 * }} Config
 */

/**
 * A flag that is being handled by the proxy only. In particular, passing this
 * is supposed to allow to disable proxying as a whole.
 */
const noYarnProxy = '--no-yarn-proxy';

/**
 * @param {NodeJS.ProcessEnv} env
 * @returns {Config}
 */
function getConfig(env = process.env) {
  const argv = process.argv.slice(2).filter(e => e !== noYarnProxy);
  const ignore = process.argv.slice(2).some(e => e === noYarnProxy);
  const tmpDirPath = [env.TMPDIR, env.TMP, '/var/tmp', '/tmp'].filter(Boolean).find(existsSync);
  assert.ok(tmpDirPath, 'Failed to find temporary directory');

  const args = parseYarnArgs(argv);
  const cwd = String(args.cwd || process.cwd());
  const packageNixFilePath = existsSync(path.join(cwd, 'package.nix'))
    ? path.join(cwd, 'package.nix')
    : undefined;

  return {
    yarn: '@yarn@/bin/yarn',
    nixBuild: '@nix@/bin/nix-build',
    packageNixFilePath,
    tmpDirPath,
    argv,
    args,
    ignore,
    cwd,
  };
}

const implicitBoolean = [
  'check-files',
  'disable-pnp',
  'emoji',
  'enable-pnp',
  'pnp',
  'flat',
  'focus',
  'force',
  'frozen-lockfile',
  'har',
  'ignore-engines',
  'ignore-optional',
  'ignore-platform',
  'ignore-scripts',
  'json',
  'link-duplicates',
  'no-bin-links',
  'no-default-rc',
  'no-lockfile',
  'non-interactive',
  'no-node-version-check',
  'no-progress',
  'offline',
  'prefer-offline',
  'prod',
  'production',
  'pure-lockfile',
  's',
  'silent',
  'scripts-prepend-node-path',
  'skip-integrity-check',
  'strict-semver',
  'update-checksums',
  'v',
  'version',
  'verbose',
  'h',
  'help',
];

/**
 * @param {?string[]} argv
 * @returns {YarnArgs}
 */
function parseYarnArgs(argv = process.argv.slice(2)) {
  // The following arguments are going to be parsed into a key/value while they are
  // a boolean (--json) flag and a command (install):
  //   optimist.parse(['--json', 'install']) // -> { json: 'install' }
  //
  // We need to list implicict boolean flags in order to prevent malformed parsing
  // output as above.
  return optimist
    .boolean(
      // Cut '--' from the start, if any.
      [...implicitBoolean, noYarnProxy].map(i => i.replace(/^-{1,2}/, '')),
    )
    .parse(argv);
}

/**
 *
 * @param {Config} config
 * @returns {(string) => void}
 */
function getLogger(config) {
  const silent = !!(config.args.silent || config.args.s);
  return silent ? () => {} : x => process.stderr.write(process.stderr.isTTY ? x : stripAnsi(x));
}

proxy().catch(e => {
  process.stderr.write(e.toString());
  process.exit(1);
});
