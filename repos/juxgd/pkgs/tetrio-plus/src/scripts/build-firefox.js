#!node
// To be used by pack-firefox.sh
const vueutil = require('@vue/component-compiler-utils');
const compiler = require('vue-template-compiler');
const { visit } = require('ast-types');
const recast = require('recast');
const build = recast.types.builders;

const acorn = require('acorn');
const parser = {
  parse(source) {
    return acorn.parse(source, {
      allowHashBang: true,
      ecmaVersion: 'latest',
      sourceType: 'module',
      locations: true
    });
  }
}

let chunks = [];
process.stdin.on('data', chunk => {
  chunks.push(chunk);
});
process.stdin.on('end', () => {
  let superchunk = chunks.join('');
  let ast = recast.parse(superchunk, { parser });
  visit(ast, {
    visitTaggedTemplateExpression(path) {
      if (path.value.tag.name != 'html') return false;
      let templateValue = path.value.quasi.quasis[0].value;
      let source = templateValue.cooked;
      let compiled = vueutil.compileTemplate({
        source: source,
        filename: 'component.js',
        compiler: compiler,
        prettify: true
      });
      let objdef = path.parentPath.parentPath.value;
      for (let prop of objdef) {
        if (prop.key.name == 'template')
          objdef.splice(objdef.indexOf(prop), 1);
      }

      if (compiled.errors.length > 0) {
        for (let error of compiled.errors)
          console.error(error);
        process.exit(1);
      }

      objdef.push(build.property(
        'init',
        build.identifier('render'),
        recast.parse(
          `(() => {\n${compiled.code};\nreturn render;\n})()`,
          { parser }
        ).program.body[0].expression
      ));

      objdef.push(build.property(
        'init',
        build.identifier('staticRenderFns'),
        recast.parse(
          `(() => {\n${compiled.code};\nreturn staticRenderFns;\n})()`,
          { parser }
        ).program.body[0].expression
      ));

      return false;
    }
  });
  process.stdout.write(recast.print(ast).code);
});
