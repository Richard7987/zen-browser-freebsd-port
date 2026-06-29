PORTNAME=	zen-browser
PORTVERSION=	1.21.4b
PORTREVISION=	0
CATEGORIES=	www

MAINTAINER=	anything.la@tuta.com
COMMENT=	Firefox-based browser focused on privacy and productivity (Linux binary)
WWW=		https://zen-browser.app

LICENSE=	MPL20

# ── Distfiles ──────────────────────────────────────────────────────────────
MASTER_SITES=	https://github.com/zen-browser/desktop/releases/download/${PORTVERSION}/:zen \
		https://dl.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/Packages/l/:rocky
DISTFILES=	zen.linux-x86_64.tar.xz:zen \
		libnotify-0.7.9-8.el9.x86_64.rpm:rocky
DIST_SUBDIR=	zen-browser

# ── Dependencies ───────────────────────────────────────────────────────────
USES=		linux:rl9
USE_LINUX=	dbus gdkpixbuf2 glib2

# ── Paths ──────────────────────────────────────────────────────────────────
ZEN_LIBDIR=	${PREFIX}/lib/zen-browser
# Stubs go in the Linux compat layer's lib dir so ldconfig makes them visible
# to ALL Linux ELF processes (including Firefox's sandboxed Utility process).
# Installing under PREFIX/lib/zen-browser/linux and using LD_LIBRARY_PATH only
# works for the main Zen process; the Utility/RDD process has a clean environment
# and must find stubs via the ldconfig cache.
STUB_DIR=	${LINUXBASE}/usr/lib64

# ── No standard build (Linux binary + custom stub compilation) ─────────────
NO_ARCH=	yes
WRKSRC=		${WRKDIR}

.include <bsd.port.pre.mk>

# ── Extract ────────────────────────────────────────────────────────────────
do-extract:
	@${ECHO_MSG} "===>  Extracting Zen Browser tarball"
	@${MKDIR} ${WRKDIR}/zen
	tar -xJf ${DISTDIR}/${DIST_SUBDIR}/zen.linux-x86_64.tar.xz \
		-C ${WRKDIR}/zen --strip-components=1
	@${ECHO_MSG} "===>  Extracting libnotify from RPM"
	@${MKDIR} ${WRKDIR}/libnotify
	cd ${WRKDIR}/libnotify && bsdtar xf \
		${DISTDIR}/${DIST_SUBDIR}/libnotify-0.7.9-8.el9.x86_64.rpm

# ── Build: compile compat-layer stubs ──────────────────────────────────────
do-build:
	@${ECHO_MSG} "===>  Compiling Linux compat stubs"
	cd ${WRKSRC} && ${MAKE} -f ${FILESDIR}/stubs.mk \
		FILESDIR=${FILESDIR} \
		WRKDIR=${WRKDIR}

# ── Install ────────────────────────────────────────────────────────────────
do-install:
	# Zen Browser application files
	@${ECHO_MSG} "===>  Installing Zen Browser to ${ZEN_LIBDIR}"
	${MKDIR} ${STAGEDIR}${ZEN_LIBDIR}
	(cd ${WRKDIR}/zen && ${COPYTREE_BIN} . ${STAGEDIR}${ZEN_LIBDIR})

	# Wrapper script
	${SED} -e 's|%%PREFIX%%|${PREFIX}|g' \
		-e 's|%%ZEN_LIBDIR%%|${ZEN_LIBDIR}|g' \
		${FILESDIR}/zen-browser.sh.in \
		> ${STAGEDIR}${PREFIX}/bin/zen-browser
	${CHMOD} 755 ${STAGEDIR}${PREFIX}/bin/zen-browser

	# Desktop entry
	${MKDIR} ${STAGEDIR}${PREFIX}/share/applications
	${SED} -e 's|%%PREFIX%%|${PREFIX}|g' \
		${FILESDIR}/zen-browser.desktop.in \
		> ${STAGEDIR}${PREFIX}/share/applications/zen-browser.desktop

	# Icon
	${MKDIR} ${STAGEDIR}${PREFIX}/share/pixmaps
	${CP} ${WRKDIR}/zen/browser/chrome/icons/default/default128.png \
		${STAGEDIR}${PREFIX}/share/pixmaps/zen-browser.png

	# Stubs in LINUXBASE/usr/lib64/ so ldconfig cache includes them.
	# This is required: the Utility process (which decodes H264/AAC via libavcodec)
	# has a clean environment and cannot use LD_LIBRARY_PATH; it must find these
	# stubs (dependencies of libavcodec.so.59) via the ldconfig cache.
	@${ECHO_MSG} "===>  Installing Linux compat stubs to ${STUB_DIR}"
	${MKDIR} ${STAGEDIR}${STUB_DIR}
	${INSTALL_LIB} ${WRKDIR}/stubs/libmfx.so.1            ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libzvbi.so.0            ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libsoxr.so.0            ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libvo-amrwbenc.so.0     ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libopencore-amrwb.so.0  ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libopencore-amrnb.so.0  ${STAGEDIR}${STUB_DIR}/
	${INSTALL_LIB} ${WRKDIR}/stubs/libSvtAv1Enc.so.0       ${STAGEDIR}${STUB_DIR}/
	cd ${STAGEDIR}${STUB_DIR} && ${LN} -sf libmfx.so.1 libmfx.so

	# libnotify from Rocky Linux 9 RPM
	${INSTALL_LIB} ${WRKDIR}/libnotify/usr/lib64/libnotify.so.4.0.0 \
		${STAGEDIR}${STUB_DIR}/libnotify.so.4.0.0
	cd ${STAGEDIR}${STUB_DIR} && \
		${LN} -sf libnotify.so.4.0.0 libnotify.so.4 && \
		${LN} -sf libnotify.so.4.0.0 libnotify.so

post-install:
	${LINUXBASE}/sbin/ldconfig -r ${LINUXBASE}

.include <bsd.port.post.mk>
