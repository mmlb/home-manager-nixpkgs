{ lib
, buildPythonPackage
, fetchPypi
, pytestCheckHook
, google-api-core
, libcst
, mock
, protobuf
, proto-plus
, pytest-asyncio
, pythonOlder
}:

buildPythonPackage rec {
  pname = "google-cloud-websecurityscanner";
  version = "1.9.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-T+a154A4EakPGk7OL65mweveLBEL1ol3ZYYh2MTyxy8=";
  };

  propagatedBuildInputs = [
    google-api-core
    libcst
    protobuf
    proto-plus
  ];

  checkInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "google.cloud.websecurityscanner_v1alpha"
    "google.cloud.websecurityscanner_v1beta"
  ];

  meta = with lib; {
    description = "Google Cloud Web Security Scanner API client library";
    homepage = "https://github.com/googleapis/python-websecurityscanner";
    license = licenses.asl20;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
