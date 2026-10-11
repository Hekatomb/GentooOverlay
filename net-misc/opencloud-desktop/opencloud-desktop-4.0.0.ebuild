# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Desktop synchronization client for OpenCloud"
HOMEPAGE="https://github.com/opencloud-eu/desktop"
SRC_URI="https://github.com/opencloud-eu/desktop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/desktop-${PV}"

LICENSE="CC-BY-3.0 GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="keyring"
RESTRICT="test mirrors"

RDEPEND="
	>=dev-db/sqlite-3.9:3
	dev-libs/kdsingleapplication
	>=dev-libs/qtkeychain-0.13:=[keyring?,qt6(+)]
	>=dev-qt/qtbase-6.8:6[concurrent,dbus,gui,network,ssl,widgets,xml]
	>=dev-qt/qtdeclarative-6.8:6[widgets]
	>=net-libs/libre-graph-api-cpp-qt-client-1.0.4
	sys-fs/inotify-tools
	virtual/zlib:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	>=kde-frameworks/extra-cmake-modules-6.0
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
		-DWITH_AUTO_UPDATER=OFF
		-DWITH_UPDATE_NOTIFICATION=OFF
		-DWITH_CRASHREPORTER=OFF
		-DWITH_HTTP2=OFF
		-DVIRTUAL_FILE_SYSTEM_PLUGINS=off
		-DKDE_INSTALL_SYSCONFDIR=/etc
	)
	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	if ! has_version 'dev-libs/qtkeychain[keyring]'; then
		elog "Enable USE=keyring on dev-libs/qtkeychain to store login credentials securely."
	fi
}
