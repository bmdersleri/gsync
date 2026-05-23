# gsync

`gsync`, `/home/haytek/projects` altindaki Git repolarini proje bazli sikistirip Google Drive'a yuklemek icin hazirlanmis kucuk bir otomasyon projesidir.

## Icerik

- `backup/gdrive-backup-repo.sh`: Tek bir Git reposunu arsivleyip Drive'a yukler
- `backup/gdrive-backup-all-repos.sh`: Tum Git repolarini tek tek yedekler
- `backup/gdrive-projects-backup.service`: systemd kullanici servisi
- `backup/gdrive-projects-backup.timer`: Zamanlanmis otomatik calistirma
- `install/install-git-alias.sh`: `git gsync-push` alias'ini kurar
- `install/install-pre-push-hooks.sh`: Dilersen mevcut repolara `pre-push` hook kurar

Varsayilan olarak `.git`, `.venv`, `venv`, `node_modules`, `dist`, `build`, `.next`, `.nuxt`, `.cache`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.tox`, `coverage` ve `.DS_Store` yedek disinda tutulur.

## Hizli baslangic

```bash
sudo apt install rclone zstd
rclone config
rclone lsd ismkirauto:
chmod +x /home/haytek/projects/gdrive-sync/backup/*.sh
/home/haytek/projects/gdrive-sync/backup/gdrive-backup-all-repos.sh
```

Varsayilan hedef:

```text
ismkirauto:backups/projects/<repo-adi>.tar.zst
```

## Push sonrasi yedek

Git'te gercek bir istemci `post-push` hook'u olmadigi icin iki secenek vardir:

```bash
/home/haytek/projects/gdrive-sync/install/install-git-alias.sh
git gsync-push
```

Bu komut once normal `git push` calistirir, basarili olursa sadece bulundugun repo icin yeni arsivi Drive'a gonderir ve ayni dosya adini kullanarak eski surumu ezer.

Istersen dogrudan tek repo de test edebilirsin:

```bash
/home/haytek/projects/gdrive-sync/backup/gdrive-backup-repo.sh /home/haytek/projects/gdrive-sync
```

## Zamanlanmis toplu yedek

```bash
mkdir -p ~/.config/systemd/user
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.service ~/.config/systemd/user/
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now gdrive-projects-backup.timer
```

Toplu yedekleme sonunda Drive hedefinde artik mevcut olmayan repolara ait eski `.tar.zst` dosyalari da temizlenir.

Daha ayrintili bilgi icin [backup/README.md](./backup/README.md) dosyasina bakin.
