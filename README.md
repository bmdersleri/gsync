# gsync

`gsync`, `/home/haytek/projects` dizinini Google Drive'a yedeklemek icin hazirlanmis kucuk bir otomasyon projesidir.

## Icerik

- `backup/gdrive-projects-backup.sh`: Arsiv olusturur ve Google Drive'a yukler
- `backup/gdrive-projects-backup.service`: systemd kullanici servisi
- `backup/gdrive-projects-backup.timer`: Zamanlanmis otomatik calistirma
- `backup/gdrive-projects-backup.exclude`: Yedekleme disinda tutulacak dosya ve klasorler

## Hizli baslangic

```bash
sudo apt install rclone zstd
rclone config
rclone lsd ismkirauto:
chmod +x /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
/home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.sh
```

Varsayilan hedef:

```text
ismkirauto:backups/projects
```

## Otomatik calistirma

```bash
mkdir -p ~/.config/systemd/user
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.service ~/.config/systemd/user/
cp /home/haytek/projects/gdrive-sync/backup/gdrive-projects-backup.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now gdrive-projects-backup.timer
```

Daha ayrintili bilgi icin [backup/README.md](./backup/README.md) dosyasina bakin.
