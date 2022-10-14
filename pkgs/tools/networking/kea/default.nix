{ stdenv
, lib
, fetchurl

# build time
, autoreconfHook
, pkg-config

# runtime
, boost
, libmysqlclient
, log4cplus
, openssl
, postgresql
, python3

# tests
, nixosTests
}:

stdenv.mkDerivation rec {
  pname = "kea";
  version = "2.2.0"; # only even minor versions are stable

  src = fetchurl {
    url = "https://ftp.isc.org/isc/${pname}/${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-2n2QymKncmAtrG535QcxkDhCKJWtaO6xQvFIfWfVMdI=";
  };

  patches = [
    ./dont-create-var.patch
  ];

  postPatch = ''
    substituteInPlace ./src/bin/keactrl/Makefile.am --replace '@sysconfdir@' "$out/etc"
  '';

  outputs = [
    "out"
    "doc"
    "man"
  ];

  configureFlags = [
    "--enable-perfdhcp"
    "--enable-shell"
    "--localstatedir=/var"
    "--with-openssl=${lib.getDev openssl}"
    "--with-mysql=${lib.getDev libmysqlclient}/bin/mysql_config"
    "--with-pgsql=${postgresql}/bin/pg_config"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ] ++ (with python3.pkgs; [
    sphinxHook
    sphinx-rtd-theme
  ]);

  sphinxBuilders = [
    "html"
    "man"
  ];
  sphinxRoot = "doc/sphinx";

  buildInputs = [
    boost
    libmysqlclient
    log4cplus
    openssl
    python3
  ];

  enableParallelBuilding = true;

  passthru.tests = {
    kea = nixosTests.kea;
    prefix-delegation = nixosTests.systemd-networkd-ipv6-prefix-delegation;
    prometheus-exporter = nixosTests.prometheus-exporters.kea;
  };

  meta = with lib; {
    homepage = "https://kea.isc.org/";
    description = "High-performance, extensible DHCP server by ISC";
    longDescription = ''
      Kea is a new open source DHCPv4/DHCPv6 server being developed by
      Internet Systems Consortium. The objective of this project is to
      provide a very high-performance, extensible DHCP server engine for
      use by enterprises and service providers, either as is or with
      extensions and modifications.
    '';
    license = licenses.mpl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ fpletz hexa ];
  };
}
