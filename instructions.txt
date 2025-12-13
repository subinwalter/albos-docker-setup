mysqldump -u wp_albos -p wordpress > albos_dump.sql

DB pass: <DB_PASSWORD>

scp cherian@Blog:/home/cherian/albos_dump.sql .

rsync -avz --delete --exclude='wp-content/cache' cherian@Blog:/sites/alittlebitofspice.com/public/ ./public/

scp -r cherian@Blog:/etc/letsencrypt/ ./letsencrypt/


Change

user.ini to  /sites/alittlebitofspice/public ---> /var/www/html
change DB password in wp-config.php

Fixed wp-config.php database connection issues:
- Changed DB_USER from 'wp_albos' to 'wordpress'
- Changed DB_HOST from 'localhost' to 'db'
- Added isset() check for HTTP_X_FORWARDED_PROTO to prevent PHP warning

Restart containers: docker-compose down && docker-compose up -d


docker-compose exec -T db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress < albos_dump.sql

Update WordPress URLs:
docker-compose exec db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress -e "UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'home';"


scp /Users/subin/albos-docker-setup/docker-compose-server.yml new-albos-docker:~/docker-compose.yml
scp /Users/subin/albos-docker-setup/nginx_server.conf new-albos-docker:~/nginx.conf
scp /Users/subin/albos-docker-setup/.env new-albos-docker:~/
scp /Users/subin/albos-docker-setup/Dockerfile new-albos-docker:~/
scp /Users/subin/albos-docker-setup/custom-php.ini new-albos-docker:~/
scp /Users/subin/albos-docker-setup/Dockerfile.gigpeppers new-albos-docker:~/
scp /Users/subin/albos-docker-setup/entrypoint.sh new-albos-docker:~/
scp /Users/subin/albos-docker-setup/entrypoint-gigpeppers.sh new-albos-docker:~/

scp -C /Users/subin/albos-docker-setup/albos_dump.sql new-albos-docker:~/
scp -C /Users/subin/albos-docker-setup/gigpeppers_dump.sql new-albos-docker:~/

rsync -avz /Users/subin/albos-docker-setup/public/ new-albos-docker:~/public/
rsync -avz /Users/subin/albos-docker-setup/public_gp/ new-albos-docker:~/public_gp/


Ubuntu machine commands


sudo adduser wordpress
sudo usermod -aG sudo wordpress

# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

echo 'alias docker-compose="docker compose"' >> ~/.bashrc && source ~/.bashrc


docker-compose exec db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress -e "UPDATE wp_options SET option_value = 'https://alittlebitofspice.com' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'https://alittlebitofspice.com' WHERE option_name = 'home';"


# Steps for Gigpeppers
rsync -avz --delete --exclude='wp-content/cache' cherian@Blog:/sites/gigpeppers.com/public/ ./public_gp/


mysqldump -u wp_ggpprs -p wordpress_ggpprs > gigpeppers_dump.sql

scp cherian@Blog:/home/cherian/gigpeppers_dump.sql .



# Create database
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "CREATE DATABASE wordpress_ggpprs;"

# Create user and grant privileges
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "CREATE USER 'wp_ggpprs'@'%' IDENTIFIED BY '<GIGPEPPERS_PASSWORD>';"
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "GRANT ALL PRIVILEGES ON wordpress_ggpprs.* TO 'wp_ggpprs'@'%';"
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "FLUSH PRIVILEGES;"

# import db dump
docker-compose exec -T db mysql -u wp_ggpprs -p<GIGPEPPERS_PASSWORD> wordpress_ggpprs < gigpeppers_dump.sql

# change siteurl etc
docker-compose exec db mysql -u wp_ggpprs -p<GIGPEPPERS_PASSWORD> wordpress_ggpprs -e "UPDATE wp_options SET option_value = 'https://www.gigpeppers.com' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'https://www.gigpeppers.com' WHERE option_name = 'home';"

docker-compose logs -f wordpress_gp


# SSL setup

ssh cherian@Blog "sudo tar -czf /tmp/letsencrypt.tar.gz -C /etc letsencrypt"
scp cherian@Blog:/tmp/letsencrypt.tar.gz .
tar -xzf letsencrypt.tar.gz

tar -czf letsencrypt.tar.gz letsencrypt/
scp letsencrypt.tar.gz new-albos-docker:~/
ssh new-albos-docker "sudo tar -xzf ~/letsencrypt.tar.gz -C /etc/"


# Datadog DB access

docker compose exec db mysql -uroot -p<ROOT_PASSWORD> -e "
CREATE USER IF NOT EXISTS 'datadog'@'%' IDENTIFIED BY '<DATADOG_PASSWORD>';
GRANT REPLICATION CLIENT ON *.* TO 'datadog'@'%';
GRANT PROCESS ON *.* TO 'datadog'@'%';
GRANT SELECT ON performance_schema.* TO 'datadog'@'%';
FLUSH PRIVILEGES;
"

docker compose exec db mysql -uroot -p<ROOT_PASSWORD> -e "
GRANT SELECT ON mysql.* TO 'datadog'@'%';
GRANT SELECT ON performance_schema.* TO 'datadog'@'%';
FLUSH PRIVILEGES;
"
