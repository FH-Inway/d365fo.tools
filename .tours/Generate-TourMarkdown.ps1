# Generates a markdown file for a tour from a tour.json file
# Usage: Generate-TourMarkdown.ps1 -TourJsonPath <path to tour.json> -OutputPath <path to output markdown file>
# Example: Generate-TourMarkdown.ps1 -TourJsonPath .tours/tour.json -OutputPath .tours/tour.md

param(
  [string]$TourJsonPath,
  [string]$OutputPath
)

$Tour = Get-Content $TourJsonPath | ConvertFrom-Json
$TourMarkdown = "# $($Tour.title)`n`n"

$index = 1
foreach ($step in $Tour.steps) {
  $title = "Step $index"
  $directory = ""
  if ($step.title) {
    $title = $step.title
  }
  elseif ($step.Directory) {
    $title = $step.Directory
    $directory = $step.Directory
  }
  elseif ($step.File) {
    $title = $step.File
  }
  $TourMarkdown += "## $title`n`n"
  $description = $step.description -replace "\./", "../"
  $TourMarkdown += "$description`n`n"
    
  $index++
}

$TourMarkdown | Out-File $OutputPath -Encoding utf8