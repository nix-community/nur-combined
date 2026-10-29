# Comprehensive Publishing Guide for 29 Package Registries

This guide provides exact, production-ready steps to publish the **`seowebchecker-seoaudit-sdk`** suite across 29 high Domain Authority (DA) registries to maximize SEO authority and backlink equity for [seowebchecker.com](https://seowebchecker.com/).

---

## 🎯 Domain Authority (DA) Matrix

| Ecosystem | Registry | Domain Authority (DA) | Package Name | Directory |
| :--- | :--- | :---: | :--- | :--- |
| **R** | [cran.r-project.org](https://cran.r-project.org) | **99** | `seowebchecker` | [`r/`](./r) |
| **GitHub Packages** | [github.com](https://github.com/jaiganesh6999?tab=packages) | **96** | `SeoWebChecker.SeoAudit` / `ghcr.io` | Root (`./`) |
| **Enterprise / Cloud** | [dev.azure.com](https://dev.azure.com) | **96** | `seowebchecker` (Feed) | Root (`./`) |
| **Node.js** | [npmjs.com](https://npmjs.com) | **95** | `seowebchecker-seoaudit-sdk` | [`npm/`](./npm) |
| **Containers** | [hub.docker.com](https://hub.docker.com) | **94** | `seowebchecker/seoaudit-sdk` | [`docker/`](./docker) |
| **Python (PyPI)** | [pypi.org](https://pypi.org) | **94** | `seowebchecker-seoaudit-sdk` | [`python/`](./python) |
| **Go** | [pkg.go.dev](https://pkg.go.dev) | **93** | `github.com/jaiganesh6999/seowebchecker-seoaudit-sdk` | Root (`./`) |
| **Java** | [central.sonatype.com](https://central.sonatype.com) | **93** | `com.seowebchecker:seowebchecker-seoaudit-sdk` | [`java/`](./java) |
| **Dart / Flutter** | [pub.dev](https://pub.dev) | **93** | `seowebchecker` | [`dart/`](./dart) |
| **Conda / Python** | [anaconda.org](https://anaconda.org) | **92** | `seowebchecker-seoaudit-sdk` | [`conda/`](./conda) |
| **Ruby** | [rubygems.org](https://rubygems.org) | **92** | `seowebchecker-seoaudit-sdk` | [`ruby/`](./ruby) |
| **.NET** | [nuget.org](https://nuget.org) | **92** | `SeoWebChecker.SeoAudit` | [`dotnet/`](./dotnet) |
| **PHP** | [packagist.org](https://packagist.org) | **91** | `seowebchecker/seoaudit-sdk` | [`php/`](./php) |
| **Perl** | [metacpan.org](https://metacpan.org) | **91** | `SeoWebChecker::SeoAudit` | [`perl/`](./perl) |
| **iOS / macOS** | [cocoapods.org](https://cocoapods.org) | **90** | `SeoWebChecker` | [`swift/`](./swift) |
| **Rust** | [crates.io](https://crates.io) | **90** | `seowebchecker-seoaudit-sdk` | [`rust/`](./rust) |
| **JavaScript (Yarn)** | [yarnpkg.com](https://yarnpkg.com) | **90** | `seowebchecker-seoaudit-sdk` | [`npm/`](./npm) |
| **Web Assets** | [bower.io](https://bower.io) | **88** | `seowebchecker` | [Root (`./bower.json`)](./bower.json) |
| **Java / Android** | [jitpack.io](https://jitpack.io) | **88** | `com.github.jaiganesh6999.seowebchecker-seoaudit-sdk` | [`java/`](./java) |
| **Windows (Chocolatey)** | [chocolatey.org](https://community.chocolatey.org) | **88** | `seowebchecker` | [`chocolatey/`](./chocolatey) |
| **Enterprise Artifacts (JFrog)** | [jfrog.io](https://seowebchecker.jfrog.io) | **88** | `seowebchecker-seoaudit-sdk` | Root (`./`) |
| **Frontend (Vite)** | [vite.dev](https://vite.dev) | **87** | `vite-plugin-seowebchecker` | [`vite/`](./vite) |
| **Haskell** | [hackage.haskell.org](https://hackage.haskell.org) | **87** | `seowebchecker` | [`haskell/`](./haskell) |
| **Julia** | [juliahub.com](https://juliahub.com) | **84** | `SeoWebCheckerAudit` | [`julia/`](./julia) |
| **Elixir / Erlang** | [hex.pm](https://hex.pm) | **83** | `seowebchecker` | [`elixir/`](./elixir) |
| **Lua** | [luarocks.org](https://luarocks.org) | **82** | `seowebchecker` | [`lua/`](./lua) |
| **Multi-Format / Cloud** | [cloudsmith.io](https://cloudsmith.io) | **78** | `seowebchecker-seoaudit-sdk` | Root (`./`) |
| **Apple / Swift** | [swiftpackageindex.com](https://swiftpackageindex.com) | **76** | `SeoWebChecker` | [Root (`./Package.swift`)](./Package.swift) |
| **Clojure** | [clojars.org](https://clojars.org) | **75** | `net.clojars.seoaitools/seowebchecker-seoaudit-sdk` | [`clojure/`](./clojure) |

---

## 1. PyPI (`pypi.org` - DA 94)
```powershell
cd python
python setup.py sdist bdist_wheel
python -m twine check dist/*
python -m twine upload -u __token__ -p <YOUR_PYPI_TOKEN> dist/*
```

---

## 2. NPM (`npmjs.com` - DA 95)
```powershell
cd npm
npm.cmd publish --access public --otp=<6_DIGIT_2FA_CODE>
```

---

## 3. Packagist (`packagist.org` - DA 91)
1. Go to [https://packagist.org/packages/submit](https://packagist.org/packages/submit).
2. Paste: `https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk`.
3. Click **Check** $\rightarrow$ **Submit**.

---

## 4. NuGet (`nuget.org` - DA 92)
1. Create an account on [nuget.org](https://www.nuget.org) and generate an API Key.
2. Build & push from PowerShell:
```powershell
cd dotnet\src\SeoWebChecker.SeoAudit
dotnet pack -c Release -o ..\..\nupkg
dotnet nuget push ..\..\nupkg\SeoWebChecker.SeoAudit.1.0.0.nupkg --api-key <YOUR_NUGET_KEY> --source https://api.nuget.org/v3/index.json
```

---

## 5. RubyGems (`rubygems.org` - DA 92)
1. Create an account on [rubygems.org](https://rubygems.org).
2. Build and push:
```bash
cd ruby
gem build seowebchecker-seoaudit-sdk.gemspec
gem push seowebchecker-seoaudit-sdk-1.0.0.gem
```

---

## 6. Docker Hub (`hub.docker.com` - DA 94)
1. Create an account on [hub.docker.com](https://hub.docker.com).
2. Build and push your multi-platform image:
```bash
docker login -u <YOUR_DOCKER_USERNAME>
docker build -t <YOUR_DOCKER_USERNAME>/seoaudit-sdk:latest -f docker/Dockerfile .
docker push <YOUR_DOCKER_USERNAME>/seoaudit-sdk:latest
```

---

## 7. Crates.io (`crates.io` - DA 90)
1. Log in to [crates.io](https://crates.io) via GitHub and generate an API Token.
2. Run in terminal:
```bash
cd rust
cargo login dsd
cargo publish
```

---

## 8. Maven Central (`central.sonatype.com` - DA 93)
1. Create a namespace ticket / account on [central.sonatype.com](https://central.sonatype.com).
2. Verify domain ownership for `seowebchecker.com` (DNS TXT record).
3. Deploy via Maven:
```bash
cd java
mvn clean deploy
```

---

## 9. CPAN (`metacpan.org` - DA 91)
1. Register a PAUSE account at [pause.perl.org](https://pause.perl.org).
2. Build distribution tarball:
```bash
cd perl
perl Makefile.PL
make dist
```
3. Upload the generated `SeoWebChecker-SeoAudit-1.0.0.tar.gz` via PAUSE web upload interface.

---

## 10. Julia Packages (`juliahub.com` - DA 84 / `julialang.org`)
1. Ensure the package in `julia/` has valid `Project.toml` and test suite (`test/runtests.jl`).
2. Install the **[JuliaRegistrator GitHub App](https://github.com/apps/juliaregistrator)** on this GitHub repository.
3. In any commit or issue on GitHub, comment:
```text
@JuliaRegistrator register subdir=julia
```
4. Registrator automatically tests the package and opens a registration PR on `JuliaRegistries/General`.
5. After the automated 3-day community waiting period, it is merged and indexed automatically on [JuliaHub.com](https://juliahub.com) and the Julia ecosystem.

---

## 11. CRAN (`cran.r-project.org` - DA 99)
1. Build the CRAN-compliant package source archive (`seowebchecker_1.0.0.tar.gz` in `r/` or download via the GitHub Actions `Build and Check R Package for CRAN` workflow).
2. Go to the official CRAN package submission web portal:
   **[https://xmpalantir.wu.ac.at/cransubmit/](https://xmpalantir.wu.ac.at/cransubmit/)** (or [cran.r-project.org/submit.html](https://cran.r-project.org/submit.html))
3. Upload `seowebchecker_1.0.0.tar.gz`.
4. Enter your maintainer name and email (`support@seowebchecker.com` or your preferred email).
5. Click **Upload Package**.
6. Check your inbox and click the confirmation link sent by CRAN to initiate automated incoming checks.

---

## 12. Clojars (`clojars.org` - DA 75)
1. The package group is set to your pre-verified personal group: **`net.clojars.seoaitools`** (package identifier: `net.clojars.seoaitools/seowebchecker-seoaudit-sdk`).
2. In your Clojars Account Profile on [clojars.org](https://clojars.org), generate a **Deploy Token**.
3. Deploy directly via Leiningen or GitHub Actions:
   - **Method A (GitHub Actions)**:
     - In your GitHub repo settings, add repository secrets:
       - `CLOJARS_USERNAME`: `seoaitools`
       - `CLOJARS_PASSWORD`: your Clojars deploy token
     - Run the workflow `Test and Publish Clojure Package to Clojars`.
   - **Method B (CLI)**:
     ```bash
     cd clojure
     export CLOJARS_USERNAME="seoaitools"
     export CLOJARS_PASSWORD="your-deploy-token"
     lein deploy clojars
     ```

---

## 13. Hackage (`hackage.haskell.org` - DA 87)
1. Create a free account at **[hackage.haskell.org/users/register](https://hackage.haskell.org/users/register)**.
2. Locate the pre-built sdist tarball:
   `haskell/dist/seowebchecker-1.0.0.tar.gz` (or download from GitHub Actions `Build and Check Haskell Package for Hackage`).
3. Upload via the web portal:
   👉 **[https://hackage.haskell.org/packages/upload](https://hackage.haskell.org/packages/upload)**
4. Or upload via the `cabal` CLI:
   ```bash
   cabal upload haskell/dist/seowebchecker-1.0.0.tar.gz
   ```

---

## 14. Go Modules (`pkg.go.dev` - DA 93)
Go packages are decentralized and automatically indexed by Google's Go Proxy:
1. Ensure `go.mod`, `doc.go`, and code are committed and pushed to GitHub `main`.
2. Create and push a semver git tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
3. Trigger instant indexing on the official Go module proxy:
   ```bash
   curl -s "https://proxy.golang.org/github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/@v/v1.0.1.info"
   ```
4. Visit your live documentation page on pkg.go.dev:
   👉 **[https://pkg.go.dev/github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://pkg.go.dev/github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)**

---

## 15. Dart & Flutter (`pub.dev` - DA 93)
Package name: **`seowebchecker`** (verified available).
1. Test and dry-run locally or via GitHub Actions:
   ```bash
   cd dart
   dart pub get
   dart test
   dart pub publish --dry-run
   ```
2. Publish to `pub.dev`:
   ```bash
   dart pub publish
   ```
   *The Dart CLI will display a one-time Google authentication link. Open it in your browser and sign in with your Google Account (`jaiganesh6999@gmail.com`).*
3. Once authenticated, your package will be immediately live at:
   👉 **[https://pub.dev/packages/seowebchecker](https://pub.dev/packages/seowebchecker)**

---

## 16. Elixir & Erlang (`hex.pm` - DA 83)
Package name: **`seowebchecker`** (verified available).
1. Create a free account at **[hex.pm/signup](https://hex.pm/signup)**.
2. In your Hex account settings, navigate to **[API Keys](https://hex.pm/dashboard/keys)** and generate a new key named `github-publish` with the `api:write` or `publish:packages` permission.
3. **Publish Method A (GitHub Actions - Recommended)**:
   - In your GitHub repo settings, add repository secret `HEX_API_KEY`: `<your_hex_api_key>`.
   - Trigger the GitHub Actions workflow **`Elixir Test & Hex Publish`** (`workflow_dispatch` or push to `main`).
   - It will run `mix test`, `mix hex.build`, and publish via `mix hex.publish --yes`.
4. **Publish Method B (CLI)**:
   ```bash
   cd elixir
   mix deps.get
   mix test
   mix hex.user auth
   mix hex.publish
   ```
5. Once published, your package and documentation will be live at:
   👉 **[https://hex.pm/packages/seowebchecker](https://hex.pm/packages/seowebchecker)**
   👉 **[https://hexdocs.pm/seowebchecker](https://hexdocs.pm/seowebchecker)**

---

## 17. Lua (`luarocks.org` - DA 82)
Package name: **`seowebchecker`** (verified available).
1. Create a free account at **[luarocks.org](https://luarocks.org)**.
2. Locate the rockspec file in the repository:
   `seowebchecker-1.0.0-1.rockspec` (or `lua/seowebchecker-1.0.0-1.rockspec`).
3. **Publish Method A (Web Upload - Easiest)**:
   - Go to 👉 **[https://luarocks.org/upload](https://luarocks.org/upload)**.
   - Click "Browse" and select `seowebchecker-1.0.0-1.rockspec`.
   - Click **Submit**.
   - LuaRocks will validate the rockspec and publish the module immediately!
4. **Publish Method B (CLI)**:
   - In your LuaRocks account settings, copy your API key.
   - Run:
     ```bash
     luarocks upload seowebchecker-1.0.0-1.rockspec --api-key=<YOUR_LUAROCKS_API_KEY>
     ```
5. Once uploaded, your module will be immediately live at:
   👉 **[https://luarocks.org/modules/seowebchecker/seowebchecker](https://luarocks.org/modules/seowebchecker/seowebchecker)**

---

## 18. Conda (`anaconda.org` - DA 92)
Package identifier: **`seowebchecker-seoaudit-sdk`**
Pre-built package file:
📂 `conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2`

### Method A: Web Upload (Drag & Drop - 30 Seconds)
1. Sign in to your account on **[anaconda.org](https://anaconda.org)**.
2. Click **Upload** (top right) or navigate to `https://anaconda.org/<YOUR_USERNAME>/upload`.
3. Drag and drop the built conda package archive:
   `conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2`
4. Click **Upload Package**.

### Method B: CLI via `anaconda-client`
```bash
pip install anaconda-client
anaconda login
anaconda upload conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2
```

### Method C: Automated via GitHub Actions
Add secret `ANACONDA_API_TOKEN` in GitHub Repository Settings. The workflow `Conda Build & Anaconda.org Publish` will automatically build and publish on push to `main`!

Once uploaded, your package is live at:
👉 **`https://anaconda.org/<YOUR_USERNAME>/seowebchecker-seoaudit-sdk`**
And installable via:
```bash
conda install -c <YOUR_USERNAME> seowebchecker-seoaudit-sdk
```

---

## 19. CocoaPods (`cocoapods.org` - DA 90)
Pod identifier: **`SeoWebChecker`**  
Podspec file: `SeoWebChecker.podspec` (and `swift/SeoWebChecker.podspec`)

### Method A: Direct via CocoaPods Trunk CLI (Recommended)
1. **Register your CocoaPods Trunk session** (run on macOS or any machine with Ruby & CocoaPods installed):
   ```bash
   pod trunk register jaiganesh6999@gmail.com 'Rahul Gupta' --description='MacBook Pro'
   ```
2. **Confirm your registration**:
   Open the email sent to `jaiganesh6999@gmail.com` with the subject *"Confirm your CocoaPods Trunk registration"* and click the confirmation link.
3. **Verify registration**:
   ```bash
   pod trunk me
   ```
4. **Publish the Pod**:
   From the repository root:
   ```bash
   pod trunk push SeoWebChecker.podspec --allow-warnings
   ```

### Method B: Automated via GitHub Actions
1. After registering with CocoaPods trunk on your local machine, retrieve your trunk token:
   - On macOS/Linux: `cat ~/.netrc` or find the `trunk.cocoapods.org` password token.
2. In GitHub repository settings $\rightarrow$ Secrets and variables $\rightarrow$ Actions, add a new repository secret:
   - Name: `COCOAPODS_TRUNK_TOKEN`
   - Value: `<YOUR_TRUNK_TOKEN>`
3. The `.github/workflows/test-and-lint-pod.yml` workflow will automatically test and publish the pod to CocoaPods Trunk on push to `main`!

Once published, your pod will be indexed and live at:  
👉 **[https://cocoapods.org/pods/SeoWebChecker](https://cocoapods.org/pods/SeoWebChecker)**

And developers can integrate it into their iOS / macOS apps via their `Podfile`:
```ruby
pod 'SeoWebChecker', '~> 1.0.0'
```

---

## 20. Bower (`bower.io` - DA 88)
Package identifier: **`seowebchecker`**  
Package specification: `bower.json`

### Architecture & Installation
As per official [bower.io documentation](https://bower.io/docs/creating-packages/), the legacy central registry (`bower register`) has been retired, and Bower natively consumes first-class Git repositories.

Developers install and consume the package directly via Bower CLI:
```bash
bower install jaiganesh6999/seowebchecker-seoaudit-sdk --save
```
Or declare it directly in their application's `bower.json`:
```json
{
  "dependencies": {
    "seowebchecker": "jaiganesh6999/seowebchecker-seoaudit-sdk#^1.0.0"
  }
}
```

---

## 21. Swift Package Index (`swiftpackageindex.com` - DA 76)
Package identifier: **`SeoWebChecker`**  
Package manifest: Root `Package.swift`

### Submission & Indexing
1. Go to 👉 **[https://swiftpackageindex.com/add-a-package](https://swiftpackageindex.com/add-a-package)**.
2. Enter the repository URL:
   `https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk`
3. Click **Submit**.
4. The Swift Package Index build system will automatically fetch releases/tags and index compatibility across iOS, macOS, watchOS, tvOS, and Linux.

Once indexed, the package is live at:  
👉 **`https://swiftpackageindex.com/jaiganesh6999/seowebchecker-seoaudit-sdk`**

---

## 22. Yarn (`yarnpkg.com` - DA 90)
Package identifier: **`seowebchecker-seoaudit-sdk`**  
Package directory: [`npm/`](./npm)

### Architecture & Synchronization
Yarn seamlessly indexes and distributes all packages published to the NPM registry. Publishing via npm instantly makes the package available across `yarnpkg.com` and all Yarn package clients worldwide.

### Publishing & Installation
1. Publish from `npm/` directory:
   ```bash
   cd npm
   npm publish --access public
   ```
2. Once published, the package is immediately live on Yarn:  
   👉 **[https://yarnpkg.com/package/seowebchecker-seoaudit-sdk](https://yarnpkg.com/package/seowebchecker-seoaudit-sdk)**

3. Developers install via Yarn CLI:
   ```bash
   yarn add seowebchecker-seoaudit-sdk
   ```

---

## 23. Vite (`vite.dev` - DA 87)
Package identifier: **`vite-plugin-seowebchecker`**  
Package directory: [`vite/`](./vite)

### Architecture & Ecosystem Indexing
As documented in the official [vite.dev Plugin Guide](https://vite.dev/guide/api-plugin.html), Vite plugins are published to npm using the `vite-plugin-` prefix and tagged with the `"vite-plugin"` keyword. The Vite community and [vite.dev/plugins](https://vite.dev/plugins/) index these packages automatically.

### Publishing & Installation
1. Publish from `vite/` directory:
   ```bash
   cd vite
   npm publish --access public
   ```
2. Once published, the package is immediately live on the Vite plugin registry and NPM:  
   👉 **[https://www.npmjs.com/package/vite-plugin-seowebchecker](https://www.npmjs.com/package/vite-plugin-seowebchecker)**  
   👉 **[https://yarnpkg.com/package/vite-plugin-seowebchecker](https://yarnpkg.com/package/vite-plugin-seowebchecker)**

3. Developers install via Vite project:
   ```bash
   npm install --save-dev vite-plugin-seowebchecker
   # or
   yarn add -D vite-plugin-seowebchecker
   ```

4. Configure in `vite.config.js`:
   ```javascript
   import { defineConfig } from 'vite';
   import seoWebChecker from 'vite-plugin-seowebchecker';

   export default defineConfig({
     plugins: [
       seoWebChecker({
         failOnError: false, // Set to true to fail CI builds on SEO errors
         minScore: 80,       // Minimum acceptable SEO score (0-100)
       })
     ]
   });
   ```

---

## 24. JitPack (`jitpack.io` - DA 88)
Package identifier: **`com.github.jaiganesh6999.seowebchecker-seoaudit-sdk`**  
Package directory: [`java/`](./java) & Root [`pom.xml`](./pom.xml)

### Architecture & On-Demand Building
[JitPack](https://jitpack.io) is a JVM package repository that builds Git repositories on-demand directly from tags and commits. Root [`pom.xml`](./pom.xml) aggregates the [`java/`](./java) module, and [`jitpack.yml`](./jitpack.yml) specifies the OpenJDK 17 build environment.

### Live Package & Coordinates
👉 **[https://jitpack.io/#jaiganesh6999/seowebchecker-seoaudit-sdk](https://jitpack.io/#jaiganesh6999/seowebchecker-seoaudit-sdk)**

### Developer Installation

#### Maven
1. Add JitPack repository to your `pom.xml`:
```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```

2. Add the dependency:
```xml
<dependency>
    <groupId>com.github.jaiganesh6999.seowebchecker-seoaudit-sdk</groupId>
    <artifactId>seowebchecker-seoaudit-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

#### Gradle (Groovy DSL)
1. Add repository to `settings.gradle` or root `build.gradle`:
```groovy
repositories {
    mavenCentral()
    maven { url 'https://jitpack.io' }
}
```

2. Add dependency:
```groovy
dependencies {
    implementation 'com.github.jaiganesh6999.seowebchecker-seoaudit-sdk:seowebchecker-seoaudit-sdk:1.0.0'
}
```

---

## 25. Cloudsmith (`cloudsmith.io` - DA 78)
Package identifier: **`seowebchecker-seoaudit-sdk`**  
Package directory: Root & All Ecosystem Modules

### Architecture & Multi-Format Cloud Hosting
[Cloudsmith](https://cloudsmith.io) is an enterprise-grade, multi-format package management platform supporting 28+ package formats (Python, NPM, NuGet, Ruby, Conda, Debian, RPM, Docker, etc.). Under Cloudsmith's **Open-Source Hosting Policy**, public open-source projects receive 50GB storage and 200GB monthly package delivery for free.

By enabling **Public Broadcasts** on the repository, Cloudsmith generates a public web showcase page with high DA authority backlink to [https://seowebchecker.com/](https://seowebchecker.com/).

### Setup & Automated Publishing

1. **Create Free Open-Source Account**:
   - Register on [https://cloudsmith.io](https://cloudsmith.io).
   - Create organization `seowebchecker` (or personal handle).
   - Create repository `seowebchecker-seoaudit-sdk` with visibility set to **Open-Source / Public**.
   - Get API key from [https://cloudsmith.io/user/settings/api/](https://cloudsmith.io/user/settings/api/).

2. **One-Click Automated Publishing Script**:
   Run the included PowerShell helper script:
   ```powershell
   .\publish_cloudsmith.ps1 -ApiKey <YOUR_CLOUDSMITH_API_KEY> -Owner seowebchecker
   ```

3. **Manual CLI Uploads**:
   ```bash
   # Python Wheel
   cloudsmith push python seowebchecker/seowebchecker-seoaudit-sdk python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl

   # NPM Tarball
   cloudsmith push npm seowebchecker/seowebchecker-seoaudit-sdk npm/seowebchecker-seoaudit-sdk-1.0.1.tgz

   # NuGet Package
   cloudsmith push nuget seowebchecker/seowebchecker-seoaudit-sdk dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg

   # Ruby Gem
   cloudsmith push ruby seowebchecker/seowebchecker-seoaudit-sdk ruby/seowebchecker-seoaudit-sdk-1.0.0.gem

   # Conda Package
   cloudsmith push conda seowebchecker/seowebchecker-seoaudit-sdk conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2
   ```

4. **Live Repository Showcase**:
   👉 **[https://cloudsmith.io/~seowebchecker/repos/seowebchecker-seoaudit-sdk/packages/](https://cloudsmith.io/~seowebchecker/repos/seowebchecker-seoaudit-sdk/packages/)**

---

## 26. Azure Artifacts (`dev.azure.com` - DA 96)
Feed identifier: **`seowebchecker`**  
Package directory: Root & All Ecosystem Modules

### Architecture & Enterprise Cloud Feeds
[Azure Artifacts](https://learn.microsoft.com/azure/devops/artifacts/) is Microsoft's enterprise-grade cloud package registry hosted on Azure DevOps (`dev.azure.com` - DA 96). It integrates NuGet, npm, Python (PyPI), Maven, and Universal Packages into unified project-scoped feeds.

When hosted in a public Azure DevOps project, the feed is publicly browsable and consumable by any developer without requiring credentials.

### Setup & Public Feed Creation
1. **Create an Azure DevOps Organization & Project**:
   - Go to [https://dev.azure.com](https://dev.azure.com) and create an organization (e.g. `seowebchecker`).
   - Create a project named `seowebchecker-seoaudit-sdk` (set Visibility to **Public**).
2. **Create the Artifacts Feed**:
   - Navigate to **Artifacts** -> **Create Feed**.
   - **Name**: `seowebchecker`.
   - **Scope**: Project (`seowebchecker-seoaudit-sdk`).
   - Click **Create**.
3. **Generate a Personal Access Token (PAT)**:
   - Click User Settings (gear icon in upper right) -> **Personal Access Tokens**.
   - Create a token with **Packaging (Read, write, & manage)** scope.

### Automated One-Click Publishing
Run the included PowerShell or batch helper script:
```powershell
.\publish_azure_artifacts.bat -Pat "<YOUR_AZURE_DEVOPS_PAT>" -Org "seowebchecker" -Project "seowebchecker-seoaudit-sdk" -Feed "seowebchecker"
```

### Manual CLI Publishing

#### NuGet (.NET)
```bash
dotnet nuget push dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg `
  --source "https://pkgs.dev.azure.com/<ORG>/<PROJECT>/_packaging/<FEED>/nuget/v3/index.json" `
  --api-key <YOUR_PAT>
```

#### Python (PyPI)
```bash
python -m twine upload `
  --repository-url "https://pkgs.dev.azure.com/<ORG>/<PROJECT>/_packaging/<FEED>/pypi/upload/" `
  -u <ORG> -p <YOUR_PAT> `
  python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl
```

### Live Public Feed URL
👉 **`https://dev.azure.com/seowebchecker/seowebchecker-seoaudit-sdk/_artifacts/feed/seowebchecker`**

---

## 27. GitHub Packages (`github.com` - DA 96)
Package identifier: **`SeoWebChecker.SeoAudit`** / **`ghcr.io/jaiganesh6999/seowebchecker-seoaudit-sdk`**  
Package directory: Root & Ecosystem Modules

### Architecture & Public Developer Showcase
[GitHub Packages](https://docs.github.com/packages) is Microsoft / GitHub's premier package hosting service with maximum domain authority (`github.com` - DA 96). It hosts NuGet, Docker / OCI containers (GHCR), npm, Maven, and RubyGems with direct links to the source repository and website backlink to [https://seowebchecker.com/](https://seowebchecker.com/).

### Automated Publishing via GitHub Actions
A dedicated workflow is included at [`.github/workflows/publish-github-packages.yml`](./.github/workflows/publish-github-packages.yml).
1. Go to the repository's **Actions** tab on GitHub:  
   👉 **[Actions -> Publish to GitHub Packages](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/actions/workflows/publish-github-packages.yml)**
2. Click **Run workflow** -> **Branch: main** -> **Run workflow**.
3. GitHub Actions automatically builds and publishes the NuGet package and the GHCR Docker container using the built-in `GITHUB_TOKEN`.

### Local Manual Publishing
Run the included PowerShell or batch helper script:
```powershell
.\publish_github_packages.bat -Token "<YOUR_GITHUB_PAT>" -Owner "jaiganesh6999"
```

### Live Public Package Showcase
👉 **[https://github.com/jaiganesh6999?tab=packages](https://github.com/jaiganesh6999?tab=packages)**  
👉 **[https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/pkgs/container/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/pkgs/container/seowebchecker-seoaudit-sdk)**

---

## 28. Chocolatey (`community.chocolatey.org` - DA 88)
Package identifier: **`seowebchecker`**  
Package directory: [`chocolatey/`](./chocolatey)

### Architecture & Windows Package Ecosystem
[Chocolatey](https://community.chocolatey.org) is the primary Windows package manager ecosystem. Publishing `seowebchecker` to the Chocolatey Community Repository allows millions of developers and system administrators to install the CLI with a single command (`choco install seowebchecker`) and generates an authoritative public package page with backlinks to [https://seowebchecker.com/](https://seowebchecker.com/).

### Package Contents
The package is pre-configured in [`chocolatey/`](./chocolatey):
- [`seowebchecker.nuspec`](./chocolatey/seowebchecker.nuspec): Metadata, license, tags, and project URL.
- [`tools/seowebchecker.bat`](./chocolatey/tools/seowebchecker.bat): Automatic cross-environment CLI runner.
- [`tools/chocolateyinstall.ps1`](./chocolatey/tools/chocolateyinstall.ps1): Automated install script.

### Publishing to Chocolatey

1. **Obtain API Key**:
   - Register or log in to [https://community.chocolatey.org/account](https://community.chocolatey.org/account).
   - Copy your personal API key.

2. **One-Click Publishing**:
   Run the included PowerShell or batch helper script:
   ```cmd
   .\publish_chocolatey.bat -ApiKey "<YOUR_CHOCOLATEY_API_KEY>"
   ```

3. **Manual CLI Command**:
   ```bash
   choco pack chocolatey/seowebchecker.nuspec --outputdirectory chocolatey
   choco push chocolatey/seowebchecker.1.0.0.nupkg --source "'https://push.chocolatey.org/'" -k="'<YOUR_API_KEY>'"
   ```

### Live Public Package Page
👉 **`https://community.chocolatey.org/packages/seowebchecker`**

---

## 29. JFrog Artifactory (`seowebchecker.jfrog.io` - DA 88)
Registry endpoint: **`https://seowebchecker.jfrog.io/artifactory`**  
Package directory: Root & Ecosystem Modules

### Architecture & Enterprise Artifact Hosting
[JFrog Artifactory](https://jfrog.com/artifactory/) is the industry standard enterprise artifact repository. The dedicated instance at **`https://seowebchecker.jfrog.io/`** provides enterprise-grade package hosting for Python wheels, npm packages, NuGet binaries, Ruby gems, Chocolatey packages, and Conda distributions.

### Setup & Authentication
1. **Log in to Artifactory**:
   - Navigate to [https://seowebchecker.jfrog.io/](https://seowebchecker.jfrog.io/).
   - Click on your profile (top right) -> **Edit Profile** -> **Authentication Settings** -> **Generate an Access Token** (or API Key).

2. **One-Click Automated Publishing Script**:
   Run the included batch runner:
   ```cmd
   .\publish_jfrog.bat -Token "<YOUR_JFROG_ACCESS_TOKEN>" -Repo "generic-local"
   ```
   *(Or with username and password/API key)*:
   ```cmd
   .\publish_jfrog.bat -Username "<YOUR_USERNAME>" -Password "<YOUR_PASSWORD_OR_API_KEY>" -Repo "generic-local"
   ```

3. **Standard Package Manager CLI Uploads**:

#### Python (PyPI)
```bash
python -m twine upload `
  --repository-url https://seowebchecker.jfrog.io/artifactory/api/pypi/pypi-local `
  -u <USERNAME> -p <ACCESS_TOKEN> `
  python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl
```

#### NuGet (.NET)
```bash
dotnet nuget push dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg `
  --source https://seowebchecker.jfrog.io/artifactory/api/nuget/nuget-local `
  --api-key <USERNAME>:<ACCESS_TOKEN>
```

#### npm
```bash
npm publish npm/seowebchecker-seoaudit-sdk-1.0.1.tgz `
  --registry=https://seowebchecker.jfrog.io/artifactory/api/npm/npm-local/
```

### Live Artifactory Dashboard
👉 **`https://seowebchecker.jfrog.io/ui/repos/tree/General`**
