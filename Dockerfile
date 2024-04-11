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

# Download and install PowerCLI
RUN wget -q -O /tmp/VMware-PowerCLI.tar.gz https://www.powershellgallery.com/api/v2/package/VMware.PowerCLI \
    && mkdir -p /usr/src/powercli \
    && tar -xzf /tmp/VMware-PowerCLI.tar.gz -C /usr/src/powercli \
    && pwsh -c "Set-Location /usr/src/powercli; & ./Initialize-PowerCLIEnvironment.ps1 -SetUserScope -Confirm:$false" \
    && rm -f /tmp/VMware-PowerCLI.tar.gz

# Switch back to non-root user
USER pwshuser
