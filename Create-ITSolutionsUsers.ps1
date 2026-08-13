# =====================================================================
# Create-ITSolutionsUsers.ps1
#
# WHAT THIS SCRIPT DOES:
#   Reads itsolutions_users.csv and creates one Active Directory user
#   account for every row, in the correct OU.
#
# BEFORE YOU RUN THIS:
#   1. Run this on your Domain Controller (or a machine with the
#      "Active Directory module for Windows PowerShell" / RSAT tools
#      installed).
#   2. Open PowerShell AS ADMINISTRATOR (right-click -> Run as Administrator).
#   3. Make sure all the OUs referenced in the CSV's OU column already
#      exist (Management, IT, Operations, Finance, HR, Sales and Marketing).
#   4. Put itsolutions_users.csv in the SAME FOLDER as this script,
#      or change the $CsvPath line below to point to wherever it is.
#
# HOW TO RUN IT:
#   1. Save this file as Create-ITSolutionsUsers.ps1
#   2. In PowerShell, go to the folder where you saved it, e.g:
#        cd C:\Scripts
#   3. Run it:
#        .\Create-ITSolutionsUsers.ps1
#
# NOTE: Every account is created with the SAME temporary password
#       (set below) and each user is forced to change it at first
#       logon. That's normal practice for new accounts.
# =====================================================================

# ---- STEP 1: Load the Active Directory module ----
Import-Module ActiveDirectory

# ---- STEP 2: Settings you might want to change ----

# Path to your CSV file (must be in the same folder as this script,
# unless you type the full path here instead)
$CsvPath = ".\itsolutions_users.csv"

# The domain part used for login names, e.g. user@itsolutions.co.za
$EmailDomain = "itsolutions.co.za"

# Temporary password given to every new user (must meet your domain's
# password policy - this one has upper, lower, number and symbol)
$TempPassword = "ITSolutions@2026"

# ---- STEP 3: Import the CSV ----
$Users = Import-Csv -Path $CsvPath

# Convert the temp password into the secure format AD requires
$SecurePassword = ConvertTo-SecureString $TempPassword -AsPlainText -Force

# ---- STEP 4: Loop through every row in the CSV and create the user ----
foreach ($User in $Users) {

    # Build a logon name like "thabo.ndlovu" from First + Last name
    $SamAccountName = ($User.FirstName + "." + $User.LastName) -replace ' ', '' -replace "'", ""
    $SamAccountName = $SamAccountName.ToLower()

    $UserPrincipalName = "$SamAccountName@$EmailDomain"
    $DisplayName       = "$($User.FirstName) $($User.LastName)"

    # Check if the user already exists, so we don't create duplicates
    # if you run the script more than once
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "SKIPPED (already exists): $DisplayName" -ForegroundColor Yellow
    }
    else {
        try {
            New-ADUser `
                -Name                  $DisplayName `
                -GivenName             $User.FirstName `
                -Surname               $User.LastName `
                -SamAccountName        $SamAccountName `
                -UserPrincipalName     $UserPrincipalName `
                -Department            $User.Department `
                -Office                $User.Office `
                -Title                 $User.JobTitle `
                -Path                  $User.OU `
                -AccountPassword       $SecurePassword `
                -Enabled               $true `
                -ChangePasswordAtLogon $true

            Write-Host "CREATED: $DisplayName -> $SamAccountName" -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED: $DisplayName - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`nDone. Check the messages above for anything marked FAILED or SKIPPED." -ForegroundColor Cyan
