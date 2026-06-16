# Clean Code Rules

## Comments — C1 to C5
- **C1 — Inappropriate Information:** Metadata (author, dates, change logs) belongs in Git, not source code. Remove HTML/CSS formatting in comments unless required by documentation generators.
- **C2 — Obsolete Comments:** Remove comments that are factually incorrect or describe logic that no longer exists. Update outdated comments immediately.
- **C3 — Redundant Comments:** Remove comments that repeat what code says (e.g., `i++; // increment i`). Keep comments only if they explain "Why" not "What."
- **C4 — Poorly Written Comments:** Rewrite comments to be concise, grammatically correct, professional. Avoid rambling.
- **C5 — Commented-Out Code:** Delete commented-out code immediately. Git remembers past code; source file should not.

## Environment — E1 to E2
- **E1 — Single Step Build:** System must build with a single command. Eliminate manual dependency installation. Create wrapper scripts (Makefile, build.sh, etc.).
- **E2 — Single Step Testing:** Entire test suite must run with a single command. Eliminate manual test configuration.

## Functions — F1 to F4
- **F1 — Too Many Arguments:** Target 0 arguments (ideal), 1-2 (acceptable), 3+ (forbidden). Refactor by wrapping args in object or splitting function.
- **F2 — No Output Arguments:** Arguments define inputs, not outputs. Eliminate patterns where argument is passed to be modified. Return values instead.
- **F3 — No Flag Arguments:** Boolean arguments imply function does more than one thing. Split into separate explicit functions (e.g., `renderSuite()` and `renderSingle()`).
- **F4 — Remove Dead Functions:** Delete methods never invoked. Do not comment out; remove entirely.

## General — G1 to G36
### G1-G10: Architecture & Structure
- **G1 — One Language Per File:** Minimize embedded languages (HTML, XML, SQL, CSS) in source files. Extract to separate files or resource managers.
- **G2 — Principle of Least Surprise:** Functions must implement behavior expected by their names. Implement `toString`, `equals` predictably. Remove empty stubs.
- **G3 — Handle Boundary Conditions:** Identify boundary conditions (`null`, 0, empty lists, max values). Add guard clauses.
- **G4 — Respect Safety Mechanisms:** Never suppress compiler warnings, disable failing tests, or swallow exceptions. Fix underlying issue.
- **G5 — DRY:** Extract duplicated logic into single helper methods or classes. High priority.
- **G6 — Correct Abstraction Level:** Base classes must know nothing about derivatives. Separate high-level concepts from low-level details.
- **G7 — Independence:** High-level concepts must be independent of low-level implementation.
- **G8 — Limit Exposed Information:** Keep interfaces tight. Use `private`/`protected` instead of `public`. Hide utility functions.
- **G9 — Remove Dead Code:** Delete unreachable code, unused variables, conditions always false.
- **G10 — Vertical Separation:** Declare variables just before use. Define private helpers immediately below first usage.

### G11-G20: Code Hygiene & Clarity
- **G11 — Consistency:** Apply naming conventions and logic patterns uniformly throughout codebase.
- **G12 — De-Clutter:** Remove unused variables, empty default constructors, unreferenced functions.
- **G13 — No Artificial Coupling:** Do not declare constants/enums "just because convenient." Move to class they logically belong to.
- **G14 — Eliminate Feature Envy:** Method should be more interested in its own class data. Move methods to object they primarily manipulate.
- **G15 — No Selector Arguments:** Avoid boolean/enum flags that select behavior inside function. Split into explicit methods.
- **G16 — Reveal Intent:** Avoid magic numbers and complex one-liners. Extract sub-expressions into well-named variables.
- **G17 — Misplaced Responsibility:** Place code where reader naturally expects to find it.
- **G18 — Avoid Inappropriate Static:** Prefer instance methods for polymorphism and testing. Use static only for pure mathematical utilities.
- **G19 — Use Explanatory Variables:** Replace magic numbers with named constants (e.g., `SECONDS_PER_DAY`).
- **G20 — Honest Function Names:** Names must strictly match implementation. Rename if you must look at code to understand what it does.

### G21-G36: Logic & Design
- **G21 — Understand the Algorithm:** Rewrite "hacky" or trial-and-error fixes cleanly.
- **G22 — Make Logical Dependencies Physical:** Pass dependencies explicitly via constructor or arguments.
- **G23 — Prefer Polymorphism:** Replace `switch/case` or `if/else` chains based on type codes with Polymorphism (Strategy/State patterns).
- **G24 — Follow Standard Conventions:** Adhere to established coding standards.
- **G25 — Replace Magic Numbers:** Replace raw numbers/strings with named constants.
- **G26 — Be Precise:** Handle `null` checks, currency precision, concurrency explicitly. Do not assume happy-path.
- **G27 — Structure over Convention:** Prefer meaningful structure over arbitrary conventions.
- **G28 — Encapsulate Conditionals:** Extract complex boolean expressions into named functions (e.g., `if (shouldStop())`).
- **G29 — Avoid Negative Conditionals:** Refactor negative conditionals to positive where possible (avoid `if (!isNotAvailable)`).
- **G30 — Functions Should Do One Thing:** Split functions that do more than one thing.
- **G31 — Hidden Temporal Couplings:** Structure arguments so dependent methods require results from earlier methods.
- **G32 — Don't Be Arbitrary:** Have clear reason for every structural choice.
- **G33 — Encapsulate Boundary Conditions:** Centralize `+1`/`-1` logic. Do not scatter boundary calculations everywhere.
- **G34 — One Level of Abstraction:** Functions should only call functions one level below them. Do not mix policy with details.
- **G35 — Keep Configurable Data at High Levels:** Define configuration constants at top level of class hierarchy.
- **G36 — Avoid Transitive Navigation:** Law of Demeter: avoid `a.getB().getC().doSomething()`. Only talk to immediate friends.

## Naming — N1 to N7
- **N1 — Choose Descriptive Names:** Names must reveal intent immediately. Rename generic names (`data`, `info`, `item`) to specific names (`customerRecord`).
- **N2 — Appropriate Abstraction Level:** Names should reflect business concepts, not technical implementation. Remove type info unless crucial (`accountList` → `accounts`).
- **N3 — Use Standard Nomenclature:** Append `Factory`, `Observer`, `Listener` when using design patterns.
- **N4 — Unambiguous Names:** Names must be clear and unambiguous.
- **N5 — Long Names for Long Scopes:** Short names (`i`, `x`) only in small scopes. Class members need long, precise names.
- **N6 — Avoid Encodings:** No Hungarian notation (`strName`, `iCount`), no member prefixes (`m_Name`), no interface prefixes (`IShape`).
- **N7 — Names Should Describe Side-Effects:** If `getAccount()` creates account if missing, rename to `getOrCreateAccount()`.

## Tests — T1 to T9
- **T1 — Insufficient Tests:** Test everything that can possibly break.
- **T2 — Use a Coverage Tool:** Measure and improve test coverage.
- **T3 — Don't Skip Trivial Tests:** Test simple getters/setters if part of public API.
- **T4 — Ignored Test = Ambiguity:** If requirement unclear, write test documenting ambiguity and mark as `@Ignore` with explanation.
- **T5 — Test Boundary Conditions:** Focus on edge cases: `null`, `0`, `-1`, empty strings, max values, date boundaries.
- **T6 — Exhaustively Test Near Bugs:** Write more tests for complex logic clusters and potential bug areas.
- **T7 — Patterns of Failure Are Revealing:** Analyze failure patterns to understand root causes.
- **T8 — Test Coverage Patterns Are Revealing:** Coverage gaps indicate risky areas.
- **T9 — Tests Should Be Fast:** No `Thread.sleep()`, real network calls, real file I/O, heavy DB connections. Use Mocks/Stubs/Fakes.
