# mvn2nix

## error: access to URI 'https://github.com/NixOS/nixpkgs/archive/a332da8588aeea4feb9359d23f58d95520899e3c.tar.gz' is forbidden in restricted mode

https://github.com/nix-community/NUR/actions/runs/5752194167/job/15592607096#step:4:4492

```
INFO:nur.eval:Evaluate repository milahu
trace: warning: [npmlock2nix] You are using the new v2 beta api. The interface isn't stable yet. Please report any issues at https://github.com/nix-community/npmlock2nix/issues
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
error:
       … while querying the derivation named 'mwdumper-1.25'

       … while evaluating the attribute 'buildPhase' of the derivation 'mwdumper-1.25'

       at /nix/store/pqc8pcnx3w2dc0cbch351p5nl22flpr3-source/pkgs/stdenv/generic/make-derivation.nix:300:7:

          299|     // (lib.optionalAttrs (attrs ? name || (attrs ? pname && attrs ? version)) {
          300|       name =
             |       ^
          301|         let

       … while evaluating the attribute 'buildMavenRepositoryFromLockFile'

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/default.nix:24:3:

           23|
           24|   buildMavenRepositoryFromLockFile = pkgs.buildMavenRepositoryFromLockFile;
             |   ^
           25| }

       … while realising the context of a path

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/default.nix:5:10:

            4|   sources = import ./nix/sources.nix;
            5|   pkgs = import nixpkgs {
             |          ^
            6|     overlays = [

       … while evaluating call site

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:122:31:

          121|         else
          122|           spec // { outPath = fetch config.pkgs name spec; }
             |                               ^
          123|     ) config.sources;

       … while calling 'fetch'

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:63:23:

           62|   # The actual fetching function.
           63|   fetch = pkgs: name: spec:
             |                       ^
           64|

       … while evaluating call site

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:68:41:

           67|     else if spec.type == "file" then fetch_file pkgs spec
           68|     else if spec.type == "tarball" then fetch_tarball pkgs name spec
             |                                         ^
           69|     else if spec.type == "git" then fetch_git spec

       … while calling 'fetch_tarball'

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:15:31:

           14|
           15|   fetch_tarball = pkgs: name: spec:
             |                               ^
           16|     let

       … while evaluating call site

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:22:9:

           21|       if spec.builtin or true then
           22|         builtins_fetchTarball { name = name'; inherit (spec) url sha256; }
             |         ^
           23|       else

       … while calling 'builtins_fetchTarball'

       at /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source/pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:95:27:

           94|   # fetchTarball version that is compatible between all the versions of Nix
           95|   builtins_fetchTarball = { url, name, sha256 }@attrs:
             |                           ^
           96|     let

       error: access to URI 'https://github.com/NixOS/nixpkgs/archive/a332da8588aeea4feb9359d23f58d95520899e3c.tar.gz' is forbidden in restricted mode
ERROR:nur.update:repository milahu failed to evaluate: milahu does not evaluate:
$ nix-env -f /run/user/1001/tmp02d4bycj/default.nix -qa * --meta --xml --allowed-uris https://static.rust-lang.org --option restrict-eval true --option allow-import-from-derivation true --drv-path --show-trace -I nixpkgs=/nix/store/pqc8pcnx3w2dc0cbch351p5nl22flpr3-source -I /nix/store/3p78l119i3anm0gd2wqbr5jgyd6rvvhs-source -I /run/user/1001/tmp02d4bycj/default.nix -I /home/runner/work/NUR/NUR/lib/evalRepo.nix
```

```
$ grep -r a332da8588aeea4feb9359d23f58d95520899e3c pkgs/development/tools/mvn2nix/src/mvn2nix
pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.json:        "rev": "a332da8588aeea4feb9359d23f58d95520899e3c",
pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.json:        "url": "https://github.com/NixOS/nixpkgs/archive/a332da8588aeea4feb9359d23f58d95520899e3c.tar.gz",
```

```
$ grep -r sources.json pkgs/development/tools/mvn2nix/src/mvn2nix
pkgs/development/tools/mvn2nix/src/mvn2nix/nix/sources.nix:    { sourcesFile ? ./sources.json
```

```
$ grep -r sources.nix pkgs/development/tools/mvn2nix/src/mvn2nix
pkgs/development/tools/mvn2nix/src/mvn2nix/default.nix:{ nixpkgs ? (import ./nix/sources.nix).nixpkgs,
pkgs/development/tools/mvn2nix/src/mvn2nix/default.nix:  sources = import ./nix/sources.nix;
```

## error: maven-resources-plugin:jar:3.3.0 is missing

```
$ nix-build . -A mvn2nix
building
Using repository /nix/store/yv6xxhagkclpsz13ivb1rgx717pdmxrf-mvn2nix-repository
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.fzakaria:mvn2nix >------------------------
[INFO] Building mvn2nix 0.1
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[WARNING] The POM for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 is missing, no dependency information available
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  1.251 s
[INFO] Finished at: 2023-08-03T16:07:52Z
[INFO] ------------------------------------------------------------------------
[ERROR] Plugin org.apache.maven.plugins:maven-resources-plugin:3.3.0 or one of its dependencies could not be resolved: The following artifacts could not be resolved: org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 (absent): Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 has not been downloaded from it before. -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/PluginResolutionException

error: builder for '/nix/store/la3knfzgi4s7rcpipk4kfnn45lv91n16-mvn2nix-0.1.drv' failed with exit code 1;
```

<blockquote>

edit: updating dependencies in pom.xml could be simpler:

```
# update dependencies
# https://www.baeldung.com/maven-dependency-latest-version
mvn versions:use-latest-releases
```

see also: pkgs/mwdumper/update.sh

</blockquote>

mvn2nix-repository:

pkgs/development/tools/mvn2nix/src/mvn2nix/derivation.nix

```
    buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; });
```

pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json

```
    "org.apache.maven.plugins:maven-resources-plugin:jar:2.6": {
      "layout": "org/apache/maven/plugins/maven-resources-plugin/2.6/maven-resources-plugin-2.6.jar",
      "sha256": "07bd1b98b5b029af91fabcf99a9b3463b9dc09b993f28c2ee0ccc98265888ca6",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/2.6/maven-resources-plugin-2.6.jar"
    },
```

https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.jar

```
$ wget https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.jar
$ sha256sum maven-resources-plugin-3.3.0.jar 
9c7d0c7ffed082647a5fe0d0e4db9dede7dbb16dc7f34fc49c2f0ac07b9dba56  maven-resources-plugin-3.3.0.jar
```

patch:

```
    "org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0": {
      "layout": "org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.jar",
      "sha256": "9c7d0c7ffed082647a5fe0d0e4db9dede7dbb16dc7f34fc49c2f0ac07b9dba56",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.jar"
    },
```

new error:

```
$ nix-build . -A mvn2nix
building
Using repository /nix/store/wvblkkw7wlsj5sgq4dvyspm3ch5g605s-mvn2nix-repository
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.fzakaria:mvn2nix >------------------------
[INFO] Building mvn2nix 0.1
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[WARNING] The POM for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 is missing, no dependency information available
[INFO] 
[INFO] --- resources:3.3.0:resources (default-resources) @ mvn2nix ---
[WARNING] The POM for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 is missing, no dependency information available
[WARNING] Error injecting: org.apache.maven.plugins.resources.ResourcesMojo
java.lang.NoClassDefFoundError: org/apache/maven/shared/filtering/MavenFilteringException
```

old source:

```
    "org.apache.maven.plugins:maven-resources-plugin:pom:2.6": {
      "layout": "org/apache/maven/plugins/maven-resources-plugin/2.6/maven-resources-plugin-2.6.pom",
      "sha256": "a7842d002fbc7d2a84217106be909bc85ea35aa47031e410ab8afbb3b3364e2d",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/2.6/maven-resources-plugin-2.6.pom"
    },
```

new source:

https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.pom

```
$ wget https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.pom
$ sha256sum maven-resources-plugin-3.3.0.pom
3d27e776f52c3261a1f78272ca9681c2cab78dcd9586a35e13ad31b8c98d3114  maven-resources-plugin-3.3.0.pom
```

patch:

```
    "org.apache.maven.plugins:maven-resources-plugin:pom:3.3.0": {
      "layout": "org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.pom",
      "sha256": "3d27e776f52c3261a1f78272ca9681c2cab78dcd9586a35e13ad31b8c98d3114",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-resources-plugin/3.3.0/maven-resources-plugin-3.3.0.pom"
    },
```

new error:

```
$ nix-build . -A mvn2nix
building
Using repository /nix/store/38hwdlcqkf528sngbknfjqlv8w4rbi0j-mvn2nix-repository
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.fzakaria:mvn2nix >------------------------
[INFO] Building mvn2nix 0.1
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  0.911 s
[INFO] Finished at: 2023-08-03T16:27:57Z
[INFO] ------------------------------------------------------------------------
[ERROR] Plugin org.apache.maven.plugins:maven-resources-plugin:3.3.0 or one of its dependencies could not be resolved: Failed to read artifact descriptor for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0: The following artifacts could not be resolved: org.apache.maven.plugins:maven-plugins:pom:36 (absent): Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven.plugins:maven-plugins:pom:36 has not been downloaded from it before. -> [Help 1]
```

new source:

org.apache.maven.plugins:maven-plugins:pom:36

https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom

```
$ wget https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom
$ sha256sum maven-plugins-36.pom 
b0020d55af2afd9bff042d627dd52b7a4828243014ded0ae89412e1717582056  maven-plugins-36.pom
```

patch:

```
    "org.apache.maven.plugins:maven-plugins:pom:36": {
      "layout": "org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom",
      "sha256": "b0020d55af2afd9bff042d627dd52b7a4828243014ded0ae89412e1717582056",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom"
    },
```

new error:

```
The following artifacts could not be resolved: org.apache.maven:maven-parent:pom:36
```

old sources:

```
$ grep org.apache.maven:maven-parent:pom: pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json | sort -V 
    "org.apache.maven:maven-parent:pom:5": {
    "org.apache.maven:maven-parent:pom:10": {
    "org.apache.maven:maven-parent:pom:11": {
    "org.apache.maven:maven-parent:pom:15": {
    "org.apache.maven:maven-parent:pom:21": {
    "org.apache.maven:maven-parent:pom:22": {
    "org.apache.maven:maven-parent:pom:23": {
    "org.apache.maven:maven-parent:pom:25": {
    "org.apache.maven:maven-parent:pom:26": {
    "org.apache.maven:maven-parent:pom:27": {
    "org.apache.maven:maven-parent:pom:30": {
    "org.apache.maven:maven-parent:pom:31": {
    "org.apache.maven:maven-parent:pom:33": {
    "org.apache.maven:maven-parent:pom:34": {
```

this is getting boring.

how can i update all dependencies in mvn2nix-lock.json?

pkgs/development/tools/mvn2nix/src/mvn2nix/README.md

```
$ nix run -f https://github.com/fzakaria/mvn2nix/archive/master.tar.gz \
        --command mvn2nix > mvn2nix-lock.json
```

error: unrecognised flag '--command'

```
$ nix run github:fzakaria/mvn2nix#mvn2nix > mvn2nix-lock.json
Failed to execute goals [[package]]. Exit code: 1
```

ok, mvn2nix needs a java source repo

```
$ git clone  --depth=1 https://github.com/fzakaria/mvn2nix
$ cd mvn2nix
$ nix run github:fzakaria/mvn2nix#mvn2nix > mvn2nix-lock.json
$ grep org.apache.maven:maven-parent:pom:36 mvn2nix-lock.json | wc -l 
0
```

no, dependencies were not updated.

probably we need maven to update dependencies.

```
$ git clone  --depth=1 https://github.com/fzakaria/mvn2nix
$ cd mvn2nix
$ nix-shell -p maven
$ mvn --version 
Apache Maven 3.9.2 (c9616018c7a021c1c39be70fb2843d6f5f9b8a1c)
Maven home: /nix/store/wxxxnrmmk256kpf1jmrlgk3dp8g3g6dg-apache-maven-3.9.2/maven
Java version: 19.0.2, vendor: N/A, runtime: /nix/store/2gbq413gml7igp533v3397vbrzd24xyb-openjdk-19.0.2+7/lib/openjdk
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.1.35", arch: "amd64", family: "unix"
$ mvn dependency:resolve --update-snapshots --update-plugins
$ git diff | wc -l
0
$ mvn package --update-snapshots --update-plugins
$ git diff | wc -l
0
```

no, maven does not update dependencies.

so... back to nix. lets parse the output of nix-build,
to find missing dependencies, and then add them to mvn2nix-lock.json.

```
$ nix_build_output=$(nix-build . -A mvn2nix 2>&1)
$ echo "$nix_build_output" | grep "The following artifacts could not be resolved" | grep -v "^       > "
[ERROR] Plugin org.apache.maven.plugins:maven-resources-plugin:3.3.0 or one of its dependencies could not be resolved: Failed to read artifact descriptor for org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0: The following artifacts could not be resolved: org.apache.maven:maven-parent:pom:36 (absent): Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven:maven-parent:pom:36 has not been downloaded from it before. -> [Help 1]
$ dependency_key=$(echo "$nix_build_output" | grep "The following artifacts could not be resolved" | grep -v "^       > " | sed -E 's/^.* The following artifacts could not be resolved: ([^ ]+) .*$/\1/')
$ echo "$dependency_key"
org.apache.maven:maven-parent:pom:36
$ dependency_domain=$(echo "$dependency_key" | sed -E 's/^([^:]+):.*$/\1/')
$ echo "$dependency_domain"
org.apache.maven
$ dependency_name=$(echo "$dependency_key" | sed -E 's/^[^:]+:([^:]+):.*$/\1/')
$ echo "$dependency_name"
maven-parent
$ dependency_extension=$(echo "$dependency_key" | sed -E 's/^[^:]+:[^:]+:([^:]+):.*$/\1/')
$ echo "$dependency_extension"
pom
$ dependency_version=$(echo "$dependency_key" | sed -E 's/^.*:([^:]+)$/\1/')
$ echo "$dependency_version"
36
$ dependency_layout="$(echo "$dependency_domain" | tr . /)/$dependency_name/$dependency_version/$dependency_name-$dependency_version.$dependency_extension"
$ echo "$dependency_layout"
org/apache/maven/maven-parent/36/maven-parent-36.pom
$ dependency_url="https://repo.maven.apache.org/maven2/$dependency_layout"
$ echo "$dependency_url"
https://repo.maven.apache.org/maven2/org/apache/maven/maven-parent/36/maven-parent-36.pom
$ dependency_sha256=$(curl -s "$dependency_url" | sha256sum -)
$ dependency_sha256=${dependency_sha256:0:64}
$ echo "$dependency_sha256"
fcc3ab64c3cc80966d562a9aa604d8c280b3b7092441dd09e5290b081dfbedb5
$ cat >mvn2nix-lock.json.fragment <<EOF
{
  "dependencies": {
    "$dependency_key": {
      "layout": "$dependency_layout",
      "sha256": "$dependency_sha256",
      "url": "$dependency_url"
    }
  }
}
EOF
$ cat mvn2nix-lock.json.fragment
{
  "dependencies": {
    "org.apache.maven:maven-parent:pom:36": {
      "layout": "org/apache/maven/maven-parent/36/maven-parent-36.pom",
      "sha256": "fcc3ab64c3cc80966d562a9aa604d8c280b3b7092441dd09e5290b081dfbedb5",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/maven-parent/36/maven-parent-36.pom"
    } 
  } 
}
$ # using jq for recursive merge of json objects
$ # https://stackoverflow.com/questions/19529688/how-to-merge-2-json-objects-from-2-files-using-jq
$ # jq -s '.[0] * .[1]' file1 file2
$ lockfile_path="pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json"
$ backup_path="$lockfile_path".bak.$(date +%s.%N)
$ cp "$lockfile_path" "$backup_path"
$ jq -s '.[0] * .[1]' "$lockfile_path" mvn2nix-lock.json.fragment | sponge "$lockfile_path"
$ diff -u "$backup_path" "$lockfile_path"
--- pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json.bak.1691083620 2023-08-03 19:27:05.053180674 +0200
+++ pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json        2023-08-03 19:27:14.100268572 +0200
@@ -1984,6 +1984,11 @@
       "layout": "com/squareup/moshi/moshi/1.10.0/moshi-1.10.0.pom",
       "sha256": "0a3819835572dbccd53b89d77e73ceb6ac51f6bb7ae18f5e3ad0a45a4be53e7f",
       "url": "https://repo.maven.apache.org/maven2/com/squareup/moshi/moshi/1.10.0/moshi-1.10.0.pom"
+    },
+    "org.apache.maven:maven-parent:pom:36": {
+      "layout": "org/apache/maven/maven-parent/36/maven-parent-36.pom",
+      "sha256": "fcc3ab64c3cc80966d562a9aa604d8c280b3b7092441dd09e5290b081dfbedb5",
+      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/maven-parent/36/maven-parent-36.pom"
     }
   }
 }
```

ok, looking good. lets move the code to a script file:
pkgs/development/tools/mvn2nix/update.sh

after some iterations of updating dependencies, new build error:

```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources (default-resources) on project mvn2nix: Execution default-resources of goal org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources failed: Unable to load the mojo '\''resources'\'' (or one of its required components) from the plugin '\''org.apache.maven.plugins:maven-resources-plugin:3.3.0'\'': com.google.inject.ProvisionException: Unable to provision, see the following errors:
[ERROR] 
[ERROR] 1) No implementation for MavenResourcesFiltering was bound.
[ERROR]   while locating ResourcesMojo
[ERROR]   at ClassRealm[plugin>org.apache.maven.plugins:maven-resources-plugin:3.3.0, parent: ClassLoaders$AppClassLoader@7a4f0f29]
[ERROR]       \_ installed by: WireModule -> PlexusBindingModule
[ERROR]   while locating Mojo annotated with @Named("org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources")
```

full build log:

```
building
Using repository /nix/store/ylszh3r2lbv6qdz8n1x1xhbrdpbl4ayh-mvn2nix-repository
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.fzakaria:mvn2nix >------------------------
[INFO] Building mvn2nix 0.1
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- resources:3.3.0:resources (default-resources) @ mvn2nix ---
[WARNING] The POM for org.codehaus.plexus:plexus-interpolation:jar:1.26 is missing, no dependency information available
[WARNING] The POM for org.apache.maven.shared:maven-filtering:jar:3.3.0 is missing, no dependency information available
[WARNING] The POM for commons-io:commons-io:jar:2.11.0 is missing, no dependency information available
[WARNING] The POM for org.apache.commons:commons-lang3:jar:3.12.0 is missing, no dependency information available
[WARNING] Error injecting: org.apache.maven.plugins.resources.ResourcesMojo
com.google.inject.ProvisionException: Unable to provision, see the following errors:

1) No implementation for MavenResourcesFiltering was bound.
  while locating ResourcesMojo

1 error

======================
Full classname legend:
======================
MavenResourcesFiltering: "org.apache.maven.shared.filtering.MavenResourcesFiltering"
ResourcesMojo:           "org.apache.maven.plugins.resources.ResourcesMojo"
========================
End of classname legend:
========================

    at com.google.inject.internal.InternalProvisionException.toProvisionException (InternalProvisionException.java:251)
    at com.google.inject.internal.InjectorImpl$1.get (InjectorImpl.java:1104)
    at com.google.inject.internal.InjectorImpl.getInstance (InjectorImpl.java:1139)
    at org.eclipse.sisu.space.AbstractDeferredClass.get (AbstractDeferredClass.java:48)
    at com.google.inject.internal.ProviderInternalFactory.provision (ProviderInternalFactory.java:86)
    at com.google.inject.internal.InternalFactoryToInitializableAdapter.provision (InternalFactoryToInitializableAdapter.java:57)
    at com.google.inject.internal.ProviderInternalFactory$1.call (ProviderInternalFactory.java:67)
    at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision (ProvisionListenerStackCallback.java:109)
    at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision (ProvisionListenerStackCallback.java:124)
    at com.google.inject.internal.ProvisionListenerStackCallback.provision (ProvisionListenerStackCallback.java:66)
    at com.google.inject.internal.ProviderInternalFactory.circularGet (ProviderInternalFactory.java:62)
    at com.google.inject.internal.InternalFactoryToInitializableAdapter.get (InternalFactoryToInitializableAdapter.java:47)
    at com.google.inject.internal.InjectorImpl$1.get (InjectorImpl.java:1101)
    at org.eclipse.sisu.inject.Guice4$1.get (Guice4.java:162)
    at org.eclipse.sisu.inject.LazyBeanEntry.getValue (LazyBeanEntry.java:81)
    at org.eclipse.sisu.plexus.LazyPlexusBean.getValue (LazyPlexusBean.java:51)
    at org.codehaus.plexus.DefaultPlexusContainer.lookup (DefaultPlexusContainer.java:263)
    at org.codehaus.plexus.DefaultPlexusContainer.lookup (DefaultPlexusContainer.java:255)
    at org.apache.maven.plugin.internal.DefaultMavenPluginManager.getConfiguredMojo (DefaultMavenPluginManager.java:494)
    at org.apache.maven.plugin.DefaultBuildPluginManager.executeMojo (DefaultBuildPluginManager.java:114)
    at org.apache.maven.lifecycle.internal.MojoExecutor.doExecute2 (MojoExecutor.java:342)
    at org.apache.maven.lifecycle.internal.MojoExecutor.doExecute (MojoExecutor.java:330)
    at org.apache.maven.lifecycle.internal.MojoExecutor.execute (MojoExecutor.java:213)
    at org.apache.maven.lifecycle.internal.MojoExecutor.execute (MojoExecutor.java:175)
    at org.apache.maven.lifecycle.internal.MojoExecutor.access$000 (MojoExecutor.java:76)
    at org.apache.maven.lifecycle.internal.MojoExecutor$1.run (MojoExecutor.java:163)
    at org.apache.maven.plugin.DefaultMojosExecutionStrategy.execute (DefaultMojosExecutionStrategy.java:39)
    at org.apache.maven.lifecycle.internal.MojoExecutor.execute (MojoExecutor.java:160)
    at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject (LifecycleModuleBuilder.java:105)
    at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject (LifecycleModuleBuilder.java:73)
    at org.apache.maven.lifecycle.internal.builder.singlethreaded.SingleThreadedBuilder.build (SingleThreadedBuilder.java:53)
    at org.apache.maven.lifecycle.internal.LifecycleStarter.execute (LifecycleStarter.java:118)
    at org.apache.maven.DefaultMaven.doExecute (DefaultMaven.java:261)
    at org.apache.maven.DefaultMaven.doExecute (DefaultMaven.java:173)
    at org.apache.maven.DefaultMaven.execute (DefaultMaven.java:101)
    at org.apache.maven.cli.MavenCli.execute (MavenCli.java:910)
    at org.apache.maven.cli.MavenCli.doMain (MavenCli.java:283)
    at org.apache.maven.cli.MavenCli.main (MavenCli.java:206)
    at jdk.internal.reflect.DirectMethodHandleAccessor.invoke (DirectMethodHandleAccessor.java:104)
    at java.lang.reflect.Method.invoke (Method.java:578)
    at org.codehaus.plexus.classworlds.launcher.Launcher.launchEnhanced (Launcher.java:283)
    at org.codehaus.plexus.classworlds.launcher.Launcher.launch (Launcher.java:226)
    at org.codehaus.plexus.classworlds.launcher.Launcher.mainWithExitCode (Launcher.java:407)
    at org.codehaus.plexus.classworlds.launcher.Launcher.main (Launcher.java:348)
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  3.138 s
[INFO] Finished at: 2023-08-03T17:41:38Z
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources (default-resources) on project mvn2nix: Execution default-resources of goal org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources failed: Unable to load the mojo '\''resources'\'' (or one of its required components) from the plugin '\''org.apache.maven.plugins:maven-resources-plugin:3.3.0'\'': com.google.inject.ProvisionException: Unable to provision, see the following errors:
[ERROR] 
[ERROR] 1) No implementation for MavenResourcesFiltering was bound.
[ERROR]   while locating ResourcesMojo
[ERROR]   at ClassRealm[plugin>org.apache.maven.plugins:maven-resources-plugin:3.3.0, parent: ClassLoaders$AppClassLoader@7a4f0f29]
[ERROR]       \_ installed by: WireModule -> PlexusBindingModule
[ERROR]   while locating Mojo annotated with @Named("org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources")
[ERROR] 
[ERROR] 1 error
[ERROR] 
[ERROR] ======================
[ERROR] Full classname legend:
[ERROR] ======================
[ERROR] ClassLoaders$AppClassLoader: "jdk.internal.loader.ClassLoaders$AppClassLoader"
[ERROR] MavenResourcesFiltering:     "org.apache.maven.shared.filtering.MavenResourcesFiltering"
[ERROR] Mojo:                        "org.apache.maven.plugin.Mojo"
[ERROR] Named:                       "com.google.inject.name.Named"
[ERROR] PlexusBindingModule:         "org.eclipse.sisu.plexus.PlexusBindingModule"
[ERROR] ResourcesMojo:               "org.apache.maven.plugins.resources.ResourcesMojo"
[ERROR] WireModule:                  "org.eclipse.sisu.wire.WireModule"
[ERROR] ========================
[ERROR] End of classname legend:
[ERROR] ========================
[ERROR] 
[ERROR]       role: org.apache.maven.plugin.Mojo
[ERROR]   roleHint: org.apache.maven.plugins:maven-resources-plugin:3.3.0:resources
[ERROR] -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/PluginContainerException

error: builder for '\''/nix/store/p1b6g8wfdd1rxfx646c3s76h9w7ii231-mvn2nix-0.1.drv'\'' failed with exit code 1;
```

parse warnings?

```
[WARNING] The POM for org.codehaus.plexus:plexus-interpolation:jar:1.26 is missing, no dependency information available
[WARNING] The POM for org.apache.maven.shared:maven-filtering:jar:3.3.0 is missing, no dependency information available
[WARNING] The POM for commons-io:commons-io:jar:2.11.0 is missing, no dependency information available
[WARNING] The POM for org.apache.commons:commons-lang3:jar:3.12.0 is missing, no dependency information available
[WARNING] Error injecting: org.apache.maven.plugins.resources.ResourcesMojo
```

```
    "org.apache.maven.plugins:maven-plugins:pom:36": {
      "layout": "org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom",
      "sha256": "b0020d55af2afd9bff042d627dd52b7a4828243014ded0ae89412e1717582056",
      "url": "https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/36/maven-plugins-36.pom"
    },
```

> Error injecting: org.apache.maven.plugins.resources.ResourcesMojo

https://github.com/smooks/smooks/issues/155

> Enforcing version 2.7 of the Maven Resources plugin gets the build to go past the Milyn :: Commons module.

https://github.com/smooks/smooks/commit/e287b3f5d2b9aead3d978eedd58e8b905117447c

```
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-resources-plugin</artifactId>
                    <version>2.7</version>
                </plugin>
```

the original lockfile has `org.apache.maven.plugins:maven-resources-plugin:jar:2.6`

```
$ grep org.apache.maven.plugins:maven-resources-plugin pkgs/development/tools/mvn2nix/src/mvn2nix/mvn2nix-lock.json
    "org.apache.maven.plugins:maven-resources-plugin:jar:2.6": {
    "org.apache.maven.plugins:maven-resources-plugin:pom:2.6": {
```

patch for pom.xml:

```
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-resources-plugin</artifactId>
                <version>2.6</version>
            </plugin>
```

&rarr; success! now the build works with the original lockfile:

```
$ nix-build . -A mvn2nix
this derivation will be built:
  /nix/store/778ajpgp36hfmk1wbyndhyaw850ssnd0-mvn2nix-0.1.drv
building '/nix/store/778ajpgp36hfmk1wbyndhyaw850ssnd0-mvn2nix-0.1.drv'...
unpacking sources
unpacking source archive /nix/store/1k1g62560qgjqd36949l092r3psdbbwl-mvn2nix
source root is mvn2nix
patching sources
configuring
no configure script, doing nothing
building
Using repository /nix/store/yv6xxhagkclpsz13ivb1rgx717pdmxrf-mvn2nix-repository
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.fzakaria:mvn2nix >------------------------
[INFO] Building mvn2nix 0.1
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- resources:2.6:resources (default-resources) @ mvn2nix ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 1 resource
[INFO] 
[INFO] --- compiler:3.8.1:compile (default-compile) @ mvn2nix ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 11 source files to /build/mvn2nix/target/classes
[INFO] 
[INFO] --- resources:2.6:testResources (default-testResources) @ mvn2nix ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 2 resources
[INFO] 
[INFO] --- compiler:3.8.1:testCompile (default-testCompile) @ mvn2nix ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 2 source files to /build/mvn2nix/target/test-classes
[INFO] 
[INFO] --- surefire:3.0.0-M5:test (default-test) @ mvn2nix ---
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.fzakaria.mvn2nix.maven.ArtifactTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.482 s - in com.fzakaria.mvn2nix.maven.ArtifactTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] 
[INFO] --- jar:3.2.0:jar (default-jar) @ mvn2nix ---
[INFO] Building jar: /build/mvn2nix/target/mvn2nix-0.1.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  19.778 s
[INFO] Finished at: 2023-08-03T18:27:22Z
[INFO] ------------------------------------------------------------------------
[WARNING] 
[WARNING] Plugin validation issues were detected in 4 plugin(s)
[WARNING] 
[WARNING]  * org.apache.maven.plugins:maven-jar-plugin:3.2.0
[WARNING]  * org.apache.maven.plugins:maven-compiler-plugin:3.8.1
[WARNING]  * org.apache.maven.plugins:maven-resources-plugin:2.6
[WARNING]  * org.apache.maven.plugins:maven-surefire-plugin:3.0.0-M5
[WARNING] 
[WARNING] For more or less details, use 'maven.plugin.validation' property with one of the values (case insensitive): [BRIEF, DEFAULT, VERBOSE]
[WARNING] 
@nix { "action": "setPhase", "phase": "installPhase" }
installing
post-installation fixup
shrinking RPATHs of ELF executables and libraries in /nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1
checking for references to /build/ in /nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1...
patching script interpreter paths in /nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1
stripping (with command strip and flags -S -p) in  /nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1/lib /nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1/bin
/nix/store/568a3rgilj02mpl6bm8nyw3bhkn3lw69-mvn2nix-0.1
```

### new issue

https://github.com/fzakaria/mvn2nix/issues/new

```
update nixpkgs and mvn2nix-lock.json

mvn2nix fails to build, when i replace the pinned nixpkgs with a recent version of nixpkgs
```

&rarr; no. out of scope for mvn2nix, limitation of nixpkgs?

but still, it would be interesting, why exactly the build fails with a newer nixpkgs
