{
  lib,
  buildPythonPackage,
  et-xmlfile,
  fetchFromGitLab,
  lxml,
  pandas,
  pillow,
  pytest7CheckHook,
  pythonAtLeast,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "openpyxl";
  version = "3.1.5";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitLab {
    domain = "foss.heptapod.net";
    owner = "openpyxl";
    repo = "openpyxl";
    rev = "refs/tags/${version}";
    hash = "sha256-vp+TIWcHCAWlDaBcmC7w/kV7DZTZpa6463NusaJmqKo=";
  };

  build-system = [ setuptools ];

  dependencies = [ et-xmlfile ];

  nativeCheckInputs = [
    lxml
    pandas
    pillow
    pytest7CheckHook
  ];

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  disabledTests = [
    # Tests broken since lxml 2.12; https://foss.heptapod.net/openpyxl/openpyxl/-/issues/2116
    "test_read"
    "test_read_comments"
    "test_ignore_external_blip"
    "test_from_xml"
    "test_filenames"
    "test_exts"
    "test_from_complex"
    "test_merge_named_styles"
    "test_unprotected_cell"
    "test_none_values"
    "test_rgb_colors"
    "test_named_styles"
    "test_read_ole_link"
  ]
  ++ lib.optionals (pythonAtLeast "3.11") [
    "test_broken_sheet_ref"
    "test_name_invalid_index"
    "test_defined_names_print_area"
    "test_no_styles"
  ];

  pythonImportsCheck = [ "openpyxl" ];

  meta = with lib; {
    description = "Python library to read/write Excel 2010 xlsx/xlsm files";
    homepage = "https://openpyxl.readthedocs.org";
    changelog = "https://foss.heptapod.net/openpyxl/openpyxl/-/blob/${version}/doc/changes.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ lihop ];
  };
}
