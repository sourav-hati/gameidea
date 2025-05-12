
# Define path to the existing installer
$installerPath = "$env:USERPROFILE\Downloads\apache-tomcat-9.0.104.exe"

# Check if the file exists
if (Test-Path $installerPath) {
    Write-Output "Found installer at: $installerPath"

    # Run the installer (try silent install, adjust flags if needed)
    Write-Output "Running Apache Tomcat installer..."
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -NoNewWindow

    Write-Output "Apache Tomcat installation completed."
} else {
    Write-Error "Installer not found at: $installerPath"
}
# Define JDK installer filename
$jdkInstallerName = "jdk-21_windows-x64_bin.exe"  # Change this if needed
$installerPath = "$env:USERPROFILE\Downloads\$jdkInstallerName"

# Set installation target (optional, usually defaults to Program Files)
$jdkInstallDir = "C:\Program Files\Java\jdk-21"

# Check if installer exists
if (-Not (Test-Path $installerPath)) {
    Write-Error "JDK installer not found at: $installerPath"
    exit 1
}

Write-Output "Found JDK installer: $installerPath"

# Run the installer silently
Write-Output "Installing JDK..."
Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait -NoNewWindow

# Verify installation directory exists
if (-Not (Test-Path $jdkInstallDir)) {
    Write-Warning "Installation directory not found. You may need to check actual JDK install path."
} else {
    Write-Output "JDK installed at: $jdkInstallDir"

    # Set JAVA_HOME and JRE_HOME system environment variables
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkInstallDir, "Machine")
    [System.Environment]::SetEnvironmentVariable("JRE_HOME", "$jdkInstallDir\jre", "Machine")

    Write-Output "Environment variables JAVA_HOME and JRE_HOME set successfully."
}

# Optional: Add Java to the system PATH
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newJavaBin = "$jdkInstallDir\bin"
if ($oldPath -notlike "*$newJavaBin*") {
    $newPath = "$oldPath;$newJavaBin"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Output "Added $newJavaBin to system PATH."
}



# ---------------------------
# Configurable Parameters
# ---------------------------
$jdkInstallerName = "jdk-21_windows-x64_bin.exe"      # Change if needed
$jdkInstallPath   = "C:\Program Files\Java\jdk-21"    # Change if needed
$tomcatInstallerName = "apache-tomcat-9.0.104.exe"
$downloadsPath = "$env:USERPROFILE\Downloads"

# ---------------------------
# Install JDK
# ---------------------------
$jdkInstaller = Join-Path $downloadsPath $jdkInstallerName
if (-Not (Test-Path $jdkInstallPath)) {
    if (Test-Path $jdkInstaller) {
        Write-Output "Installing JDK from $jdkInstaller..."
        Start-Process -FilePath $jdkInstaller -ArgumentList "/s" -Wait -NoNewWindow
    } else {
        Write-Error "JDK installer not found at $jdkInstaller"
        exit 1
    }
} else {
    Write-Output "JDK is already installed at $jdkInstallPath"
}

# Validate JDK installation
if (-Not (Test-Path $jdkInstallPath)) {
    Write-Error "JDK installation failed or path not found."
    exit 1
}

# ---------------------------
# Set JAVA_HOME and JRE_HOME
# ---------------------------
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkInstallPath, "Machine")

# Handle missing JRE folder in modern JDKs
$jrePath = Join-Path $jdkInstallPath "jre"
if (-Not (Test-Path $jrePath)) {
    $jrePath = $jdkInstallPath  # Use JDK path as fallback
}
[System.Environment]::SetEnvironmentVariable("JRE_HOME", $jrePath, "Machine")

# Add to system PATH if not already there
$javaBin = Join-Path $jdkInstallPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$javaBin*") {
    $newPath = "$currentPath;$javaBin"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Output "Added $javaBin to PATH."
}

# ---------------------------
# Install Apache Tomcat
# ---------------------------
$tomcatInstaller = Join-Path $downloadsPath $tomcatInstallerName
if (Test-Path $tomcatInstaller) {
    Write-Output "Installing Apache Tomcat..."
    Start-Process -FilePath $tomcatInstaller -ArgumentList "/S" -Wait -NoNewWindow
    Write-Output "Apache Tomcat installation completed."
} else {
    Write-Error "Tomcat installer not found at $tomcatInstaller"
}
