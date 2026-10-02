#!/usr/bin/env bash
set -e

# ================= KUSTOMISASI VARIABEL =================
POOL_URL="pool.hashvault.pro:443"
WALLET_ADDRESS="478BC9CWHyN2dkBmgTxaFsMpBXRUWqvBN2mhK5gA4msPbXTLod6wjjvbAktb1zUPPdNwWLwdWz5kuXZYjDFCdWTg73TMshD"
POOL_PASSWORD="WorkerX-Ubuntu-AnnaQitty"
RIG_NAME="WorkerX-Ubuntu-AnnaQitty"
CURRENCY="monero"
INSTALL_DIR="/opt/xmr-stak"
CURRENT_USER=$(whoami)
# ========================================================

echo "=== 1. Menginstal Dependensi Sistem ==="
sudo apt update
sudo apt install -y build-essential cmake libhwloc-dev libssl-dev git libmicrohttpd-dev cron

echo "=== 2. Mengunduh dan Mengompilasi xmr-stak ==="
sudo rm -rf /tmp/xmr-stak
git clone https://github.com/fireice-uk/xmr-stak.git /tmp/xmr-stak
cd /tmp/xmr-stak
mkdir -p build && cd build
cmake .. -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF
make -j$(nproc)

echo "=== 3. Memindahkan Biner ke $INSTALL_DIR ==="
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r /tmp/xmr-stak/build/bin/* "$INSTALL_DIR/"
sudo chown -R "$CURRENT_USER":"$CURRENT_USER" "$INSTALL_DIR"
rm -rf /tmp/xmr-stak

echo "=== 4. Membuat Konfigurasi Pools Otomatis ==="
cat <<EOF > "$INSTALL_DIR/pools.txt"
"pool_list" :
[
  {"pool_address" : "$POOL_URL", "wallet_address" : "$WALLET_ADDRESS", "rig_id" : "$RIG_NAME", "pool_password" : "$POOL_PASSWORD", "use_nicehash" : false, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1 },
],
"currency" : "$CURRENCY",
EOF

# Jalankan 2 detik untuk generate config.txt dan cpu.txt jika belum ada
cd "$INSTALL_DIR"
timeout 2s ./xmr-stak || true

echo "=== 5. Optimasi Huge Pages Kernel ==="
sudo sysctl -w vm.nr_hugepages=128
if ! grep -q "vm.nr_hugepages" /etc/sysctl.conf; then
    echo "vm.nr_hugepages=128" | sudo tee -a /etc/sysctl.conf
fi

echo "=== 6. Membuat Systemd Service (Auto-Start saat Boot) ==="
sudo tee /etc/systemd/system/xmr-stak.service > /dev/null <<EOF
[Unit]
Description=xmr-stak Mining Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/xmr-stak
Restart=always
RestartSec=10
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable xmr-stak.service
sudo systemctl restart xmr-stak.service

echo "=== 7. Menambahkan Cronjob Watchdog ==="
CRON_CMD="systemctl is-active --quiet xmr-stak.service || systemctl restart xmr-stak.service"
# Menambahkan ke crontab user jika belum terdaftar
(crontab -l 2>/dev/null | grep -Fv "xmr-stak.service"; echo "*/5 * * * * $CRON_CMD") | crontab -

echo "======================================================"
echo "Instalasi selesai!"
echo "Status Service:"
sudo systemctl status xmr-stak.service --no-pager
echo "======================================================"
