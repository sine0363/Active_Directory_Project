# =====================================================================
# Create-ITSolutionsOUs.ps1  (simple version - one explicit command per OU)
#
# WHAT THIS SCRIPT DOES:
#   Creates every OU needed for itsolutions.co.za, written out one
#   command at a time so it's easy to read, edit, or copy/paste
#   individual lines if you only need to create one OU.
#
# BEFORE YOU RUN THIS:
#   1. Run on your Domain Controller (or a machine with RSAT AD tools).
#   2. Open PowerShell AS ADMINISTRATOR.
#   3. Run this BEFORE Create-ITSolutionsUsers.ps1.
#
# HOW TO RUN IT:
#   cd C:\Scripts
#   .\Create-ITSolutionsOUs.ps1
#
# NOTE: If you run this twice, any OU that already exists will show an
# error like "An attempt was made to add an object to the directory
# with a name that is already in use" - that's expected and safe to
# ignore, it just means that OU is already there.
# =====================================================================

Import-Module ActiveDirectory

# ---- Top level ----
New-ADOrganizationalUnit -Name "Durban" -Path "DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true

# ---- Second level (under Durban) ----
New-ADOrganizationalUnit -Name "Computers" -Path "OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Groups"    -Path "OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Users"     -Path "OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true

# ---- Department OUs (under Users) ----
New-ADOrganizationalUnit -Name "Management"          -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "IT"                  -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Operations"          -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Finance"             -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "HR"                  -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Sales and Marketing" -Path "OU=Users,OU=Durban,DC=itsolutions,DC=co,DC=za" -ProtectedFromAccidentalDeletion $true

Write-Host "`nDone creating OUs." -ForegroundColor Cyan
