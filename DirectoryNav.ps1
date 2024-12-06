param (
    [string]$AddPath,
    [switch]$ShowPaths,
    [switch]$ShowHistory,
    [switch]$FindWord
)

$saveFilePath = "$env:USERPROFILE\Documents\SavedPaths.txt"

if (-not (Test-Path -Path $saveFilePath)) {
    New-Item -Path $saveFilePath -ItemType File
}

function Add-Path {
    param (
        [string]$Path
    )
    Add-Content -Path $saveFilePath -Value $Path
    Write-Host "Directory path saved: $Path"
}

function Show-Paths {
    $savedPaths = Get-Content -Path $saveFilePath
    $pageSize = 3
    $currentPage = 0
    $totalPages = [math]::Ceiling($savedPaths.Count / $pageSize)

    while ($true) {
        Clear-Host
        Write-Host "Page $($currentPage + 1) of $totalPages"

        for ($i = $currentPage * $pageSize; $i -lt [math]::Min(($currentPage + 1) * $pageSize, $savedPaths.Count); $i++) {
            Write-Host "$($i). $($savedPaths[$i])"
        }

        $userInput = Read-Host "Enter a number to select a path, 'n' for next page, 'p' for previous page, or 'q' to quit"

        if ($userInput -eq 'q') {
            break
        } elseif ($userInput -eq 'n') {
            if ($currentPage -lt $totalPages - 1) {
                $currentPage++
            } else {
                Write-Host "You're already on the last page."
            }
        } elseif ($userInput -eq 'p') {
            if ($currentPage -gt 0) {
                $currentPage--
            } else {
                Write-Host "You're already on the first page."
            }
        } elseif ($userInput -match '^\d+$' -and [int]$userInput -ge 0 -and [int]$userInput -lt $savedPaths.Count) {
            $selectedPath = $savedPaths[$userInput]
            Write-Host "You selected: $selectedPath"
            Set-Location -Path $selectedPath
            Write-Host "Navigated to: $selectedPath"
            Start-Process explorer "$selectedPath"
            break
        } else {
            Write-Host "Invalid selection. Please try again."
        }
    }
}

function Show-PathSaver-History {
    $history = Get-History | Where-Object { $_.CommandLine -like "*PathSaver.ps1*" } | Select-Object -Last 3
    $history | Format-Table -AutoSize
}

if ($AddPath) {
    Add-Path -Path $AddPath
} elseif ($ShowPaths) {
    Show-Paths
} elseif ($ShowHistory) {
    Show-PathSaver-History
} else {
    Write-Host "Please provide a valid action: -AddPath, -ShowPaths, -ShowHistory, or -FindWord."
}
