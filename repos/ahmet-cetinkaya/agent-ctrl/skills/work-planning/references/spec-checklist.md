# Domain Checklists

A domain checklist is a unit test suite for the requirements text: each item asks whether something is written well enough, never whether the implementation works. It lives at `checklists/<domain>.md` beside the spec, for a reviewer to work through before approval.

## When

Only on request, through `/ac:spec <spec-path> --checklist <domain>`, where `<domain>` is a short kebab-case name such as `security`, `ux`, `api`, or `data`. The built-in `requirements.md` is not a domain checklist; `/ac:spec` maintains it.

## Focus

Settle the focus before writing, from the request and the spec. Ask at most three questions in one message, only where the answer changes the checklist content, covering scope breadth, depth (a quick author self-check or a formal review gate), risk emphasis, audience, and explicit exclusions. Without answers, default to a standard depth, a reviewer audience, and the two most relevant focus areas.

## Items

Write each item as a question about the text, tagged with its quality dimension and a reference:

- Completeness — "Are error requirements defined for every external failure mode? [Completeness, Gap]"
- Clarity — "Is 'prominent display' quantified with a measurable size or position? [Clarity, FR-004]"
- Consistency — "Do the retry requirements agree between US1 and US3? [Consistency, FR-007]"
- Measurability — "Can SC-002 be confirmed without reading the code? [Measurability, SC-002]"
- Scenario and edge-case coverage — "Is the behavior defined when the list is empty? [Coverage, Edge case]"
- Non-functional — "Are accessibility requirements stated for keyboard-only use? [Gap]"
- Dependencies and assumptions — "Is the assumption about the existing session store validated? [Assumption]"

Reference an ID (`FR-###`, `SC-###`, `US<n>`, `PB-<n>`) when the item checks existing text, and `Gap` when it checks for something missing. Never write implementation tests such as "Verify the button submits the form."

## File rules

- Number items `CHK001` onward. When the file exists, append and continue from the last `CHK` number; never delete, renumber, or rewrite earlier items.
- Group items under the dimension headings above.
- Leave every new item unchecked. The checkbox belongs to the reviewer: `[x]` means the reviewer judged the text satisfies the item, not that any work is done. Evaluate items only when the reviewer asks.
- A failing item is resolved by refining the spec with `/ac:spec <spec-path>`, not by editing the checklist.
