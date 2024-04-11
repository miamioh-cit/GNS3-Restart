# Use a PowerShell Core base image
FROM mcr.microsoft.com/powershell:latest

# Install VMware PowerCLI
RUN pwsh -c "Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Confirm:$false"

# Set the working directory
WORKDIR /usr/src/app

# Copy your PowerShell script into the container
COPY Restart-VMs.ps1 .

# By default, run the PowerShell script
CMD ["pwsh", "-File", "./Restart-VMs.ps1"]