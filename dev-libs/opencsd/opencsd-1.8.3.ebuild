# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="ARM CoreSight trace stream decoder library"
HOMEPAGE="https://github.com/Linaro/OpenCSD"
SRC_URI="https://github.com/Linaro/OpenCSD/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/OpenCSD-${PV}"

LICENSE="BSD"
SLOT="0/1"
KEYWORDS="~amd64 ~arm64"
IUSE="static-libs"

src_prepare() {
	default

	sed -i 's/-O2 -DNDEBUG/-DNDEBUG/g' \
		decoder/build/unix_common/makefile.common || die

	if ! tc-is-gcc; then
		sed -i 's/-Wlogical-op//g' \
			decoder/build/linux/makefile || die
	fi
}

opencsd_make() {
	emake -C decoder/build/linux \
		MASTER_CC="$(tc-getCC)" \
		MASTER_CXX="$(tc-getCXX)" \
		MASTER_LINKER="$(tc-getCXX)" \
		MASTER_LIB="$(tc-getAR)" \
		"$@"
}

src_compile() {
	opencsd_make
}

src_install() {
	local args=(
		DESTDIR="${D}"
		PREFIX="${EPREFIX}/usr"
		LIB_PATH="$(get_libdir)"
	)

	if ! use static-libs; then
		args+=( DISABLE_STATIC=1 )
	fi

	opencsd_make -j1 "${args[@]}" install install_man

	einstalldocs
}
