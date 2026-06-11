const html = arg => arg.join('');
export default {
  template: html`
    <div :class="{ error: expressionError }">
      <b><slot></slot></b>
      <input
        type="text"
        ref="input"
        @input="update"
        @change="$emit('change')"
        @focus="$emit('focus')"
        @blur="$emit('blur')"
        :value="value"
      />
      <span class="help">
        ?
        <div class="helptext">
          This is an <em>expression</em>. It can perform simple arithmetic and
          has access to variables.<br>

          The <code>$</code> variable is special and refers to the value of the
          current event.<br>

          Operators: <code>+ - * / > < >= <= == != && ||</code>

          See the wiki for more details.
        </div>
      </span>
      <div v-if="expressionError">
        {{ expressionError }}
      </div>
    </div>
  `,
  props: ['value', 'optional'],
  computed: {
    expressionError() {
      try {
        if (this.value.length == 0) {
          if (this.optional) return null;
          throw new Error("Expression is required");
        }
        let expval = new ExpVal(this.value);
        let val = expval.evaluate({}, {});
        return null;
      } catch(ex) {
        return ex.toString().replace(/^Error:\s*/, '');
      }
    }
  },
  methods: {
    update() {
      this.$emit('input', this.$refs.input.value);
    }
  }
}
