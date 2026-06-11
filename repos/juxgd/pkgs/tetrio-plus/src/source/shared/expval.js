// cool post: https://chidiwilliams.com/post/evaluator/
// this implementation is probably pretty jank

const expValCache = {};
class ExpVal {
  constructor(expr) {
    this.expr = expr;
    let exp = expr.trim();
    const tokenizers = {
      literal: /^-?[0-9]+(?:\.[0-9]*)?/,
      operator: /^(?:\*\*|==|>=|<=|!=|>|<|&&|\|\||[+\-*/%~])/,
      leftparan: /^\(/,
      rightparan: /^\)/,
      function: /^[A-Za-z]+\(/,
      variable: /^[A-Za-z$#]([\w$]|{{|}})*/,
      comma: /^,/
    };
    const precedence = {
      '!': 17,
      '**': 16,
      '*': 15,
      '/': 15,
      '%': 15,
      '+': 14,
      '-': 14,
      '>=': 12,
      '<=': 12,
      '!=': 12,
      '<': 12,
      '>': 12,
      '==': 11,
      '&&': 7,
      '||': 6
    }
    let tokens = [];
    let pos = 0;

    scan: while (exp.length > 0) {
      for (let [token, regex] of Object.entries(tokenizers)) {
        let result = regex.exec(exp);
        if (!result) continue;
        if (token == 'rightparan' && tokens[tokens.length-1]?.type == 'function')
          throw new Error(`Zero argument functions not allowed (at pos ${pos})`);
        tokens.push({
          type: token,
          value: token == 'literal' ? parseFloat(result[0]) : result[0],
          pos: pos
        });
        pos += result[0].length;
        exp = exp.slice(result[0].length).trim();
        continue scan;
      }
      throw new Error(`Unexpected token "${exp[0]}" at position ${pos}`);
    }

    let operators = [];
    let out = [];
    for (let token of tokens) {
      if (token.type == 'literal' || token.type == 'variable') {
        out.push(token);
      }
      if (token.type == 'leftparan' || token.type == 'function' || token.type == 'comma') {
        operators.push(token);
      }
      if (token.type == 'rightparan') {
        unwind: while (true) {
          if (operators.length == 0)
            throw new Error(`Couldn't find matching left paranthesis at position ${token.pos}`);
          let last = operators[operators.length - 1];
          switch (last.type) {
            case 'leftparan':
              operators.pop(); // remove '(';
              break unwind;
            case 'function':
              out.push(operators.pop()); // remove '(';
              break unwind;
            default:
              out.push(operators.pop());
              break;
          }
        }
      }
      if (token.type == 'operator') {
        // note: tetrio desktop uses an old chromium version that doesn't support this api yet,
        // so here's a manual implementation
        function findLastIndex(array, predicate) {
          for (let i = array.length-1; i >= 0; i--)
            if (predicate(array[i]))
              return i;
          return -1;
        }

        let paranGroupStart = findLastIndex(operators, op => op.value == '(');
        // note: index is -1 if there are no paranthesis, thus slicing from 0 is correct
        // otherwise, add 1 to exclude the actual paranthetical operator.
        let hasGreater = operators
          .slice(paranGroupStart + 1)
          .some(op => precedence[op.value] >= precedence[token.value]);
        if (hasGreater)
          while (operators.length > paranGroupStart+1)
            out.push(operators.pop());
        operators.push(token);
      }
    }
    while (operators.length)
      out.push(operators.pop());

    this.rpn = out;
  }

  static get(expression) {
    if (!expValCache[expression])
      expValCache[expression] = new ExpVal(expression);
    return expValCache[expression];
  }

  static substitute(variableName, variables) {
    if (!variableName.includes('{'))
      return variableName;

    let substituted = variableName.replace(/{{(.+?)}}/, ($, ident) => {
      return variables[ident] || 0;
    });
    if (substituted.includes('{') || substituted.includes('}'))
      throw new Error('invalid variable substitution pattern');
    return substituted;
  }

  evaluate(variables={}, functions={}) {
    Object.assign(functions, {
      if(a, b, c) {
        return (a ? b : c) || 0;
      },
      floor: Math.floor,
      ceil: Math.ceil,
      round: Math.round,
      sin: Math.sin,
      cos: Math.cos,
      tan: Math.tan,
      max: Math.max,
      min: Math.min
    })
    let stack = [];
    let args = [];
    let lastToken = null;
    let req = (size) => {
      if (stack.length < size)
        throw new Error(`Error evaluating expression: "${this.expr}", stack underflow.`);
    }
    for (let token of this.rpn) {
      if (token.type == 'literal') stack.push(token.value);
      if (token.type == 'variable') stack.push(variables[ExpVal.substitute(token.value, variables)] || 0);
      if (token.type == 'comma') {
        req(1);
        args.push(stack.pop());
      }
      if (token.type == 'function') {
        req(1);
        args.push(stack.pop());
        let func = functions[token.value.slice(0, -1)];
        if (!func) throw new Error(`Unknown function ${token.value.slice(0, -1)}`);
        stack.push(func(...args.reverse()));
        args.splice(0);
      }
      if (token.type == 'operator') {
        req(2);
        let a = stack.pop();
        let b = stack.pop();
        switch (token.value) {
          case  '+': stack.push(b  + a); break;
          case  '-': stack.push(b  - a); break;
          case  '*': stack.push(b  * a); break;
          case  '/': stack.push(b  / a); break;
          case  '%': stack.push(b  % a); break;
          case '**': stack.push(b ** a); break;
          case '==': stack.push(b == a); break;
          case '>=': stack.push(b >= a); break;
          case '<=': stack.push(b <= a); break;
          case  '>': stack.push(b  > a); break;
          case  '<': stack.push(b  < a); break;
          case '!=': stack.push(b != a); break;
          case '&&': stack.push(b && a); break;
          case '||': stack.push(b || a); break;
          default: throw new Error("Unknown operator " + token.value);
        }
      }
    }
    if (stack.length !== 1)
      throw new Error(`Error evaluating expression: "${this.expr}". Ended with ${stack.length} values.`);
    return stack[0];
  }
}

function assert(expr, expected, variables={}, functions={}) {
  let result = new ExpVal(expr).evaluate(variables, functions);
  if (result != expected)
    console.error(`ExpVal test case fail: ${expr} -> ${result}, expected ${expected}`);
}
assert('2+2', 4);
assert('two+2', 4, { two: 2 });
assert('(two+2)==4', 1, { two: 2 });
assert('(((two+2)==4))==0', 0, { two: 2 });
assert('test(1)', 2, {}, { test: x => x+1 });
assert('(left%10)==1', 1, { left: 1 });
assert('(left%10==1)', 0, { left: 2 });
assert('1 == 2', 0);
assert('if((((two+2)==4))==1, 3, 1)', 3, { two: 2 }, { if: (a, b, c) => a ? b : c });
assert('if((((two+2)==4))==0, 3, 1)', 1, { two: 2 }, { if: (a, b, c) => a ? b : c });


if (typeof musicGraph != 'undefined') musicGraph(graph => graph.ExpVal = ExpVal);
if (typeof module != 'undefined' && module.exports) module.exports.ExpVal = ExpVal;
if (typeof window != 'undefined') window.ExpVal = ExpVal;
