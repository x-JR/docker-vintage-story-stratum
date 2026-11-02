FROM mcr.microsoft.com/dotnet/runtime:10.0-noble AS dotnet-runtime

FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu24.04

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-vintage-story"

COPY --from=dotnet-runtime /usr/share/dotnet /usr/share/dotnet

RUN apt-get update && \
	apt-get -y install --no-install-recommends ca-certificates curl jq locales mono-complete procps screen unzip wget && \
	ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet && \
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV DOTNET_ROOT=/usr/share/dotnet
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV DATA_DIR="/vintagestory"
ENV VS_CHANNEL="stable"
ENV STATIC_V=""
ENV GAME_PARAMS=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="vintagestory"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]