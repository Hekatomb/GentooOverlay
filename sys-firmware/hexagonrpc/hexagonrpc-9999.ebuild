EAPI=8

inherit git-r3 meson

DESCRIPTION="FastRPC ioctl wrapper, reverse RPC daemon and HexagonFS"
HOMEPAGE="https://github.com/linux-msm/hexagonrpc"
EGIT_REPO_URI="https://github.com/linux-msm/hexagonrpc.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="arm64"

src_configure() {
	local emesonargs=(
		-Dhexagonrpcd_verbose=true
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	# Upstream installs systemd units below libdir/systemd/system.
	# Gentoo expects native system units below /usr/lib/systemd/system.
	if [[ -d "${ED}/usr/$(get_libdir)/systemd/system" && "$(get_libdir)" != "lib" ]]; then
		dodir /usr/lib/systemd/system
		mv "${ED}/usr/$(get_libdir)/systemd/system/"* "${ED}/usr/lib/systemd/system/" || die
		rmdir "${ED}/usr/$(get_libdir)/systemd/system" || die
	fi
}
