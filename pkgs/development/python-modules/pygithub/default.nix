{
  lib,
  buildPythonPackage,
  deprecated,
  fetchFromGitHub,
  pynacl,
  typing-extensions,
  pyjwt,
  pythonOlder,
  requests,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pygithub";
  version = "2.6.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "PyGithub";
    repo = "PyGithub";
    tag = "v${version}";
    hash = "sha256-CfAgN5vxHbVyDSeP0KR1QFnL6gDQsd46Q0zosr0ALqM=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    deprecated
    pyjwt
    pynacl
    requests
    typing-extensions
    urllib3
  ]
  ++ pyjwt.optional-dependencies.crypto;

  # Test suite makes REST calls against github.com
  doCheck = false;

  pythonImportsCheck = [ "github" ];

  meta = with lib; {
    description = "Python library to access the GitHub API v3";
    homepage = "https://github.com/PyGithub/PyGithub";
    changelog = "https://github.com/PyGithub/PyGithub/raw/${src.tag}/doc/changes.rst";
    license = licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
