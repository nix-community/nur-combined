# Clean Code

Apply to every line of code you write or change. The repository's own conventions outrank these defaults; the clean-code review lens finds what this rule should have prevented.

- Names say what a thing is or does, at the reader's level: no abbreviations to decode, no `data`/`tmp`/`result`/`handle` placeholders, booleans that read as predicates, one name per concept across the codebase.
- One function does one thing at one level of abstraction and fits on a screen. A block that needs a label becomes a named function; a flag argument becomes two functions.
- Control flow reads top-down: guard clauses first, the happy path unindented, nesting at most two levels, no clever one-liners that need decoding.
- No duplication inside the code you write; a repeated block becomes the one function that owns it. Do not refactor adjacent code that is merely untidy — note it.
- Constants are named; there are no magic numbers or strings. Errors are handled at the layer that can act on them; none are swallowed.
- Comments say why, never what. Commented-out code, dead code, debug output, and ownerless TODOs are deleted, not shipped.
- Match the file's existing formatting, idioms, and naming case, then run the project's formatter and linter on what you touched.
- Before reporting, reread the diff as a reviewer with the clean-code lens; fix anything it would flag before handing over.
