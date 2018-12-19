FROM alpine
LABEL maintainer="stefan.oehrli@trivadis.com"
ENV DOCKER_SCRIPTS="/opt/docker/bin"     START_SCRIPT="start_system_update.sh"
ENV PATH=/u00/app/oracle/local/tvdperl-all/bin:/u00/app/oracle/product/12.2.0.1/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/u00/app/oracle/local/dba/bin:/u00/app/oracle/local/tvdusr/bin:/u00/app/oracle/local/tvdas/bin:/bin:/Library/TeX/texbin:/opt/X11/bin:/Applications/Wireshark.app/Contents/MacOS:""
COPY scripts/* "/"
CMD exec "/"
