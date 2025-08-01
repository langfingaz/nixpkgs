{
  lib,
  stdenv,
  bash,
  fetchFromGitHub,
  gtk3,
  pkg-config,
  intltool,
  libxslt,
  makeWrapper,
  coreutils,
  zip,
  unzip,
  p7zip,
  unar,
  gnutar,
  bzip2,
  gzip,
  lhasa,
  wrapGAppsHook3,
  desktopToDarwinBundle,
}:

stdenv.mkDerivation rec {
  version = "0.5.4.25";
  pname = "xarchiver";

  src = fetchFromGitHub {
    owner = "ib";
    repo = "xarchiver";
    rev = version;
    hash = "sha256-pLNAgyYqujk+xvHZjq98kzTG47G4C2JvSTDoS7UTNeo=";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    makeWrapper
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    gtk3
    bash # so patchShebangs can patch #!/bin/sh in xarchiver.tap
  ];

  postFixup = ''
    wrapProgram $out/bin/xarchiver \
    --prefix PATH : ${
      lib.makeBinPath [
        zip
        unzip
        p7zip
        unar
        gnutar
        bzip2
        gzip
        lhasa
        coreutils
      ]
    }
  '';

  strictDeps = true;

  meta = {
    description = "GTK frontend to 7z,zip,rar,tar,bzip2, gzip,arj, lha, rpm and deb (open and extract only)";
    homepage = "https://github.com/ib/xarchiver";
    maintainers = [ ];
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    mainProgram = "xarchiver";
  };
}
