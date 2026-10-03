EAPI=8

inherit meson

DESCRIPTION="Userspace tools and library for Qualcomm QRTR"
HOMEPAGE="https://github.com/linux-msm/qrtr"
SRC_URI="https://github.com/linux-msm/qrtr/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm64"

src_configure() {
	local emesonargs=(
		-Dqrtr-ns=disabled
		-Dsystemd-service=disabled
	)

	meson_src_configure
}
