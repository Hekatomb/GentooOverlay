# sys-auth/freeipa-client/freeipa-client-4.13.4.ebuild

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit autotools python-single-r1

DESCRIPTION="FreeIPA client tools"
HOMEPAGE="https://www.freeipa.org/"
RESTRICT="mirror"
SRC_URI="https://codeberg.org/freeipa/freeipa/releases/download/release-${PV//./-}/freeipa-${PV}.tar.gz"

S="${WORKDIR}/freeipa-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="sudo"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	dev-build/automake
	dev-build/autoconf
	dev-build/libtool
	sys-devel/gettext
	virtual/pkgconfig
"

DEPEND="
	app-crypt/mit-krb5
	dev-libs/cyrus-sasl
	dev-libs/jansson
	dev-libs/libpcre2
	dev-libs/popt
	net-nds/openldap
	net-misc/curl
	sys-apps/systemd
"

RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
	app-admin/augeas
	app-crypt/gnupg
	dev-libs/nss
	net-dns/bind[gssapi]
	net-nds/openldap
	sys-auth/pambase[sssd]
	sys-auth/sssd[python,${PYTHON_SINGLE_USEDEP}]
	sys-apps/dbus
	sys-apps/keyutils
	sudo? ( app-admin/sudo[sssd] )
	$(python_gen_cond_dep '
		dev-python/gssapi[${PYTHON_USEDEP}]
		dev-python/ifaddr[${PYTHON_USEDEP}]
		dev-python/python-augeas[${PYTHON_USEDEP}]
		dev-python/python-ldap[${PYTHON_USEDEP}]
		dev-python/pyasn1[${PYTHON_USEDEP}]
		dev-python/pyasn1-modules[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/freeipa-4.13.4-gentoo-platform.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-server
		--with-ipaplatform=gentoo
		--localstatedir=/var
		--without-ipatests
		--without-jslint
		--disable-pylint
		--disable-rpmlint
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" PYTHON_INSTALL_EXTRA_OPTIONS="" install
	python_optimize
	einstalldocs
}

pkg_postinst() {
	elog "For automatic home directory creation, ensure /etc/pam.d/system-auth contains:"
	elog
	elog "session required pam_mkhomedir.so skel=/etc/skel umask=0022"
}
