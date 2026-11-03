# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Modern and fast terminal for KDE Plasma and other desktops"
HOMEPAGE="https://invent.kde.org/utilities/kwi"
EGIT_REPO_URI="https://invent.kde.org/utilities/kwi.git"

LICENSE="|| ( GPL-2 GPL-3 ) || ( LGPL-2.1 LGPL-3 )"
SLOT="0"
KEYWORDS=""
IUSE="kpart"

RDEPEND="
	>=dev-qt/qtbase-6.10:6=[dbus,gui,network,widgets]
	>=dev-qt/qtdeclarative-6.10:6=
	>=dev-qt/qtshadertools-6.10:6=
	>=dev-qt/qtsvg-6.10:6=
	>=kde-frameworks/kcoreaddons-6.29:6=
	>=kde-frameworks/kconfig-6.29:6=
	>=kde-frameworks/kdbusaddons-6.29:6=
	>=kde-frameworks/kguiaddons-6.29:6=
	>=kde-frameworks/ki18n-6.29:6=
	>=kde-frameworks/kirigami-6.29:6=
	>=kde-frameworks/kpty-6.29:6=
	>=kde-frameworks/kio-6.29:6=
	>=kde-frameworks/knotifications-6.29:6=
	>=kde-frameworks/kwindowsystem-6.29:6=
	>=kde-frameworks/kitemmodels-6.29:6=
	>=kde-frameworks/qqc2-desktop-style-6.29:6=
	>=dev-libs/kirigami-addons-1.11:6=
	>=dev-libs/kirigami-app-components-1.1:6=
	>=dev-libs/libghostty-vt-1.4
	kpart? (
		>=kde-frameworks/kparts-6.29:6=
		>=kde-frameworks/kxmlgui-6.29:6=
		>=kde-frameworks/kwidgetsaddons-6.29:6=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.28
	>=kde-frameworks/extra-cmake-modules-6.29
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_KPART=$(usex kpart ON OFF)
	)
	cmake_src_configure
}
