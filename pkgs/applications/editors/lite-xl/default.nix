{ agg
, fetchFromGitHub
, Foundation
, freetype
, lib
, lua5_4
, meson
, ninja
, pcre2
, pkg-config
, reproc
, SDL2
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "lite-xl";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "lite-xl";
    repo = "lite-xl";
    rev = "v${version}";
    sha256 = "sha256-9nQFdii6SY14Cul7Ki0DUEsu75HWTCeEZtXaU6KGRiM=";
  };

  nativeBuildInputs = [ meson ninja pkg-config ];

  buildInputs = [
    agg
    freetype
    lua5_4
    pcre2
    reproc
    SDL2
  ] ++ lib.optionals stdenv.isDarwin [
    Foundation
  ];

  meta = with lib; {
    description = "A lightweight text editor written in Lua";
    homepage = "https://github.com/lite-xl/lite-xl";
    license = licenses.mit;
    maintainers = with maintainers; [ boppyt ];
    platforms = platforms.unix;
  };
}
