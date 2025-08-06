FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Cài gói hệ thống
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        git \
        pciutils \
        python3 \
        python3-pip \
        build-essential \
        python3-dev \
        libffi-dev \
        libssl-dev \
        numactl \
        iproute2 \
        iputils-ping \
        curl \
        net-tools \
        libyaml-dev \
        && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Tạo user zun
RUN groupadd --system zun && \
    useradd --system -g zun --home-dir /var/lib/zun -s /bin/false zun

# Làm việc tại /opt/zun
WORKDIR /opt/zun

# Clone mã nguồn Zun (nhánh stable/2025.1)
COPY . .

# Cài đúng version pyroute2 có transactional
RUN pip3 install pyroute2==0.6.13 && \
    pip3 install pymysql

# Cài các phụ thuộc Python
RUN pip3 install -r requirements.txt && \
    pip3 install .

# Tạo thư mục và copy config
RUN mkdir -p /etc/zun /var/log/zun /var/lib/zun/tmp /etc/cni/net.d && \
    cp etc/zun/rootwrap.conf /etc/zun/rootwrap.conf && \
    cp -r etc/zun/rootwrap.d /etc/zun/rootwrap.d && \
    chown -R zun:zun /etc/zun /var/log/zun /var/lib/zun /etc/cni/net.d

# Command mặc định
CMD ["zun-compute", "--config-file", "/etc/zun/zun.conf"]
