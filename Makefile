PORTNAME=	zen-browser
DISTVERSION=	1.21.4b
PORTREVISION=	0
CATEGORIES=	www
PKGNAMEPREFIX=	linux-

MAINTAINER=	anything.la@tuta.com
COMMENT=	Firefox-based browser focused on privacy and productivity (Linux binary)
WWW=		https://zen-browser.app

LICENSE=	MPL20

# CPE tracks CVEs from Firefox/Gecko that apply to this fork
CPE_VENDOR=	mozilla
CPE_PRODUCT=	firefox

MASTER_SITES=	https://github.com/zen-browser/desktop/releases/download/${DISTVERSION}/:zen \
		https://dl.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/Packages/l/:rocky
DISTFILES=	zen.linux-x86_64.tar.xz:zen \
		libnotify-0.7.9-8.el9.x86_64.rpm:rocky
DIST_SUBDIR=	zen-browser

USES=		linux:rl9
USE_LINUX=	dbus gdkpixbuf2 glib2

ONLY_FOR_ARCHS=	amd64

ZEN_LIBDIR=	${PREFIX}/lib/zen-browser
# Stubs go in the Linux compat layer's lib dir so ldconfig makes them visible
# to ALL Linux ELF processes (including Firefox's sandboxed Utility process).
# Installing under PREFIX/lib/zen-browser/linux and using LD_LIBRARY_PATH only
# works for the main Zen process; the Utility/RDD process has a clean environment
# and must find stubs via the ldconfig cache.
STUB_DIR=	${LINUXBASE}/usr/lib64

WRKSRC=		${WRKDIR}

.include <bsd.port.pre.mk>

do-extract:
	@${MKDIR} ${WRKDIR}/zen
	@tar -xJf ${DISTDIR}/${DIST_SUBDIR}/zen.linux-x86_64.tar.xz \
		-C ${WRKDIR}/zen --strip-components=1
	@${MKDIR} ${WRKDIR}/libnotify
	@cd ${WRKDIR}/libnotify && bsdtar xf \
		${DISTDIR}/${DIST_SUBDIR}/libnotify-0.7.9-8.el9.x86_64.rpm

do-build:
	@cd ${WRKSRC} && ${MAKE} -f ${FILESDIR}/stubs.mk \
		FILESDIR=${FILESDIR} \
		WRKDIR=${WRKDIR}

do-install:
	@${MKDIR} ${STAGEDIR}${ZEN_LIBDIR}
	@(cd ${WRKDIR}/zen && ${COPYTREE_BIN} . ${STAGEDIR}${ZEN_LIBDIR})
	@${SED} -e 's|%%PREFIX%%|${PREFIX}|g' \
		-e 's|%%ZEN_LIBDIR%%|${ZEN_LIBDIR}|g' \
		${FILESDIR}/zen-browser.sh.in \
		> ${STAGEDIR}${PREFIX}/bin/zen-browser
	@${CHMOD} 755 ${STAGEDIR}${PREFIX}/bin/zen-browser
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/applications
	@${SED} -e 's|%%PREFIX%%|${PREFIX}|g' \
		${FILESDIR}/zen-browser.desktop.in \
		> ${STAGEDIR}${PREFIX}/share/applications/zen-browser.desktop
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/pixmaps
	@${CP} ${WRKDIR}/zen/browser/chrome/icons/default/default128.png \
		${STAGEDIR}${PREFIX}/share/pixmaps/zen-browser.png
	@${MKDIR} ${STAGEDIR}${STUB_DIR}
.for lib in libmfx.so.1 libzvbi.so.0 libsoxr.so.0 libvo-amrwbenc.so.0 \
		libopencore-amrwb.so.0 libopencore-amrnb.so.0 libSvtAv1Enc.so.0
	@${INSTALL_LIB} ${WRKDIR}/stubs/${lib} ${STAGEDIR}${STUB_DIR}/
.endfor
	@cd ${STAGEDIR}${STUB_DIR} && ${LN} -sf libmfx.so.1 libmfx.so
	@${INSTALL_LIB} ${WRKDIR}/libnotify/usr/lib64/libnotify.so.4.0.0 \
		${STAGEDIR}${STUB_DIR}/libnotify.so.4.0.0
	@cd ${STAGEDIR}${STUB_DIR} && \
		${LN} -sf libnotify.so.4.0.0 libnotify.so.4 && \
		${LN} -sf libnotify.so.4.0.0 libnotify.so

.include <bsd.port.post.mk>
