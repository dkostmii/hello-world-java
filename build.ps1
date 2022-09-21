param(
  [switch] $Run = $false,
  [switch] $Clean = $false
)

# CHANGE THIS
$MainClass = "helloworld.App";

# Definitions

$targetDir = "target";
$classesDir = (Join-Path $targetDir "classes");
$srcDir = (Join-Path "src" "main" "java");

$manifestFile = "MANIFEST.MF";
$manifestContent = "Main-Class: " + $MainClass;

$ProjName = (Split-Path -Path (Get-Location) -Leaf);

$jarFile = "$ProjName.jar";
$jarFileClassesRel = (Join-Path ".." $jarFile);
$jarFileAbs = (Join-Path $targetDir $jarFile);

# Check java, jar executables are accessible from the PATH
function Check {
  $javaOk = $false;
  $jarOk = $false;

  if (Get-Command "java" -ErrorAction SilentlyContinue) {
    $javaOk = $true;
  }

  if (Get-Command "jar" -ErrorAction SilentlyContinue) {
    $jarOk = $true;
  }

  return ($javaOk -and $jarOk);
}

function Clean {
  Write-Output "Cleaning build...";
  Remove-Item $classesDir -Recurse;
  Remove-Item $targetDir -Recurse;
}

function Build {
  if (-not (Test-Path $targetDir -PathType Container)) {
    New-Item $targetDir -ItemType Directory | Out-Null;
  }
  
  if (-not (Test-Path $classesDir -PathType Container)) {
    New-Item $classesDir -ItemType Directory | Out-Null;
  }
  
  # List all source files
  $srcFiles = (Get-ChildItem $srcDir -Recurse -File | ForEach-Object {
    $_.FullName
  });

  $prevLocation = Get-Location;
  Set-Location $classesDir;
  
  # Create the MANIFEST.MF file
  if (-not (Test-Path $manifestFile -PathType Leaf)) {
    New-Item -Path $manifestFile -ItemType File | Out-Null;
    Set-Content -Path $manifestFile -Value $manifestContent;
  }

  Set-Location $prevLocation;
  
  Write-Output "Building...";
  # Step 1. Build the classes

  # write that list of source files to special argument file
  Set-Content -Path "srcList" -Value $srcFiles;
  # use that argument file as an argument
  javac -sourcepath src -d $classesDir "@srcList"
  # remove the argument file
  Remove-Item srcList;
  
  $prevLocation = Get-Location;
  Set-Location $classesDir;
  
  # Step 2. Package the JAR file
  jar -cfm $jarFileClassesRel $manifestFile .
  
  Set-Location $prevLocation;
}

function Run {
  Write-Output "Running the project...";
  Write-Output "";
  Write-Host "#######################################################" -ForegroundColor Blue;
  $output = (java -jar $jarFileAbs).Split("`n");
  $output | ForEach-Object {
    Write-Host $_ -ForegroundColor Blue;
  }
  Write-Host "#######################################################" -ForegroundColor Blue;
}


# Script scenario

if (-not (Check)) {
  Write-Host "Seems, Java bin/ directory is not in the PATH variable." -ForegroundColor Red;
  Write-Host "Exiting..." -ForegroundColor Red;
  exit;
}

if ($Clean) {
  Clean;
}

if (-not (Test-Path $jarFileAbs -PathType Leaf)) {
  Build;
} else {
  Write-Host "Project is alread built. Skipping building." -ForegroundColor Yellow;
}

if ($Run) {
  Run;
}

Write-Host "";
Write-Host "Done." -ForegroundColor Green;