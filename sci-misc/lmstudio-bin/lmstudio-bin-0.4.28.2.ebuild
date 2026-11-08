# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

# Upstream versions carry a build number ("0.4.24-1" in the download URL,
# "0.4.24+1" in the .deb control file). It is folded into PV as a fourth
# component, and MY_PV turns the last dot back into a dash.
MY_PV="${PV%.*}-${PV##*.}"
MY_PN="LM-Studio"

DESCRIPTION="LM Studio - discover, download and run local LLMs"
HOMEPAGE="https://lmstudio.ai"
SRC_URI="https://installers.lmstudio.ai/linux/x64/${MY_PV}/${MY_PN}-${MY_PV}-x64.deb -> ${P}.deb"

S="${WORKDIR}"

# Proprietary EULA (https://lmstudio.ai/app-terms) forbidding redistribution.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="mirror strip bindist"

# Depends of the upstream .deb plus the NEEDED entries of the Electron binary.
# The llama.cpp backends bundle their own Vulkan loader and CUDA runtime, so
# only a Vulkan ICD or the NVIDIA driver is needed for GPU offload.
RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

src_install() {
	# Keep the upstream prefix: the desktop file and the bundled lms CLI both
	# refer to /opt/LM-Studio.
	mkdir -p "${ED}/opt/${MY_PN}" || die
	cp -r "${S}/opt/${MY_PN}/"* "${ED}/opt/${MY_PN}" || die

	# The .deb postinst picks 4755 only when unprivileged user namespaces are
	# unavailable. A binary package cannot probe the target kernel, so ship
	# the setuid fallback, which works in both cases.
	fperms 4755 "/opt/${MY_PN}/chrome-sandbox"

	dosym "../../opt/${MY_PN}/lm-studio" /usr/bin/lm-studio
	# Bundled lms CLI (local server, model management), only needs libc.
	dosym "../../opt/${MY_PN}/resources/app/.webpack/lms" /usr/bin/lms

	# Upstream adds a lowercase "category" key that desktop-file-validate rejects.
	sed -e '/^category=/d' \
		"${S}/usr/share/applications/ai.elementlabs.lmstudio.desktop" \
		> "${T}/ai.elementlabs.lmstudio.desktop" || die
	domenu "${T}/ai.elementlabs.lmstudio.desktop"

	local size
	for size in 16 24 32 48 64 128 256 512; do
		newicon -s ${size} \
			"${S}/usr/share/icons/hicolor/${size}x${size}/apps/lm-studio.png" \
			lm-studio.png
	done
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LM Studio has been installed to /opt/${MY_PN}"
	elog ""
	elog "To launch: lm-studio (GUI) or lms (CLI, e.g. 'lms server start')"
	elog ""
	elog "The bundled llama.cpp runtimes require an AVX2 capable CPU."
	elog "GPU offload needs a Vulkan ICD (media-libs/mesa[vulkan] or the"
	elog "NVIDIA driver) or x11-drivers/nvidia-drivers for the CUDA runtime."
	elog "Models and runtimes are stored under ~/.lmstudio"
}
