FROM fuzzers/libfuzzer:12.0

RUN apt-get update
RUN apt install -y build-essential clang wget git cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev liblzma-dev meson ninja-build pkg-config libzstd-dev
RUN wget https://oligarchy.co.uk/xapian/1.4.19/xapian-core-1.4.19.tar.xz
RUN tar xf xapian-core-1.4.19.tar.xz
WORKDIR /xapian-core-1.4.19
RUN ./configure 
RUN make
RUN make install
WORKDIR ./.libs
RUN cp * /usr/local/lib/
WORKDIR /
RUN git clone https://github.com/openzim/libzim.git
WORKDIR /libzim
RUN meson build .
RUN ninja -C build
RUN ninja -C build install
COPY fuzzers/zim_fuzz.cpp .
RUN clang++ -I./include/ -fsanitize=fuzzer,address zim_fuzz.cpp -o /x -lzim -std=c++17
RUN cp /usr/local/lib/x86_64-linux-gnu/libzim.* /usr/local/lib/
ENV LD_LIBRARY_PATH=/usr/local/lib/

ENTRYPOINT []
CMD /x
