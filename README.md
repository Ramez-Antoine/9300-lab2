# Simple Antivirus Daemon
## Overview
This project implements a simple antivirus daemon using Bash shell scripting on Ubuntu.
The antivirus monitors a directory for changes, scans files for suspicious extensions and keywords, and quarantines detected files.
A separate restore tool allows users to restore, permanently delete, or leave quarantined files.

## Project Structure
**antivirusd.s** - Antivirus monitoring script
**restore.sh** - Quarantine restore tool
**Makefile** - Project execution and setup
**README.md** - Project documentation
**/watched** - Monitored directory
**/quarantine** - Quarantined files

## Prerequisites
The following tools are required to run this project on Ubuntu:
Ubuntu/Linux: The operating system used to run the shell scripts.
**Bash:** Used to execute antivirusd.sh and restore.sh.
**GNU Make:** Used to run the project through the Makefile.
**GNU grep:** Used to detect suspicious keywords inside files.
**Core Utilities:** Provide commands such as ls, cp, rm, and mkdir.
**GNU diffutils:** Provide cmp and diff for detecting directory changes.
Installation
Open the Ubuntu terminal and update the package list:
sudo apt update
Install the required packages:
sudo apt install bash make grep coreutils diffutils
Verify Installation
Check that the required tools are installed:
bash --version
make --version
grep --version
cmp --version
If the commands display version information, the tools are installed successfully.
No additional third-party libraries are required.


## How to Run
**1. Open the Project Directory**
Open the Ubuntu terminal and navigate to the project folder:
cd ~/lab2
**2. Run the Antivirus**
To start the antivirus daemon, run:
make
Alternatively, run the script directly:
bash antivirusd.sh watched quarantine 5
The antivirus scans the monitored directory immediately, then checks for changes every 5 seconds. When a malicious file is detected, it is copied to the quarantine directory and deleted from the original directory.
To stop the antivirus, press Ctrl + C.
**3. Run the Restore Tool**
Make sure the antivirus daemon is stopped before running the restore tool.
Run:
make restore
Alternatively:
bash restore.sh watched quarantine
The program displays a numbered list of quarantined files. Select a file by entering its number.
Then choose one of the following options:
1 — Restore: Move the selected file back to the monitored directory.
2 — Delete: Permanently delete the selected file.
3 — Leave: Keep the file in quarantine and return to the list.
**4. Create the Quarantine Directory**
To create the quarantine directory if it does not exist, run:
make setup
The Makefile also performs this setup automatically before running the antivirus or restore tool.
**5. Important Notes**
Do not run the antivirus and restore scripts simultaneously.
Restored files may be detected again by the antivirus if they still match the malicious detection rules.
Use test files when testing the antivirus, since flagged files are removed from the monitored directory.


## Malicious Detection Rules
The antivirus identifies malicious files using two detection methods:
**1. Suspicious File Extensions**
The following extensions are considered malicious:
.exe
.bat
.vbs
.scr
.ps1
These extensions are hardcoded in the case statement inside the scan_files() function in antivirusd.sh.
**2. Suspicious Keywords**
The antivirus scans file contents for the following keywords:
virus
trojan
malware
worm
ransomware
These keywords are hardcoded in the grep -Eqi command inside the scan_files() function in antivirusd.sh.
The keyword search is case-insensitive, meaning uppercase and lowercase letters are treated equally.
**3. Detection and Quarantine**
A file is considered malicious if its extension matches any suspicious extension OR its content contains any suspicious keyword.
When a malicious file is detected, the antivirus copies it to the quarantine directory and removes the original file from the monitored directory.
Files that do not match either rule are left unchanged.



## Bonus 1: Cron Job

The `antivirus-cron.sh` script allows the antivirus to run automatically using Cron instead of a continuous loop.

### Prerequisites

- Ubuntu/Linux operating system.
- Cron service installed and running.
- `antivirus-cron.sh` file in the project directory.
- A monitored directory named `watched`.
- A quarantine directory, created automatically if needed.

### Installation and Configuration

**Step 1:** Install Cron:

`sudo apt install cron`

**Step 2:** Enable and start the Cron service:

`sudo systemctl enable --now cron`

**Step 3:** Verify that Cron is running:

`systemctl is-active cron`

The expected output is `active`.

**Step 4:** Open the Crontab editor:

`crontab -e`

**Step 5:** Add the following line to run the antivirus every minute at approximately second 23:

`* * * * * /bin/sleep 23 && /bin/bash /home/kareneantoine/lab2/antivirus-cron.sh >> /home/kareneantoine/lab2/cron.log 2>&1`

Cron starts the job every minute, and `sleep 23` delays the scan by 23 seconds.

The output and errors are redirected to `cron.log`.

**Step 6:** Save the Crontab and verify the configuration:

`crontab -l`

### Testing the Cron Job

Create a test file:

`echo "virus" > watched/cron_test.txt`

Wait approximately 90 seconds, then check the quarantine directory:

`ls quarantine`

The malicious test file should be moved to quarantine automatically.

To view the logs:

`cat cron.log`

### Third Friday of Every Month

To run the antivirus on the third Friday of each month at 12:31 AM, use:

`31 0 15-21 * * [ "$(/bin/date +\%u)" -eq 5 ] && /bin/bash /home/kareneantoine/lab2/antivirus-cron.sh`

The expression selects dates from the 15th to the 21st, and the additional condition ensures that the day is Friday.

### Disable the Cron Job

Run:

`crontab -e`

Add `#` at the beginning of the antivirus Cron entry to disable it temporarily.

---

## Bonus 2: Whitelist

The whitelist prevents restored files from being detected as malicious again.

### How It Works

The whitelist is stored in a file named `whitelist.txt` inside the project directory.

When a user restores a file using Option 1 in `restore.sh`, the filename is added to `whitelist.txt` after a successful restore.

During scanning, `antivirusd.sh` checks the whitelist before applying the malicious detection rules.

The script uses `grep -Fxq` to check whether the filename matches an entry in the whitelist.

If the filename is found, the file is skipped, even if it has a suspicious extension or contains a suspicious keyword.

### Whitelist Persistence

The whitelist is stored in a text file, so its contents remain available even after stopping or restarting the antivirus daemon.

### Testing the Whitelist

1. Create a test file in the quarantine directory:

   `touch quarantine/bonus_test.exe`

2. Run the restore tool:

   `bash restore.sh watched quarantine`

3. Select `bonus_test.exe` and choose Option 1 to restore it.

4. Check the whitelist:

   `cat whitelist.txt`

5. Run the antivirus:

   `bash antivirusd.sh watched quarantine 5`

6. Verify that the restored file remains inside `watched` and is not quarantined again.

### Note

The whitelist identifies safe files by their filenames rather than their contents. Therefore, another file with the same name would also be considered whitelisted.
