FROM alpine
ENV URL=http://docker.oradba.ch/depot/demo.zip \
    USER=scott \
    PASSWORD=tiger
RUN apk --update add curl && \
    curl --user scott:tiger -f $URL -o demo.txt
RUN curl --user $USER:$PASSWORD -f $URL -o demo.txt
CMD cat demo.txt