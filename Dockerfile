FROM ubuntu:20.04

#Installation of requierments
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y software-properties-common sudo
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y git wget unzip
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y gcc clang clang-tools g++-10 cmake make g++ clang gdb
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev mysql-server libboost-all-dev
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y build-essential checkinstall zlib1g-dev
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y locales

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

#Build authserver
WORKDIR /wotlk/build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/ -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DSCRIPTS=static -DMODULES=static -DTOOLS_BUILD=none -DAPPS_BUILD=auth-only
#Warning; Should have at least 2 proc!
RUN make install -j $(nproc --all)
RUN make clean

#Create config data
RUN cp /wotlk/src/server/apps/authserver/authserver.conf.dist /usr/local/etc/authserver.conf
RUN sed -i "s/DataDir = \"./DataDir = \"\/usr\/local\/data/g" /usr/local/etc/authserver.conf

WORKDIR /usr/local/bin