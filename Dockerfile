FROM ubuntu:20.04

#Installation of requierments
RUN apt-get update -y && apt-get install -y software-properties-common sudo
RUN apt-get update -y && apt-get install -y git wget unzip
RUN apt-get update -y && apt-get install -y gcc clang clang-tools g++-10 cmake make g++ clang gdb
RUN add-apt-repository ppa:mhier/libboost-latest -y
RUN apt-get update -y && apt-get install -y libmysqlclient-dev libssl1.1 libssl-dev libbz2-dev libreadline-dev libncurses-dev mysql-server libboost1.74-dev
RUN apt-get update -y && apt-get install -y build-essential checkinstall zlib1g-dev
RUN apt-get update -y && apt-get install -y locales
RUN apt-get update -y && wget https://www.openssl.org/source/openssl-3.0.11.tar.gz \
    && tar xvf openssl-3.0.11.tar.gz && cd openssl-3.0.11 \
    && ./config && make -j$(nproc) && make install \
    && ldconfig


# Set timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create app directoy
WORKDIR /wotlk
COPY . .

# Get modules
WORKDIR /wotlk/modules
RUN rm -rf mod-*
RUN git clone https://github.com/Jackhein/mod-check-modules-conflicts
WORKDIR /wotlk/modules/mod-check-modules-conflicts
RUN bash apply_sql_copy.sh -y
RUN bash apply_conf_copy.sh -y -p /usr/local/etc/
RUN rm -rf /wotlk/modules/mod-check-modules-conflicts

#Build authserver
WORKDIR /wotlk/build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/ -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DSCRIPTS=static -DMODULES=static -DTOOLS_BUILD=none -DAPPS_BUILD=world-only
#Warning; Should have at least 2 proc!
RUN make install -j $(nproc --all)
RUN make clean

#Create config data
RUN cp /wotlk/src/server/apps/worldserver/worldserver.conf.dist /usr/local/etc/worldserver.conf
RUN sed -i "s/DataDir = \"./DataDir = \"\/usr\/local\/data/g" /usr/local/etc/worldserver.conf

WORKDIR /usr/local/bin
