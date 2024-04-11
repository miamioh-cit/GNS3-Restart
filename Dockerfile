FROM mcr.microsoft.com/powershell:latest

# Switch to root user
USER root

# Install necessary packages for PowerCLI
RUN apt-get update \
    && apt-get install -y \
        wget \
        libgssapi-krb5-2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install VMware PowerCLI directly from PowerShell Gallery
RUN pwsh -c "Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -AllowClobber"

# Copy the PowerShell script file into the Docker image
COPY Restart-VMs.ps1 /usr/src/app/
