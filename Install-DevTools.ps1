# Install-DevTools.ps1

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Administrative privileges are required. Please run this script as an Administrator."
    exit 1
}

# Define the log file path
$logFile = "$PSScriptRoot\install_log.txt"
"Installation started at $(Get-Date)" | Out-File -FilePath $logFile -Encoding utf8

# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    "Chocolatey not found. Installing Chocolatey..." | Tee-Object -FilePath $logFile -Append
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 2>> $logFile
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        "ERROR: Chocolatey installation failed. Check $logFile for details." | Tee-Object -FilePath $logFile -Append
        exit 1
    } else {
        "Chocolatey installed successfully." | Tee-Object -FilePath $logFile -Append
    }
} else {
    "Chocolatey is already installed." | Tee-Object -FilePath $logFile -Append
}

# Define complex parameters for Visual Studio
$vsParams = '--add Microsoft.VisualStudio.Workload.NetCrossPlat --add Microsoft.VisualStudio.Workload.NetWeb'

# Define the list of software to install
$softwareList = @(
    @{ Name = "Chocolatey Upgrade"; Command = 'choco upgrade chocolatey -y' },
    @{ Name = "Visual Studio 2022 (MAUI)"; Command = "choco install visualstudio2022enterprise --package-parameters ""--allWorkloads --includeRecommended --includeOptional --passive --locale en-US""" },
    @{ Name = "Visual Studio Code"; Command = 'choco install vscode -y' },
    @{ Name = "Postman"; Command = 'choco install postman -y' },
    @{ Name = "Git"; Command = 'choco install git -y' },
	@{ Name = "Git Credential Manager"; Command = 'choco install git-credential-manager-for-windows -y' },
    @{ Name = "Android Studio"; Command = 'choco install androidstudio -y' },
    @{ Name = "Terraform"; Command = 'choco install terraform -y' },
	@{ Name = "Obsidian"; Command = 'choco install obsidian -y' },
    @{ Name = "NuGet CLI"; Command = 'choco install nuget.commandline -y' },
    @{ Name = "Azure CLI"; Command = 'choco install azure-cli -y' },
    @{ Name = "Notepad++"; Command = 'choco install notepadplusplus -y' },
    @{ Name = "Upgrade All Packages"; Command = 'choco upgrade all -y' }
)

# Function to install software and log results
function Install-Software {
    param (
        [string]$Name,
        [string]$Command
    )
    try {
        "$((Get-Date)): Installing $Name..." | Tee-Object -FilePath $logFile -Append
        Write-Host "Executing command: $Command"
        Invoke-Expression $Command 2>> $logFile
        "$Name installed successfully." | Tee-Object -FilePath $logFile -Append
    } catch {
        "ERROR: $Name installation failed. Check the console output and $logFile for details." | Tee-Object -FilePath $logFile -Append
        $script:installError = $true
        $script:errorList += $Name + " "
    }
    ""
}

$installError = $false
$errorList = ""

# List all software to be installed
$index = 1
$totalInstalls = $softwareList.Count

Write-Host "Listing all software to be installed:"
foreach ($software in $softwareList) {
    "$index. $($software.Name)"
    "   Command: $($software.Command)"
    $index++
}
$index = 1

# Begin installation loop
foreach ($software in $softwareList) {
    "Installing $($software.Name) ($index of $totalInstalls)..." | Write-Host
    Install-Software -Name $software.Name -Command $software.Command
    $index++
}

# Final output
if ($installError) {
    ""
    "Some installations failed. Please check $logFile for details." | Write-Host
    "Failed installations:" | Write-Host
    $errorList | Write-Host
} else {
    ""
    "All development tools installed successfully." | Write-Host
}

"Installation completed at $(Get-Date)." | Out-File -FilePath $logFile -Append
"Development tools installation complete. Check $logFile for details." | Write-Host

Pause
