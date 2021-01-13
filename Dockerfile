FROM innovanon/doom-base as builder-04
USER root
COPY --from=innovanon/zlib       /tmp/zlib.txz       /tmp/
COPY --from=innovanon/bzip2      /tmp/bzip2.txz      /tmp/
COPY --from=innovanon/xz         /tmp/xz.txz         /tmp/
COPY --from=innovanon/libpng     /tmp/libpng.txz     /tmp/
COPY --from=innovanon/jpeg-turbo /tmp/jpeg-turbo.txz /tmp/
RUN extract.sh

FROM builder-04 as sdl
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && command -v strip.sh                 \
 && git clone --depth=1 --recursive       \
      https://github.com/SDL-mirror/SDL.git \
 && cd                            SDL     \
 && ./autogen.sh                          \
 && ./configure                           \
      --disable-shared --enable-static    \
      "${CONFIG_OPTS[@]}"                 \
 && make                                  \
 && make DESTDIR=/tmp/sdl install         \
 && cd           /tmp/sdl                 \
 && strip.sh .                            \
 && tar  pacf        ../sdl.txz .           \
 && rm -rf           $LFS/sources/SDL

FROM scratch as final
COPY --from=sdl /tmp/sdl.txz /tmp/

