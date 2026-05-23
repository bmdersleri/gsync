# Google Drive backup

Bu klasor, `/home/haytek/projects` altindaki Git repolarini Google Drive'a proje bazli yedeklemek icin hazir dosyalari icerir.

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
Farkli bir remote kullanmak isterseniz komut aninda `REMOTE_BASE=...` verin.

## 3. Script'leri calistirilabilir yapin

```bash
chmod +x /home/haytek/projects/gdrive-sync/backup/*.sh
chmod +x /home/haytek/projects/gdrive-sync/install/*.sh
```

## 4. Tek repo manuel test

```bash
/home/haytek/projects/gdrive-sync/backup/gdrive-backup-repo.sh /home/haytek/projects/gdrive-sync
```

Varsayilan olarak:

- Kaynak repo: komutta verdiginiz repo yolu veya mevcut calisma dizini
- Drive hedefi: `ismkirauto:backups/projects/<repo-adi>.tar.zst`
- Lokal gecici arsiv klasoru: `~/.cache/project-backups/<repo-adi>.tar.zst`
- Log dosyasi: `~/.local/state/project-backups/rclone.log`

## 5. Tum repolari yedekleme

```bash
/home/haytek/projects/gdrive-sync/backup/gdrive-backup-all-repos.sh
```

Bu script `/home/haytek/projects` altinda `.git` klasoru olan her repoyu ayri ayri arsivler ve Drive'a yukler.
Varsayilan olarak `.git`, `.venv`, `venv`, `node_modules`, `dist`, `build`, `.next`, `.nuxt`, `.cache`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.tox`, `coverage` ve `.DS_Store` yedek disinda tutulur.
Calisma sonunda Drive hedefinde repo listesinde olmayan eski `.tar.zst` dosyalari silinir.

Farkli bir remote veya kok klasor kullanmak icin:

```bash
REMOTE_BASE="digerremote:backups/projects" PROJECTS_DIR="/home/haytek/projects" /home/haytek/projects/gdrive-sync/backup/gdrive-backup-all-repos.sh
```

## 6. Push sonrasi otomatik yedek

Git istemcisinde gercek bir `post-push` hook'u yoktur. Bu nedenle iki pratik secenek vardir.

### Secenek A: `git gsync-push`

Bu yontem gercekten "push basarili olursa sonra yedekle" davranisini verir:

```bash
/home/haytek/projects/gdrive-sync/install/install-git-alias.sh
git gsync-push
```

### Secenek B: `pre-push` hook

Bu yontem plain `git push` komutunu yakalar ama yedegi push'tan once alir:

```bash
/home/haytek/projects/gdrive-sync/install/install-pre-push-hooks.sh
```

## 7. systemd kurulumu

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
