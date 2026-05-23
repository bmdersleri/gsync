# Google Drive backup

Bu klasor, `/home/haytek/projects` dizinini Google Drive'a otomatik yedeklemek icin hazir dosyalari icerir.

## 1. Gereken paketler

```bash
sudo apt install rclone zstd
```

## 2. Google Drive baglantisi

```bash
rclone config
rclone lsd ismkirauto:
```

Bu makinedeki mevcut remote adi `ismkirauto` gorunuyor. Script varsayilan olarak bunu kullanir.
Farkli bir remote kullanmak isterseniz komut aninda `REMOTE=...` verin.

## 3. Script'i calistirilabilir yapin

```bash
chmod +x /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
```

## 4. Manuel test

```bash
/home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
```

Varsayilan olarak:

- Kaynak klasor: `/home/haytek/projects`
- Drive hedefi: `ismkirauto:backups/projects`
- Lokal gecici arsiv klasoru: `~/.cache/project-backups`
- Log dosyasi: `~/.local/state/project-backups/rclone.log`
- Saklanacak lokal arsiv sayisi: `30`

Arsiv sayisini degistirmek icin:

```bash
KEEP_LAST=15 /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
```

Farkli bir remote veya hedef klasor kullanmak icin:

```bash
REMOTE="digerremote:backups/projects" /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
```

## 5. systemd kurulumu

Kullanici unit dizinine kopyalayin:

```bash
mkdir -p ~/.config/systemd/user
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.service ~/.config/systemd/user/
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.timer ~/.config/systemd/user/
```

Etkinlestirin:

```bash
systemctl --user daemon-reload
systemctl --user enable --now gdrive-projects-backup.timer
systemctl --user list-timers gdrive-projects-backup.timer
```

Oturum kapali olsa da calissin isterseniz:

```bash
loginctl enable-linger haytek
```

## 6. Haric tutulan klasorler

Asagidaki agir veya yeniden olusturulabilir dizinler dahil edilmez:

- `.git`
- `.venv`, `venv`
- `node_modules`
- `dist`, `build`
- `.next`, `.nuxt`
- `.cache`
- `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.tox`

Listeyi `gdrive-projects-backup.exclude` dosyasindan degistirebilirsiniz.
