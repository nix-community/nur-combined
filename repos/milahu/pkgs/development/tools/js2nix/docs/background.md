## Background

There are a number of package managers that manage dependencies for Node.js projects. These managers work well for small- or mid-sized projects, but not particularly well for large ones.

For example, to install dependencies for a CI agent, we use `yarn install` (or equivalent, for a different package manager), which brings in dependencies and packs them into a resulting `node_modules` folder. Even if we cache the `node_modules` folder by storing it in S3, we still need to retrieve it from S3 and unpack the cached bundle, which takes time to process.

This approach is not granular: if we change a single package version, we need to reinstall, create a new cache bundle, and upload it to S3. For large Node.js dependency closures, this high overhead is not optimal. The problem multiplies for every dependency closure (one for each `package.json` or `yarn.lock` tuple).

Adding to that, most existing package managers treat installation results as a single entity, triggering reproducibility, integrity, and correctness checks of the whole dependency closure on every modification. This is because the dependency folder layout is flat (to solve massive file duplication) and files in the output folder need to be organised appropriately, which makes every individual package in that folder context-dependent on the particular installation.

Another issue is with the local development workflow. When the codebase gets larger, it's natural to split it up into smaller, independent sub-projects so the parts can be efficiently reused. However, this approach can cause issues related to dependency management. For example, making and testing changes across many sub-projects or repositories become complicated very quickly. For example, to build TypeScript sub-projects locally and commit their artefacts into source control.

Because of this, it's easy to lose track of changed packages. You can forget to rebuild or relink them. Debugging changes can lead to wrong results and the dependency artefact (`node_modules` folder) might not reflect the state of the codebase and needs to be synced manually by a developer (using `yarn install`), which brings a high cognitive load.

In addition to that, the Node.js ecosystem provides dependency managers and build tools in a single interface. Those cannot be split because the dependencies are not just being installed but being built as well. Among the other things, a package build (installation, in terms of Node.js ecosystem) process is [a source of concerns](https://eslint.org/blog/2018/07/postmortem-for-malicious-package-publishes) around the safety of the Node.js ecosystem.

### Can Nix be used for Node.js dependencies to adress the above?

Nix can solve these issues. Specifically:

- Nix can granularly install dependencies on CI and not rebuild the whole dependency closure, but rebuild only what has changed. 
- Nix can manage local package changes and automatically rebuild them when the new environment build is initiated without an explicit manual trigger involved. 
- No additional checks on the whole dependency closure are required, since Nix relies on the inputs. If no inputs have changed, no rebuild is triggered. 
- Nix provides usability around life-cycle scripts of the packages and makes them explicit, well-controlled, and safely runs them within a sandbox where no userspace resources are available for the script.
