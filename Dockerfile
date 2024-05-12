FROM ubuntu:20.04

# Installation of requierments
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

# Get maps data (get last release)
WORKDIR /usr/local/data
RUN wget https://github.com/wowgaming/client-data/releases/download/v16/data.zip
RUN unzip data.zip && rm data.zip

# Create app directoy
WORKDIR /wotlk
COPY . .

# Get modules
WORKDIR /wotlk/modules
RUN git clone https://github.com/Jackhein/mod-event-weekend-bonus
RUN git clone https://github.com/Jackhein/mod-event-love-is-in-the-air-60
RUN git clone https://github.com/Jackhein/mod-event-hallow-s-end-60
RUN git clone https://github.com/azerothcore/mod-transmog
RUN git clone https://github.com/Jackhein/mod-talent-points-quests

# Build worldserver
WORKDIR /wotlk/build
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/ -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DSCRIPTS=static -DMODULES=static -DTOOLS_BUILD=none -DAPPS_BUILD=world-only

# Compile worldserver
RUN make install -j $(nproc --all)
RUN make clean

#Create config data
RUN cp /wotlk/src/server/apps/worldserver/worldserver.conf.dist /usr/local/etc/worldserver.conf
RUN sed -i "s/DataDir = \"./DataDir = \"\/usr\/local\/data/g" /usr/local/etc/worldserver.conf

WORKDIR /usr/local/bin