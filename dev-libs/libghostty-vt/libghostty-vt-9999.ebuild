# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Ghostty VT terminal emulation library"
HOMEPAGE="https://ghostty.org/ https://github.com/ghostty-org/ghostty"
EGIT_REPO_URI="https://github.com/ghostty-org/ghostty.git"

LICENSE="Apache-2.0 BSD BSD-2 BSD-4 Boost-1.0 MIT MPL-2.0 Unicode-3.0"
SLOT="0"
KEYWORDS=""

# Development-only: Zig resolves build.zig.zon dependencies over the network.
# For a distributable Gentoo ebuild, replace this with zig.eclass and
# a ZBS_DEPENDENCIES snapshot matching the pinned Git revision.
RESTRICT="network-sandbox"

BDEPEND="
	|| (
		>=dev-lang/zig-bin-0.17.0:0.17
		>=dev-lang/zig-0.17.0:0.17
	)
"
RDEPEND="!x11-terms/ghostty"

src_compile() {
	export ZIG_GLOBAL_CACHE_DIR="${T}/zig-global-cache"
	zig build -Demit-lib-vt -Demit-exe=false -Doptimize=ReleaseFast -Dstrip=false || die "zig build failed"
}

src_install() {
    export ZIG_GLOBAL_CACHE_DIR="${T}/zig-global-cache"

    DESTDIR="${D}" zig build \
        -Demit-lib-vt \
        -Demit-exe=false \
        -Doptimize=ReleaseFast \
        -Dstrip=false \
        --prefix /usr \
        --prefix-lib-dir "$(get_libdir)" \
        || die "zig install failed"
}
