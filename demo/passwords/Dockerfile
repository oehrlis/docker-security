FROM alpine
ENV URL=http://docker.oradba.ch/depot/demo.zip    USER=scott     PASSWORD=tiger
RUN apk --update add curl &&     curl --user scott:tiger -f  -o demo.txt
RUN curl --user soe: -f  -o demo.txt
CMD cat demo.txt
