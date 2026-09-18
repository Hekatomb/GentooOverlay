# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Adapted by Hekatombe

EAPI=8

inherit autotools udev

DESCRIPTION="Qualcomm FastRPC userspace library and daemons"
HOMEPAGE="https://github.com/qualcomm/fastrpc"
SRC_URI="https://github.com/qualcomm/fastrpc/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/fastrpc-${PV}"

KEYWORDS="arm64"

LICENSE="BSD"
SLOT="0"
RESTRICT="mirror"

RDEPEND="
	acct-group/fastrpc
	dev-libs/libbsd
	dev-libs/libyaml
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--with-systemdsystemunitdir=/usr/lib/systemd/system \
		--with-udevrulesdir=/usr/lib/udev/rules.d \
		--with-sysusersdir=/usr/lib/sysusers.d
}

src_install() {
	local DOCS=( README.md LICENSE.txt Docs/*.md )

	default

	rm -r "${ED}/usr/share/fastrpc_test" || die
	rm -f "${ED}/usr/bin/fastrpc_test" || die
	rm -r "${ED}/usr/$(get_libdir)/fastrpc_test" || die
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	udev_reload

        elog "Remember to configure ADSP_LIBRARY_PATH for adsprpcd_audiopd.service."
        elog "  /etc/systemd/system/adsprpcd_audiopd.service.d/override.conf"
        elog ""
        elog "  [Service]"
        elog "  Environment=ADSP_LIBRARY_PATH=/lib/firmware/updates/qcom/glymur/ASUSTeK/<MODEL>/ADSP"
        elog ""
        elog "Followed by: systemctl daemon-reload"

}

pkg_postrm() {
	udev_reload
}

