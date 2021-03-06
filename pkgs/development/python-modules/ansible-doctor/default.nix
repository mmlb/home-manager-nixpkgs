{ lib
, anyconfig
, appdirs
, buildPythonPackage
, colorama
, environs
, fetchFromGitHub
, jinja2
, jsonschema
, nested-lookup
, pathspec
, poetry-core
, python-json-logger
, pythonOlder
, ruamel-yaml
}:

buildPythonPackage rec {
  pname = "ansible-doctor";
  version = "1.4.0";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "thegeeklab";
    repo = "ansible-doctor";
    rev = "v${version}";
    hash = "sha256-onRur31Sa95nsXUYFJdAHySm4nIXqP01nT70IFPwLCo=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    anyconfig
    appdirs
    colorama
    environs
    jinja2
    jsonschema
    nested-lookup
    pathspec
    python-json-logger
    ruamel-yaml
  ];

  postInstall = ''
    rm $out/lib/python*/site-packages/LICENSE
  '';

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'version = "0.0.0"' 'version = "${version}"' \
      --replace 'Jinja2 = "3.1.2"' 'Jinja2 = "*"' \
      --replace 'anyconfig = "0.13.0"' 'anyconfig = "*"' \
      --replace 'environs = "9.5.0"' 'environs = "*"' \
      --replace 'jsonschema = "4.6.0"' 'jsonschema = "*"' \
      --replace '"ruamel.yaml" = "0.17.21"' '"ruamel.yaml" = "*"'
  '';

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [
    "ansibledoctor"
  ];

  meta = with lib; {
    description = "Annotation based documentation for your Ansible roles";
    homepage = "https://github.com/thegeeklab/ansible-doctor";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ tboerger ];
  };
}
