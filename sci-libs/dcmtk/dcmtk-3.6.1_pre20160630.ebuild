# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit cmake-utils eutils

MY_PVX=${PVR/pre/}
MY_PV=${MY_PVX/-r[0-9]*/}

DESCRIPTION="The DICOM Toolkit"
HOMEPAGE="http://dicom.offis.de/dcmtk.php.en"
SRC_URI="http://dicom.offis.de/download/${PN}/snapshot/old/${PN}-${MY_PV}.tar.gz"
LICENSE="BSD"

KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="doc png ssl tcpd +threads tiff xml zlib iconv"

RDEPEND="
	virtual/jpeg
	png? ( media-libs/libpng )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
	tiff? ( media-libs/tiff )
	xml? ( dev-libs/libxml2:2 )
	zlib? ( sys-libs/zlib )
	iconv? ( virtual/libiconv )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/${PN}-${MY_PV}


PATCHES=(
	"${FILESDIR}"/soversion_abi.patch
)

src_configure() {
	mycmakeargs="${mycmakeargs}
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_INSTALL_PREFIX=/usr
		$(cmake-utils_use tiff DCMTK_WITH_TIFF)
		$(cmake-utils_use png DCMTK_WITH_PNG)
		$(cmake-utils_use xml DCMTK_WITH_XML)
		$(cmake-utils_use zlib DCMTK_WITH_ZLIB)
		$(cmake-utils_use iconv DCMTK_WITH_ICONV)
		$(cmake-utils_use ssl DCMTK_WITH_OPENSSL)
		$(cmake-utils_use doc DCMTK_WITH_DOXYGEN)
		$(cmake-utils_use threads DCMTK_WITH_THREADS)"
	cmake-utils_src_configure
	if use doc; then
		cd "${S}"/doxygen
		econf
	fi
}

src_compile() {
	cmake-utils_src_compile
	if use doc; then
		emake -C "${S}"/doxygen || die
	fi
}

src_install() {
	cmake-utils_src_install
	if use doc; then
		cd "${S}"
		doman doxygen/manpages/man1/* || die
		dohtml -r doxygen/htmldocs/* || die
	fi
}
