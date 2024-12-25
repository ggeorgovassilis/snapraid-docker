FROM ubuntu:18.04 AS ubuntu_updated

RUN apt update
RUN apt upgrade -y

FROM ubuntu_updated AS build
RUN apt install -y git build-essential

RUN mkdir /build
WORKDIR /build

#TIL: adding a tar file automagically extracts it
ADD ./snapraid.tar.gz /build/

RUN extracted_dir=$(ls -d snapraid-* 2>/dev/null) && mv "$extracted_dir" snapraid

WORKDIR /build/snapraid

RUN ./configure
RUN make
RUN make check
RUN make install
RUN ls -lah /usr/local/bin/snapraid
RUN /usr/local/bin/snapraid --version

FROM ubuntu_updated
COPY --from=1 /usr/local/bin/snapraid /bin/snapraid
RUN /bin/snapraid --version
