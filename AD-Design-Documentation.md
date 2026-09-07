# AD Design Documentation
## IT Solutions - Active Directory Project

This document captures how the environment is set up: the structure, the naming rules, and who has access to what. It's meant to be the go-to reference for understanding the environment without having to click through every object in Active Directory to piece it together.

---

## 1. OU & Group Structure

```
itsolutions.co.za
└── OU=Durban
    ├── OU=Computers
    ├── OU=Groups                          (all GG- security groups live here, flat)
    │   ├── GG-Management
    │   ├── GG-IT
    │   ├── GG-Operations
    │   ├── GG-Finance
    │   ├── GG-HR
    │   └── GG-Sales and Marketing
    └── OU=Users
        ├── OU=Management
        ├── OU=IT
        ├── OU=Operations
        ├── OU=Finance
        ├── OU=HR
        └── OU=Sales and Marketing
```

**Design notes:**
- All the security groups live in their own `Groups` OU, kept separate from the user accounts. This keeps access-control objects distinct from personnel records, and makes it easier later on to delegate "who can manage groups" separately from "who can manage users."
- Each department has its own OU under `Users`, holding only that department's accounts. It's worth noting that group membership, not OU placement, is what actually controls share and GPO access.

---

## 2. Naming Convention

Full reference: **`Naming-Convention-Document.md`**

Quick summary:
| Object | Format | Example |
|---|---|---|
| OU | `<Department>` (no prefix) | `Finance` |
| Group | `GG-<Department>` | `GG-Finance` |
| Share | `SH-<Department>` | `SH-Finance` |
| User (UPN) | `firstname.lastname@itsolutions.co.za` | `sine.zulu@itsolutions.co.za` |
| GPO | `GPO-<Dept>-<Purpose>` | `GPO-Finance-PasswordPolicy` |

---

## 3. Permission Matrix (Shared Folders)

| Share | Path | Group | Access Level |
|---|---|---|---|
| SH-Finance | `C:\Shares\SH-Finance` | GG-Finance | Modify |
| | | GG-HR | Read (HR needs visibility into the budget for payroll and headcount planning) |
| | | GG-Management | Read (oversight across all departments) |
| SH-HR | `C:\Shares\SH-HR` | GG-HR | Modify |
| | | GG-Finance | Read (Finance needs employee personal/salary information for payroll and budgeting) |
| | | GG-Management | Read (oversight) |
| SH-IT | `C:\Shares\SH-IT` | GG-IT | Modify |
| | | GG-Management | Read (oversight) |
| SH-Management | `C:\Shares\SH-Management` | GG-Management | Modify |
| SH-Operations | `C:\Shares\SH-Operations` | GG-Operations | Modify |
| | | GG-Management | Read (oversight) |
| SH-Sales and Marketing | `C:\Shares\SH-Sales and Marketing` | GG-Sales and Marketing | Modify |
| | | GG-Management | Read (oversight) |
| SH-CompanyWide | `C:\Shares\SH-CompanyWide` | GG-IT | Modify (IT publishes and updates company-wide content) |
| | | GG-Management, GG-Operations, GG-Finance, GG-HR, GG-Sales and Marketing | Read |

**Design decisions worth noting:**

No department has Full Control on its own share. Modify already covers everything needed for normal day-to-day work (read, write, delete), so Full Control, which allows permission and ownership changes, is intentionally withheld from every department group, including Management. This was a deliberate least-privilege decision, not something overlooked.

Full Control is reserved exclusively for the SysAdmin/IT Administrators group. No department group, including Management, and including IT's own regular `GG-IT` membership used for day-to-day work, is granted Full Control on any shared folder. Only accounts with elevated administrative rights (Domain Admins or designated SysAdmins) hold it, since permission changes, ownership changes, and structural changes to the shares should only ever happen deliberately, through an administrator, rather than by accident through a regular department user.

Two cross-department Read exceptions exist, and both have a clear business reason behind them: HR has Read access on `SH-Finance` (to see budget and financial data relevant to payroll and headcount planning), and Finance has Read access on `SH-HR` (to see employee personal and salary information needed for payroll and budgeting). Neither is a blanket "everyone can see everything" grant; each is scoped to exactly the one folder the relationship justifies.

Management is granted Read access to all departmental shared folders because their role involves overseeing and monitoring the activities of all departments. Read-only access gives them the visibility they need while preventing unnecessary modification or deletion of departmental data. This is a meaningfully different decision from giving Management elevated write or control rights, which was considered earlier in the project and specifically rejected.

The built-in `Users` / `Authenticated Users` group has been stripped from every department share. By default, Windows inherits broad read access for all domain users onto new folders, so this had to be identified and removed folder by folder (confirmed using the Effective Access tool), so that access is governed entirely by explicit `GG-` group membership rather than blanket inherited permissions.

`SH-CompanyWide` uses Read-only access for every department except IT, who has Modify so they can manage and publish shared company content on everyone's behalf. This avoids a situation where every department could overwrite shared company documents.

---

## 4. Detailed Justification for Cross-Department Access

**Management: Read access on all departmental shared folders**
Management is granted read access to all departmental shared folders because their role involves overseeing and monitoring the activities of all departments. Read-only access provides the necessary visibility while preventing unnecessary modification or deletion of departmental data.

**HR: Read access on SH-Finance**
HR is granted read access to the Finance shared folder because HR requires visibility into the company's budget and financial data to support payroll processing and headcount planning. This allows HR to make informed staffing decisions within the constraints of the approved budget, without being able to modify or delete Finance's records.

**Finance: Read access on SH-HR**
Finance is granted read access to the HR shared folder because Finance requires access to employee personal and salary information to accurately process payroll and support budgeting activities. Read-only access ensures Finance has the data it needs while leaving ownership and management of HR records solely with HR.

---

## 5. Verification Method

Access for any given user can be confirmed without needing to log in as them, using:
**Folder Properties > Security > Advanced > Effective Access tab > select user > View effective access.**

This was used, for example, to confirm that a Finance-department user (Sanele Ngcobo) had no residual access to `SH-Management` after the `Users` group was stripped from it.

---

## 6. Related Documents
- `Naming-Convention-Document.md`, the full naming rules
- `Troubleshooting-Issues-Log.md`, issues encountered and resolutions applied
- `New-DepartmentGroups-Final.ps1` and `Add-ExistingUsersToGroups.ps1`, the provisioning scripts
