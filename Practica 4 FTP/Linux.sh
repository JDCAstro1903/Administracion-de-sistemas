sudo apt install vsftpd -y

sudo groupadd reprobados
sudo groupadd recursadores

sudo mkdir -p /srv/ftp/
sudo mkdir -p /srv/ftp/publico
sudo mkdir -p /srv/ftp/reprobados
sudo mkdir -p /srv/ftp/recursadores
sudo mkdir -p /srv/ftp/usuarios
sudo mkdir -p /srv/ftp/public/
sudo mkdir -p /srv/ftp/public/publico

mount --bind /srv/ftp/public/publico /srv/ftp/publico
echo "/srv/ftp/public/publico /srv/ftp/publico none bind 0 0" | sudo tee -a /etc/fstab

sudo chmod -R 777 /srv/ftp/publico
sudo chmod -R 755 /srv/ftp/usuarios
sudo chown -R :reprobados /srv/ftp/reprobados
sudo chmod -R 770 /srv/ftp/reprobados
sudo chown -R :recursadores /srv/ftp/recursadores
sudo chmod -R 770 /srv/ftp/recursadores

cat <<EOF | sudo tee /etc/vsftpd.conf
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
anon_root=/srv/ftp/public

chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=/srv/ftp/usuarios/\$USER

pasv_min_port=30000
pasv_max_port=30100
EOF

sudo ufw allow 20,21/tcp
sudo ufw allow 30000:31000/tcp
sudo ufw enable

sudo systemctl restart vsftpd
sudo systemctl enable vsftpd