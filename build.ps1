param(
  [switch] $Run = $false,
  [switch] $Clean = $false
)

$targetDir = "target";
$classesDir = (Join-Path $targetDir "classes");

$manifestFile = "MANIFEST.MF";
$manifestContent = "Main-Class: helloworld.App";

$jarFile = "hello-world.jar";
$jarFileClassesRel = (Join-Path ".." $jarFile);
$jarFileAbs = (Join-Path $targetDir $jarFile);

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
  
  $prevLocation = Get-Location;
  Set-Location $classesDir;
  
  if (-not (Test-Path $manifestFile -PathType Leaf)) {
    New-Item -Path $manifestFile -ItemType File | Out-Null;
    Set-Content -Path $manifestFile -Value $manifestContent;
  }
  
  Set-Location $prevLocation;
  
  Write-Output "Building...";
  javac -sourcepath src -d $classesDir src\main\java\helloworld\*.java
  
  $prevLocation = Get-Location;
  Set-Location $classesDir;
  
  jar -cfm $jarFileClassesRel $manifestFile .
  
  Set-Location $prevLocation;
}

function Run {
  Write-Output "Running the project...";
  Write-Output "";
  Write-Host "#######################################################" -ForegroundColor Blue;
  $output = java -jar $jarFileAbs
  Write-Host $output -ForegroundColor Blue;

  Write-Host "#######################################################" -ForegroundColor Blue;
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