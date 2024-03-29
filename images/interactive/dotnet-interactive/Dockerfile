FROM jupyter/base-notebook:ubuntu-18.04
LABEL maintainer="Martin Kandlbinder <indy@3rdman.de>"

ARG DOTNET_CORE_VERSION=3.1
ENV DOTNET_CORE_VERSION=$DOTNET_CORE_VERSION \
    DOTNET_CORE_VERSION_INTERACTIVE=5.0 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    PATH="${PATH}:${HOME}/.dotnet/tools"

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        dialog \
        libgssapi-krb5-2 \
        libicu60 \
        openjdk-8-jdk \
        software-properties-common \
        unzip \
    && wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && add-apt-repository universe \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y dotnet-sdk-$DOTNET_CORE_VERSION \
    && apt-get install -y dotnet-sdk-$DOTNET_CORE_VERSION_INTERACTIVE \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && rm -rf packages-microsoft-prod.deb

COPY ./nuget.config ${HOME}/nuget.config

USER ${NB_USER}

RUN pip install nteract_on_jupyter \
    && dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.230903 \
    && dotnet interactive jupyter install
