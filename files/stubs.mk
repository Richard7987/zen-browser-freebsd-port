# Compiles Linux compat stubs for Zen Browser
# Called from the port's do-build target

CC=		clang
CFLAGS=		-target x86_64-linux-gnu -nostdlib -shared -fPIC -O2
BRANDELF=	/usr/bin/brandelf
OUTDIR=		${WRKDIR}/stubs

all: ${OUTDIR} \
	${OUTDIR}/libmfx.so.1 \
	${OUTDIR}/libzvbi.so.0 \
	${OUTDIR}/libsoxr.so.0 \
	${OUTDIR}/libvo-amrwbenc.so.0 \
	${OUTDIR}/libopencore-amrwb.so.0 \
	${OUTDIR}/libopencore-amrnb.so.0 \
	${OUTDIR}/libSvtAv1Enc.so.0

${OUTDIR}:
	mkdir -p ${OUTDIR}

${OUTDIR}/libmfx.so.1: ${FILESDIR}/stub_mfx.c ${FILESDIR}/mfx2.ver
	${CC} ${CFLAGS} -Wl,--version-script=${FILESDIR}/mfx2.ver \
		-Wl,-soname,libmfx.so.1 \
		-o $@ ${FILESDIR}/stub_mfx.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libzvbi.so.0: ${FILESDIR}/stub_zvbi.c
	${CC} ${CFLAGS} -Wl,-soname,libzvbi.so.0 \
		-o $@ ${FILESDIR}/stub_zvbi.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libsoxr.so.0: ${FILESDIR}/stub_soxr.c
	${CC} ${CFLAGS} -Wl,-soname,libsoxr.so.0 \
		-o $@ ${FILESDIR}/stub_soxr.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libvo-amrwbenc.so.0: ${FILESDIR}/stub_amrwbenc.c
	${CC} ${CFLAGS} -Wl,-soname,libvo-amrwbenc.so.0 \
		-o $@ ${FILESDIR}/stub_amrwbenc.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libopencore-amrwb.so.0: ${FILESDIR}/stub_amrwb.c
	${CC} ${CFLAGS} -Wl,-soname,libopencore-amrwb.so.0 \
		-o $@ ${FILESDIR}/stub_amrwb.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libopencore-amrnb.so.0: ${FILESDIR}/stub_amrnb.c
	${CC} ${CFLAGS} -Wl,-soname,libopencore-amrnb.so.0 \
		-o $@ ${FILESDIR}/stub_amrnb.c
	${BRANDELF} -t Linux $@

${OUTDIR}/libSvtAv1Enc.so.0: ${FILESDIR}/stub_svtav1.c
	${CC} ${CFLAGS} -Wl,-soname,libSvtAv1Enc.so.0 \
		-o $@ ${FILESDIR}/stub_svtav1.c
	${BRANDELF} -t Linux $@
