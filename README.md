[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange.svg?style=flat&logo=ubuntu)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash%20Script-4EAA25.svg?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Systemd](https://img.shields.io/badge/Service-Systemd%20Managed-blue.svg)](https://systemd.io/)

A production-ready Bash automation script to compile, configure, run, and maintain **xmr-stak** on Ubuntu servers. Designed for resilience: includes native `systemd` daemon management, automated hugepages allocation, and a periodic watchdog cronjob.

---

## 🚀 Key Features

- **Automated Toolchain Compilation:** Fetches dependencies (`cmake`, `hwloc`, `openssl`) and builds `xmr-stak` from source using maximum CPU cores (`make -j$(nproc)`).
- **Zero-Interaction Deployment:** Injects pool credentials, wallet address, and runtime configurations silently—no interactive terminal prompts required.
- **Kernel Tuning:** Automatically configures and persists `vm.nr_hugepages=128` in `/etc/sysctl.conf` for maximum hashing throughput.
- **Fail-Safe & Auto-Restart:** Integrates natively with `systemd` (`Restart=always`) to immediately recover from crashes and launch automatically on system reboot.
- **Watchdog Fallback:** Installs a cronjob check every 5 minutes to guarantee service continuity.

---

## 📋 System Requirements

| Specification | Requirement |
| :--- | :--- |
| **Operating System** | Ubuntu 20.04 LTS, 22.04 LTS, or newer |
| **Permissions** | Sudo / Root privileges |
| **Architecture** | x86_64 / amd64 |

---

## ⚡ Quick Start

### 1. Clone the Repository
```bash
git clone [https://github.com/](https://github.com/)<your-username>/xmr-stak-autoinstaller.git
cd xmr-stak-autoinstaller
2. Configure CredentialsEdit the environment variables inside setup_xmr_autostart.sh to match your pool and payout parameters:Bash# ================= KUSTOMISASI VARIABEL =================
POOL_URL="pool.supportxmr.com:3333"
WALLET_ADDRESS="48edfHu7V9Z84YzzMa6fUueoXZ6UxTue3Q4Ywbndv2ZsNoWBWB74JyEO84f5P4Q"
POOL_PASSWORD="x"
RIG_NAME="UbuntuWorker"
# ========================================================
3. Execute the InstallerMake the script executable and run:Bashchmod +x setup_xmr_autostart.sh
./setup_xmr_autostart.sh
🛠️ Management & OperationsThe process runs fully headless as a background service managed by systemd.Check Real-Time Service StatusBashsudo systemctl status xmr-stak.service
Stream Live LogsBashsudo journalctl -u xmr-stak.service -f
Lifecycle CommandsActionCommandStop Minersudo systemctl stop xmr-stak.serviceStart Minersudo systemctl start xmr-stak.serviceRestart Minersudo systemctl restart xmr-stak.serviceDisable on Bootsudo systemctl disable xmr-stak.service📁 File StructurePlaintext/opt/xmr-stak/
├── xmr-stak            # Compiled binary executable
├── pools.txt           # Generated pool connection settings
├── config.txt          # Global miner configuration
└── cpu.txt             # CPU thread and affinity assignment
To modify CPU core usage or thread allocation, adjust /opt/xmr-stak/cpu.txt and reload the service:Bashsudo systemctl restart xmr-stak.service
⚠️ DisclaimerThis repository is built for educational, diagnostic, and server benchmarking purposes. Ensure you have authorization before running high-utilization background processes on shared or cloud infrastructure.📄 LicenseThis project is open-source and released under the MIT License.
---

<ElicitationsGroup message="Perlu tambahan aset pelengkap repositori?">
  <Elicitation label="Buatkan file LICENSE MIT standar" query="Buatkan template file LICENSE MIT untuk repositori GitHub ini"/>
  <Elicitation label="Buatkan skrip uninstaller untuk repo ini" query="Buatkan file uninstall.sh untuk membersihkan service, cron, dan file biner"/>
</ElicitationsGroup>
