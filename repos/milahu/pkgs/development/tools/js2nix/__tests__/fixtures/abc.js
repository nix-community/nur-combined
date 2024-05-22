const { createTree } = require('./util');

/**
 *   A → B → C → D
 */
exports.none = () =>
  createTree([
    { name: 'A', modules: ['B'] },
    { name: 'B', modules: ['C'] },
    { name: 'C', modules: ['D'] },
    { name: 'D', modules: [] },
  ]);

/**
 *     A → ╮
 *     ╰ ← B
 */
exports.direct = () =>
  createTree([
    { name: 'A', modules: ['B'] },
    { name: 'B', modules: ['A'] },
  ]);

/**
 *     A → B → C → ╮
 *         ╰ ← ← ← D
 *
 * D should be hosted by B.
 */
exports.transitive = () =>
  createTree([
    { name: 'A', modules: ['B'] },
    { name: 'B', modules: ['C'] },
    { name: 'C', modules: ['D'] },
    { name: 'D', modules: ['B'] },
  ]);

/**
 *         ╭ ← ← ← ← ← ← ← F
 *     A → B → C → D → E → ╯
 *             ╰ ← ← ← ╯
 *
 * E should be hosted by B.
 */
exports.embedded = () =>
  createTree([
    { name: 'A', modules: ['B'] },
    { name: 'B', modules: ['C'] },
    { name: 'C', modules: ['D'] },
    { name: 'D', modules: ['E'] },
    { name: 'E', modules: ['C', 'F'] },
    { name: 'F', modules: ['B'] },
  ]);

/**
 *     A → B → C → D → ╮
 *             ╰ ← ← ← E ← ╮
 *                     ╰ → F
 *     
 * F should be hosted by C.
 */
exports.overlap = () =>
  createTree([
    { name: 'A', modules: ['B'] },
    { name: 'B', modules: ['C'] },
    { name: 'C', modules: ['D'] },
    { name: 'D', modules: ['E'] },
    { name: 'E', modules: ['C', 'F'] },
    { name: 'F', modules: ['E'] },
  ]);
