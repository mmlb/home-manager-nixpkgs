{ lib
, buildPythonPackage
, click
, fetchFromGitHub
, poetry-core
, pytestCheckHook
, pythonOlder
, toml
}:

buildPythonPackage rec {
  pname = "toml-adapt";
  version = "0.2.8";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "firefly-cpp";
    repo = pname;
    rev = version;
    sha256 = "sha256-9auZZl6c+EfAO/2QaHW5BI1aDZkIIGU+fwzudIdFWqI=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    click
    toml
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "toml_adapt"
  ];

  meta = with lib; {
    description = "A simple Command-line interface for manipulating toml files";
    homepage = "https://github.com/firefly-cpp/toml-adapt";
    license = licenses.mit;
    maintainers = with maintainers; [ firefly-cpp ];
  };
}
