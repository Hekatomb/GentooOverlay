EAPI=8

inherit autotools tmpfiles

DESCRIPTION="Certificate status monitor and PKI enrollment client"
HOMEPAGE="https://pagure.io/certmonger/"
RESTRICT="mirror"
SRC_URI="https://deb.debian.org/debian/pool/main/c/certmonger/certmonger_${PV}.orig.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	dev-build/autoconf
	dev-build/automake
	dev-build/libtool
	sys-devel/gettext
	virtual/pkgconfig
"

DEPEND="
	app-crypt/mit-krb5
	dev-libs/jansson
	dev-libs/libxml2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl
	dev-libs/popt
	net-dns/libidn2
	net-misc/curl
	net-nds/openldap
	sys-apps/dbus
	sys-apps/systemd
	sys-apps/util-linux
	sys-libs/talloc
	sys-libs/tevent
"

RDEPEND="
	${DEPEND}
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-systemd
		--enable-tmpfiles
		--with-homedir=/run/certmonger
		--with-tmpdir=/run/certmonger
		--localstatedir=/var
		--disable-dsa
		--enable-pie
		--enable-now
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	keepdir /var/lib/certmonger/cas
	keepdir /var/lib/certmonger/local
	keepdir /var/lib/certmonger/requests

	einstalldocs
}

pkg_postinst() {
	tmpfiles_process certmonger.conf
}
