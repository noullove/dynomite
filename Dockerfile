# -------------------------------------------------------------------------------------------------
#
# layer for download and verifying
FROM debian:buster-slim as downloader

WORKDIR /tmp

COPY dynomite.tgz /tmp/dynomite.tgz

RUN \
  tar --extract --gzip --file "/tmp/dynomite.tgz" --directory /opt

COPY config/dynomite.yml /opt/dynomite/conf

# -------------------------------------------------------------------------------------------------
#
# final layer
#
FROM redis:latest

RUN \
  apt-get update  > /dev/null && \
  apt-get install --no-install-recommends --assume-yes \
    procps > /dev/null && \
  apt-get remove --assume-yes --purge \
    apt-utils > /dev/null && \
  rm -f /etc/apt/sources.list.d/* && \
  apt-get clean > /dev/null && \
  apt autoremove --assume-yes > /dev/null && \
  rm -rf \
    /tmp/* \
    /var/cache/debconf/* \
    /var/lib/apt/lists/* \
    /var/log/* \
    /usr/share/X11 \
    /usr/share/doc/* 2> /dev/null && \
    chmod 0775 /opt

COPY --from=downloader /opt /opt
COPY config/redis.conf /usr/local/etc
COPY docker-entrypoint.sh /

ENV PATH /opt/dynomite/sbin:$PATH

EXPOSE 8379

WORKDIR /opt/dynomite

ENTRYPOINT ["/docker-entrypoint.sh"]
