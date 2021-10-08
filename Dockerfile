ARG BUILD_IMAGE=mcr.microsoft.com/windows/servercore:1809
ARG FROM_IMAGE=ghcr.io/avid-technology/erlang:24.0.6-windows-servercore-1809

FROM $BUILD_IMAGE as build

ARG ELIXIR_VERSION
ARG ELIXIR_HASH

# Powershell is not on the path because why would it be?
SHELL ["C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", \
     "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ADD https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip ./Precompiled.zip

RUN $PrecompiledHash = (Get-FileHash Precompiled.zip -Algorithm SHA512); \
    if ($PrecompiledHash.Hash -ne $Env:ELIXIR_HASH) { exit 1; }

# $Env:ELIXIR_VERSION & $Env:ELIXIR_HASH don't work with their Docker counterparts. TODO: Docker variable resolution is dumb.
RUN Expand-Archive -Path .\Precompiled.zip -DestinationPath ".\Program` Files\elixir-$Env:ELIXIR_VERSION" -Force

FROM $FROM_IMAGE

ARG OTP_VERSION

ARG ELIXIR_VERSION

COPY --from=build ["C:/Program Files/elixir-${ELIXIR_VERSION}", "C:/Program Files/elixir-${ELIXIR_VERSION}"]

ADD https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe \
  ./Git-2.33.0.2-64-bit.exe

RUN Git-2.33.0.2-64-bit.exe /VERYSILENT /NORESTART /NOCANCEL /SP- \
  /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS \
  /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"

# Unfortunately setx won't work on certain versions of nanoserver. This is a work around.
ENV  PATH="C:\Windows\system32;C:\Windows;C:\Program Files\erl-${OTP_VERSION}\bin;C:\Program Files\elixir-${ELIXIR_VERSION}\bin;C:\Program Files\Git\bin;C:\Program Files\Git\cmd"

CMD [ "iex" ]
