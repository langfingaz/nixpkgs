{
  lib,
  stdenv,
  fetchpatch,
  fetchurl,
  updateAutotoolsGnuConfigScriptsHook,
  ncurses,
  termcap,
  curses-library ? if stdenv.hostPlatform.isWindows then termcap else ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "readline";
  version = "8.3p${toString (builtins.length finalAttrs.upstreamPatches)}";

  src = fetchurl {
    url = "mirror://gnu/readline/readline-${finalAttrs.meta.branch}.tar.gz";
    hash = "sha256-/lODIERngozUle6NHTwDen66E4nCK8agQfYnl2+QYcw=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
    "info"
  ];

  strictDeps = true;
  propagatedBuildInputs = [ curses-library ];
  nativeBuildInputs = [ updateAutotoolsGnuConfigScriptsHook ];

  patchFlags = [ "-p0" ];

  upstreamPatches = (
    let
      patch =
        nr: sha256:
        fetchurl {
          url = "mirror://gnu/readline/readline-${finalAttrs.meta.branch}-patches/readline83-${nr}";
          inherit sha256;
        };
    in
    import ./readline-8.3-patches.nix patch
  );

  patches =
    lib.optionals (curses-library.pname == "ncurses") [
      ./link-against-ncurses.patch
    ]
    ++ [
      ./no-arch_only-8.2.patch
    ]
    ++ finalAttrs.upstreamPatches
    ++ lib.optionals stdenv.hostPlatform.isWindows [
      (fetchpatch {
        name = "0001-sigwinch.patch";
        url = "https://github.com/msys2/MINGW-packages/raw/90e7536e3b9c3af55c336d929cfcc32468b2f135/mingw-w64-readline/0001-sigwinch.patch";
        stripLen = 1;
        hash = "sha256-sFK6EJrSNl0KLWqFv5zBXaQRuiQoYIZVoZfa8BZqfKA=";
      })
      (fetchpatch {
        name = "0002-event-hook.patch";
        url = "https://github.com/msys2/MINGW-packages/raw/3476319d2751a676b911f3de9e1ec675081c03b8/mingw-w64-readline/0002-event-hook.patch";
        stripLen = 1;
        hash = "sha256-F8ytYuIjBtH83ZCJdf622qjwSw+wZEVyu53E/mPsoAo=";
      })
      (fetchpatch {
        name = "0003-fd_set.patch";
        url = "https://github.com/msys2/MINGW-packages/raw/35830ab27e5ed35c2a8d486961ab607109f5af50/mingw-w64-readline/0003-fd_set.patch";
        stripLen = 1;
        hash = "sha256-UiaXZRPjKecpSaflBMCphI2kqOlcz1JkymlCrtpMng4=";
      })
      (fetchpatch {
        name = "0004-locale.patch";
        url = "https://github.com/msys2/MINGW-packages/raw/f768c4b74708bb397a77e3374cc1e9e6ef647f20/mingw-w64-readline/0004-locale.patch";
        stripLen = 1;
        hash = "sha256-dk4343KP4EWXdRRCs8GRQlBgJFgu1rd79RfjwFD/nJc=";
      })
    ];

  # Make mingw-w64 provide a dummy alarm() function
  #
  # Method borrowed from
  # https://github.com/msys2/MINGW-packages/commit/35830ab27e5ed35c2a8d486961ab607109f5af50
  CFLAGS = lib.optionalString stdenv.hostPlatform.isMinGW "-D__USE_MINGW_ALARM -D_POSIX";

  # This install error is caused by a very old libtool. We can't autoreconfHook this package,
  # so this is the best we've got!
  postInstall = lib.optionalString stdenv.hostPlatform.isOpenBSD ''
    ln -s $out/lib/libhistory.so* $out/lib/libhistory.so
    ln -s $out/lib/libreadline.so* $out/lib/libreadline.so
  '';

  meta = with lib; {
    description = "Library for interactive line editing";

    longDescription = ''
      The GNU Readline library provides a set of functions for use by
      applications that allow users to edit command lines as they are
      typed in.  Both Emacs and vi editing modes are available.  The
      Readline library includes additional functions to maintain a
      list of previously-entered command lines, to recall and perhaps
      reedit those lines, and perform csh-like history expansion on
      previous commands.

      The history facilities are also placed into a separate library,
      the History library, as part of the build process.  The History
      library may be used without Readline in applications which
      desire its capabilities.
    '';

    homepage = "https://savannah.gnu.org/projects/readline/";

    license = licenses.gpl3Plus;

    maintainers = with maintainers; [ dtzWill ];

    platforms = platforms.unix ++ platforms.windows;
    branch = "8.3";
  };
})
