# 第一阶段：构建环境
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake libtool pkg-config \
    libpng-dev libjpeg-dev libtiff-dev zlib1g-dev \
    libicu-dev libpango1.0-dev libcairo2-dev \
    ca-certificates wget git build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# 编译并安装 Leptonica
RUN wget https://github.com/DanBloomberg/leptonica/releases/download/1.84.1/leptonica-1.84.1.tar.gz && \
    tar xf leptonica-1.84.1.tar.gz && \
    cd leptonica-1.84.1 && \
    ./autogen.sh && ./configure && \
    make -j$(nproc) && make install

# 编译并安装 Tesseract
RUN wget https://github.com/tesseract-ocr/tesseract/archive/refs/tags/5.4.1.tar.gz -O tesseract-5.4.1.tar.gz && \
    tar xf tesseract-5.4.1.tar.gz && \
    cd tesseract-5.4.1 && \
    ./autogen.sh && ./configure && \
    make -j$(nproc) && make install

# 下载中英文语言包
RUN mkdir -p /usr/local/share/tessdata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/chi_sim.traineddata -O /usr/local/share/tessdata/chi_sim.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata -O /usr/local/share/tessdata/eng.traineddata

# 清理构建依赖和临时文件
RUN ldconfig && \
    apt-get purge -y --auto-remove \
      autoconf automake libtool pkg-config wget git build-essential ca-certificates && \
    rm -rf /opt/* /var/lib/apt/lists/* /tmp/*


# 第二阶段：运行环境
FROM ubuntu:22.04

# 从构建阶段拷贝安装结果
COPY --from=builder /usr/local /usr/local

# 配置 Tesseract 语言包路径
ENV TESSDATA_PREFIX=/usr/local/share/tessdata

WORKDIR /data

# 默认命令：显示版本信息
CMD ["tesseract", "--version"]