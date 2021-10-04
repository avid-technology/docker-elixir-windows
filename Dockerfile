ARG BUILD_IMAGE=mcr.microsoft.com/windows/servercore:1809
ARG FROM_IMAGE=ghcr.io/avid-technology/erlang:24.0.6-windows-servercore-1809

FROM $BUILD_IMAGE as build

ARG ELIXIR_VERSION
ARG ELIXIR_HASH

ADD https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip ./Precompiled.zip

RUN if ((Get-FileHash ".\Precompiled.zip" -Algorithm SHA256).Hash -ne $Env:ELIXIR_HASH) { exit 1; }

RUN Expand-Archive -Path ".\Precompiled.zip" -DestinationPath ".\Program` Files\elixir-v$($Env:ELIXIR_VERSION)"

FROM $FROM_IMAGE

ARG ELIXIR_VERSION

COPY --from=build ["C:/Program Files/erl-${ELIXIR_VERSION}", "C:/Program Files/erl-${ELIXIR_VERSION}"]

# Unfortunately setx won't work on certain versions of nanoserver.  Since the erlang base images for
# nanoserver are themselves non-functional at the time of writing I won't got to great pains to fix
# this.
RUN setx /M PATH $($Env:PATH + ';C:\Program Files\elixir-v' + $Env:ELIXIR_VERSION + '\bin')

CMD [ "iex.bat" ]

# ARG OTP_VERSION=24.0.4
# ARG IMAGE=${OTP_VERSION}-windows

# FROM $IMAGE
# ARG ELIXIR_VERSION=1.12.2
# ENV ELIXIR_VERSION_ENV=${ELIXIR_VERSION}




# ADD elixirHash.txt ./elixirHash.txt
# ADD checksum.ps1 ./checksum.ps1


# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


# RUN $precompiled=Get-FileHash ".\Precompiled.zip" -Algorithm SHA512; echo "precompiledHash=$($precompiled.Hash)" > precompiledHash.txt
# RUN .\checksum.ps1; Remove-Item -path ".\elixirHash.txt" ; Remove-Item -path ".\precompiledHash.txt"; Remove-Item -path ".\checksum.ps1"
