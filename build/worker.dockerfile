FROM biigle/build-dist:arm32v6 AS intermediate

FROM ghcr.io/biigle/worker:arm32v6
MAINTAINER Martin Zurowietz <martin@cebitec.uni-bielefeld.de>

COPY --from=intermediate /etc/localtime /etc/localtime
COPY --from=intermediate /etc/timezone /etc/timezone
COPY --from=intermediate /var/www /var/www
