// @ts-check

const { hostDependencyCycles } = require('../lib/print');
const { renderSnapshot } = require('./fixtures/util');
const abc = require('./fixtures/abc');

describe('Host dependency cycle', () => {
  const cases = [
    'none', //
    'direct', //
    'transitive', //
    'embedded', //
    'overlap', //
  ].map(n => [n, abc[n]]);

  it.each(cases)('the %p case', (_, generator) => {
    const tree = hostDependencyCycles(generator());
    expect(renderSnapshot(tree)).toMatchSnapshot();
  });
});
