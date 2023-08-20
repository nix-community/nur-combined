# superseded by https://github.com/mediawiki-client-tools/mediawiki-scraper

{ lib
, buildPythonApplication
, fetchFromGitHub
, internetarchive
, kitchen
, mwclient
, requests
, lxml
, python311
, python3
, pkgs
, poetry-core
}:

buildPythonApplication rec {
  pname = "mediawiki-scraper";
  # version 3.0.0 in https://github.com/mediawiki-client-tools/mediawiki-scraper
  baseVersion = "2.0.0";
  version = "${baseVersion}-unstable-2023-06-20";
  src = fetchFromGitHub {
    owner = "WikiTeam";
    repo = "wikiteam";
    rev = "54d9d8051e6159bf6161476c76a9f0665ee7a529";
    sha256 = "sha256-jTv1rOCd+TCJCgS0Xg+F6USVicaQab6vsTLIyl11xDE=";
  };

  format = "pyproject";

  # based on https://github.com/mediawiki-client-tools/mediawiki-scraper/blob/python3/pyproject.toml
  # wikiteam3 -> wikiteam
  pyproject-toml = ''
    [tool.poetry]
    name = "wikiteam"
    version = "${baseVersion}"
    description = "Tools for downloading and preserving wikis"
    license = "GPL-3.0-or-later"
    authors = ["WikiTeam Contributors <https://github.com/WikiTeam/wikiteam/graphs/contributors>"]
    maintainers = [
        "Federico Leva <https://github.com/nemobis>",
        "Elsie Hupp <https://github.com/elsiehupp>"
    ]
    readme = "README.md"
    homepage = "https://wiki.archiveteam.org/index.php/WikiTeam"
    repository = "https://github.com/WikiTeam/wikiteam"
    documentation = "https://wikiteam.readthedocs.io"
    keywords = [
        "archiveteam",
        "mediawiki",
        "preservation",
        "wiki",
        "wikipedia"
    ]
    classifiers = [
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Intended Audience :: Education",
        "Intended Audience :: End Users/Desktop",
        "Intended Audience :: Information Technology",
        "Intended Audience :: Legal Industry",
        "Intended Audience :: Science/Research",
        "Intended Audience :: System Administrators",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Topic :: Communications",
        "Topic :: Internet",
        "Topic :: Internet :: WWW/HTTP :: Dynamic Content :: Wiki",
        "Topic :: Scientific/Engineering :: Information Analysis",
        "Topic :: Sociology :: History",
        "Topic :: System :: Archiving",
        "Topic :: System :: Archiving :: Backup",
        "Topic :: Utilities"
    ]
    packages = [
        { include = "wikiteam/**/*"},
    ]

    [tool.poetry.scripts]
    dumpgenerator = "wikiteam.dumpgenerator:main"
    # gui = "wikiteam.gui:main"
    launcher = "wikiteam.launcher:main"
    # not-archived = "wikiteam.not-archived:main"
    uploader = "wikiteam.uploader:main"
    # wikiadownloader = "wikiteam.wikiadownloader:main"
    # wikipediadownloader = "wikiteam.wikipediadownloader:main"
    # wikispaces = "wikiteam.wikispaces:main"

    [tool.poetry.dependencies]
    #argparse = "*"
    internetarchive = "*"
    kitchen = "*"
    mwclient = "*"
    requests = "*"
    lxml = "*"

    [build-system]
    requires = ["poetry-core>=1.0.0"]
    build-backend = "poetry.core.masonry.api"
  '';

  /*
  # these scripts are also installed by https://github.com/mediawiki-client-tools/mediawiki-scraper
  setup-py = ''
    from setuptools import setup, find_packages
    setup(
      name='mediawiki-scraper',
        version='${baseVersion}',
        packages=find_packages(),
        scripts=[
          "dumpgenerator.py",
          "launcher.py",
          "uploader.py",
        ],
    )
  '';
  */

  # based on https://github.com/WikiTeam/wikiteam/pull/331
  #  echo ${lib.escapeShellArg setup-py} >setup.py
  postPatch = ''
    echo ${lib.escapeShellArg pyproject-toml} >pyproject.toml

    ${python311}/bin/2to3 -w -n --no-diffs .
    substituteInPlace dumpgenerator.py \
      --replace " is not '\n'" " != '\n'" \
      --replace " is not ${"''"}" " != ${"''"}" \
      --replace "UTF8Writer = getwriter('utf8')" "" \
      --replace "sys.stdout = UTF8Writer(sys.stdout)" "" \
      --replace ", 'w')" ", 'wb')" \
      --replace ", 'wt')" ", 'wb')" \
      --replace ", 'a')" ", 'ab')" \
      --replace ", 'at')" ", 'ab')" \
      --replace ", 'r')" ", 'rb')" \
      --replace ", 'rt')" ", 'rb')" \
      --replace "imagesfile.write('" "imagesfile.write(b'" \
      --replace "outfile.write(json.dumps(result, indent=4, sort_keys=True))" "outfile.write(json.dumps(result, indent=4, sort_keys=True).encode('utf-8'))" \
      --replace "titlesfile.write(title.encode('utf-8') + \"\n\")" "titlesfile.write(title.encode('utf-8') + b\"\n\")" \
      --replace "titlesfile.write(u'" "titlesfile.write(b'" \
      --replace "titlesfile.write('" "titlesfile.write(b'" \
      --replace "xmlfile.write(footer)" "xmlfile.write(footer.encode('utf-8'))" \
      --replace \
        "filename = str(urllib.parse.unquote((re.sub('_', ' ', url.split('/')[-3])).encode('ascii', 'ignore')), 'utf-8')" \
        "filename = re.sub(u'_', u' ', url.split('/')[-3])" \
      --replace \
        "filename = str(urllib.parse.unquote((re.sub('_', ' ', url.split('/')[-1])).encode('ascii', 'ignore')), 'utf-8')" \
        "filename = re.sub(u'_', u' ', url.split('/')[-1])" \

    mv *.py wikiteam
  '';

  # fix: ./result/bin/launcher: ModuleNotFoundError: No module named 'dumpgenerator'
  # fix: error: attribute 'sitePackages' missing: python3.sitePackages
  #    substituteInPlace "$f" --replace "], site._init_pathinfo());" ",'$out/${python3.sitePackages}/wikiteam'], site._init_pathinfo());"
  postFixup = ''
    # fix import path
    cd $out/bin
    for f in .*-wrapped; do
      substituteInPlace "$f" --replace "], site._init_pathinfo());" ",'$out/${pkgs.python3.sitePackages}/wikiteam'], site._init_pathinfo());"
    done
  '';

  doCheck = false;

  buildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    internetarchive
    kitchen
    mwclient
    requests
    lxml
  ];

  meta = with lib; {
    homepage = "https://github.com/WikiTeam/wikiteam";
    description = "Tools for downloading and preserving wikis";
    maintainers = [ ];
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
