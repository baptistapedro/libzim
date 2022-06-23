FROM fuzzers/libfuzzer:12.0

RUN apt-get update
RUN apt install -y build-essential wget git cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev \
meson ninja-build
RUN git clone https://github.com/openzim/libzim.git
WORKDIR /libzim
RUN meson build .
RUN ninja -C build
RUN ninja -C build install
COPY fuzzers/zim_fuzz.cpp .
RUN clang-12++ -I./include/ -fsanitize=fuzzer,address fuzz.cpp -o /x -lzim -std=c++17
ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu

# Set to fuzz!
ENTRYPOINT []
CMD /x
