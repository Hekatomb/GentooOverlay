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

IUSE="automount sudo"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
        dev-build/automake
        dev-build/autoconf
        dev-build/libtool
        sys-devel/gettext
        virtual/pkgconfig
        $(python_gen_cond_dep '
                dev-python/setuptools[${PYTHON_USEDEP}]
                dev-python/wheel[${PYTHON_USEDEP}]
                dev-python/installer[${PYTHON_USEDEP}]
        ')
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
        net-misc/curl[kerberos]
        sys-auth/certmonger
        app-admin/augeas
        app-crypt/gnupg
        dev-libs/nss
        net-dns/bind[gssapi]
        net-nds/openldap
        sys-auth/pambase[sssd]
        sys-auth/sssd[python,${PYTHON_SINGLE_USEDEP}]
        sys-apps/dbus
        sys-apps/keyutils
        automount? ( net-fs/autofs )
        sudo? ( app-admin/sudo[sssd] )
        $(python_gen_cond_dep '
                dev-python/gssapi[${PYTHON_USEDEP}]
                dev-python/ifaddr[${PYTHON_USEDEP}]
                dev-python/netaddr[${PYTHON_USEDEP}]
                dev-python/python-augeas[${PYTHON_USEDEP}]
                dev-python/python-ldap[sasl,${PYTHON_USEDEP}]
                dev-python/pyasn1[${PYTHON_USEDEP}]
                dev-python/pyasn1-modules[${PYTHON_USEDEP}]
                dev-python/qrcode[${PYTHON_USEDEP}]
        ')
"

PATCHES=(
    "${FILESDIR}/freeipa-4.13.4-gentoo-platform.patch"
    "${FILESDIR}/freeipa-4.13.4-gentoo-nss.patch"
    "${FILESDIR}/freeipa-4.13.4-sysrestore-reload.patch"
    "${FILESDIR}/freeipa-4.13.4-no-wheel-ipa-script.patch"
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

src_compile() {
        default

        local pkg
        for pkg in ipapython ipaplatform ipalib ipaclient; do
                emake -C "${pkg}" bdist_wheel || die "Building ${pkg} wheel failed"
        done
}

src_install() {
        emake DESTDIR="${D}" PYTHON_INSTALL_EXTRA_OPTIONS="" pkginstall=false install

        local pkg wheel
        for pkg in ipapython ipaplatform ipalib ipaclient; do
                local wheels=( "${S}/dist/wheels/${pkg}-${PV}-"*.whl )
                [[ ${#wheels[@]} -eq 1 && -f ${wheels[0]} ]] || die "Expected exactly one wheel for ${pkg}"
                "${PYTHON}" -m installer --destdir="${D}" "${wheels[0]}" || die "Installing ${pkg} wheel failed"
        done

        insinto /etc/sysconfig
        newins /dev/null nfs

        keepdir /var/lib/ipa-client/pki
        keepdir /var/lib/ipa-client/sysrestore
        python_optimize
        einstalldocs
}

pkg_postinst() {
        elog "For automatic home directory creation, ensure /etc/pam.d/system-auth contains:"
        elog
        elog "session required pam_mkhomedir.so skel=/etc/skel umask=0022"
}

