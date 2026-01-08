enum ColorEnum {
    red
    green
    blue
    yellow
}

class Participant {
    <# Define the class. Try constructors, properties, or methods. #>
    [string]$Name
    [int]$Age
    [ColorEnum]$Color
    [int]$Id

    Participant ([string]$name, [int]$age, [ColorEnum]$color, [int]$id) {
        $this.Name = $name
        $this.Age = $age
        $this.Color = $color
        $this.Id = $id
    }

    [string] ToString() {
        return "$($this.Name), $($this.Age), $($this.Color), $($this.Id)"
    }
}

function Get-UserData {
    [CmdletBinding()]
    #$MyUserListFile = "$PSScriptRoot\MyLabFile.csv"
    $MyUserListFile = ".\MyLabFile.csv"
    $csv = import-csv -path $MyUserListFile -Delimiter ","
    return $csv
}

function Get-CourseUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Name = '*',
        [Parameter(Mandatory=$false)]
        [int]$OlderThan = 65
    )
    Get-UserData | Where-Object {
        $_.Name -like "*$Name*" -and $_.Age -gt $OlderThan
    }
}

function Add-CourseUser {
    param (
        [ValidatePattern({"^[A-Z][a-z]*|\-|\s|[A-Z]|[a-z]"}, ErrorMessage = 'Name is in an incorrect format')]
        #[ValidatePattern({'^[A-Z][\w\-\s]*$'}, ErrorMessage = 'Name is in an incorrect format')]
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$false)]
        #[string]$dbFile = "$PSScriptRoot\MyLabFile.csv",
        [string]$dbFile = ".\MyLabFile.csv",
        [Parameter(Mandatory=$true)]
        [int]$Age,
        [Parameter(Mandatory=$true)]
        [ColorEnum]$Color,
        [Parameter(Mandatory=$false)]
        [int]$UserID = (Get-Random -Minimum 1000 -Maximum 9999)
    )
    $participant = [Participant]::new($Name, $Age, $Color, $UserID)

    $NewCSv = Get-Content $dbFile -Raw
    #$NewCSv += $participant.ToString()
    $NewCSv += $participant
    Set-Content -Value $NewCSv -Path $dbFile
    
    $updateddbfile = import-csv -Path $dbFile -Delimiter ","
    Write-Host "Added participant: $($participant.ToString())"
    Write-Host "Database updated, last row in csv is now:" -ForegroundColor $Color
    Write-Host "$($updateddbfile[-1])" -ForegroundColor $Color

    $($updateddbfile[-1])
}

function Remove-CourseUser {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param (
        [Parameter(Mandatory=$false)]
        #[string]$DatabaseFile = "$PSScriptRoot\MyLabFile.csv",
        [string]$DatabaseFile = ".\MyLabFile.csv",
        [Parameter(Mandatory=$false)]
        [switch]$runit = $false
    )
    $MyUserList = Get-Content -Path $DatabaseFile | ConvertFrom-Csv

    #$RemoveUser = $MyUserList | Out-ConsoleGridView -OutputMode Single
    $RemoveUser = $MyUserList | Out-GridView -OutputMode Single
    $MyUserList = $MyUserList | Where-Object {
        -not (
            $_.Name -eq $RemoveUser.Name -and
            $_.Age -eq $RemoveUser.Age -and
            $_.Color -eq $RemoveUser.Color -and
            $_.Id -eq $RemoveUser.Id
        )
    }
    $MyUserList = $MyUserList | ConvertTo-Csv -NoTypeInformation
    switch ($runit) {
        $false { Set-Content -Value $MyUserList -Path $DatabaseFile -WhatIf }
        $true { Set-Content -Value $MyUserList -Path $DatabaseFile }
        Default {}
    }
    #Set-Content -Value $MyUserList -Path $DatabaseFile -WhatIf
}