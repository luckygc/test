FROM arm64v8/centos

# 安装构建依赖
RUN yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y \
      epel-release \
      wget \
      curl \
      autoconf \
      automake \
      libtool \
      libjpeg-devel \
      libpng-devel \
      libtiff-devel \
      zlib-devel \
      git

# 设置工作目录
WORKDIR /usr/local/src

# 下载并编译 leptonica
RUN wget https://github.com/DanBloomberg/leptonica/releases/download/1.84.1/leptonica-1.84.1.tar.gz && \
    tar -zxvf leptonica-1.84.1.tar.gz && \
    cd leptonica-1.84.1 && \
    ./autogen.sh && ./configure && make -j$(nproc) && make install

# 下载并编译 tesseract 5.4.1
RUN wget https://github.com/tesseract-ocr/tesseract/archive/refs/tags/5.4.1.tar.gz -O tesseract-5.4.1.tar.gz && \
    tar -zxvf tesseract-5.4.1.tar.gz && \
    cd tesseract-5.4.1 && \
    ./autogen.sh && ./configure && make -j$(nproc) && make install && ldconfig

# 下载 chi_sim 和 eng 语言包
RUN mkdir -p /usr/local/share/tessdata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/chi_sim.traineddata -O /usr/local/share/tessdata/chi_sim.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata -O /usr/local/share/tessdata/eng.traineddata

# 设置默认命令
CMD ["tesseract", "--version"]
