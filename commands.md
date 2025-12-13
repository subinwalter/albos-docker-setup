# Commands Reference

## Albos Setup

### Export Database from Old Server
```bash
mysqldump -u wp_albos -p wordpress > albos_dump.sql
# DB pass: <DB_PASSWORD>
```

### Download Files from Old Server
```bash
# Download database dump
scp cherian@Blog:/home/cherian/albos_dump.sql .

# Sync WordPress files
rsync -avz --delete --exclude='wp-content/cache' cherian@Blog:/sites/alittlebitofspice.com/public/ ./public/

# Download SSL certificates
scp -r cherian@Blog:/etc/letsencrypt/ ./letsencrypt/
```

### Local Setup Configuration
- Change `user.ini` path: `/sites/alittlebitofspice/public` → `/var/www/html`


### Import Database (Local)
```bash
docker-compose exec -T db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress < albos_dump.sql
```

### Update WordPress URLs (Local)
```bash
docker-compose exec db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress -e "UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'http://localhost:8080' WHERE option_name = 'home';"
```

### Update WordPress URLs (Production)
```bash
docker-compose exec db mysql -u wordpress -p<WORDPRESS_PASSWORD> wordpress -e "UPDATE wp_options SET option_value = 'https://alittlebitofspice.com' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'https://alittlebitofspice.com' WHERE option_name = 'home';"
```

### Restart Containers
```bash
docker-compose down && docker-compose up -d
```

---

## GigPeppers Setup

### Export Database from Old Server
```bash
mysqldump -u wp_ggpprs -p wordpress_ggpprs > gigpeppers_dump.sql
```

### Download Files from Old Server
```bash
# Download database dump
scp cherian@Blog:/home/cherian/gigpeppers_dump.sql .

# Sync WordPress files
rsync -avz --delete --exclude='wp-content/cache' cherian@Blog:/sites/gigpeppers.com/public/ ./public_gp/
```

### Create Database and User
```bash
# Create database
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "CREATE DATABASE wordpress_ggpprs;"

# Create user and grant privileges
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "CREATE USER 'wp_ggpprs'@'%' IDENTIFIED BY '<GIGPEPPERS_PASSWORD>';"
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "GRANT ALL PRIVILEGES ON wordpress_ggpprs.* TO 'wp_ggpprs'@'%';"
docker-compose exec db mysql -u root -p<ROOT_PASSWORD> -e "FLUSH PRIVILEGES;"
```

### Import Database
```bash
docker-compose exec -T db mysql -u wp_ggpprs -p<GIGPEPPERS_PASSWORD> wordpress_ggpprs < gigpeppers_dump.sql
```

### Update WordPress URLs
```bash
docker-compose exec db mysql -u wp_ggpprs -p<GIGPEPPERS_PASSWORD> wordpress_ggpprs -e "UPDATE wp_options SET option_value = 'https://www.gigpeppers.com' WHERE option_name = 'siteurl'; UPDATE wp_options SET option_value = 'https://www.gigpeppers.com' WHERE option_name = 'home';"
```

### View Logs
```bash
docker-compose logs -f wordpress_gp
```

---

## Server Deployment

### Upload Files to New Server
```bash
# Configuration files
scp /Users/subin/albos-docker-setup/docker-compose-server.yml new-albos-docker:~/docker-compose.yml
scp /Users/subin/albos-docker-setup/nginx_server.conf new-albos-docker:~/nginx.conf
scp /Users/subin/albos-docker-setup/.env new-albos-docker:~/
scp /Users/subin/albos-docker-setup/Dockerfile new-albos-docker:~/
scp /Users/subin/albos-docker-setup/custom-php.ini new-albos-docker:~/
scp /Users/subin/albos-docker-setup/Dockerfile.gigpeppers new-albos-docker:~/
scp /Users/subin/albos-docker-setup/entrypoint.sh new-albos-docker:~/
scp /Users/subin/albos-docker-setup/entrypoint-gigpeppers.sh new-albos-docker:~/

# Database dumps
scp -C /Users/subin/albos-docker-setup/albos_dump.sql new-albos-docker:~/
scp -C /Users/subin/albos-docker-setup/gigpeppers_dump.sql new-albos-docker:~/

# WordPress files
rsync -avz /Users/subin/albos-docker-setup/public/ new-albos-docker:~/public/
rsync -avz /Users/subin/albos-docker-setup/public_gp/ new-albos-docker:~/public_gp/
```

---

## Ubuntu Server Setup

### Create User
```bash
sudo adduser wordpress
sudo usermod -aG sudo wordpress
```

### Install Docker
```bash
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

# Create docker-compose alias
echo 'alias docker-compose="docker compose"' >> ~/.bashrc && source ~/.bashrc
```

---

## SSL Setup

### Transfer SSL Certificates from Old Server
```bash
# Create archive on old server
ssh cherian@Blog "sudo tar -czf /tmp/letsencrypt.tar.gz -C /etc letsencrypt"

# Download to local
scp cherian@Blog:/tmp/letsencrypt.tar.gz .
tar -xzf letsencrypt.tar.gz

# Upload to new server
tar -czf letsencrypt.tar.gz letsencrypt/
scp letsencrypt.tar.gz new-albos-docker:~/
ssh new-albos-docker "sudo tar -xzf ~/letsencrypt.tar.gz -C /etc/"
```

---

## Datadog Setup

### Create Datadog Database User
```bash
# Create user and grant basic privileges
docker compose exec db mysql -uroot -p<ROOT_PASSWORD> -e "
CREATE USER IF NOT EXISTS 'datadog'@'%' IDENTIFIED BY '<DATADOG_PASSWORD>';
GRANT REPLICATION CLIENT ON *.* TO 'datadog'@'%';
GRANT PROCESS ON *.* TO 'datadog'@'%';
GRANT SELECT ON performance_schema.* TO 'datadog'@'%';
FLUSH PRIVILEGES;
"

# Grant additional privileges
docker compose exec db mysql -uroot -p<ROOT_PASSWORD> -e "
GRANT SELECT ON mysql.* TO 'datadog'@'%';
GRANT SELECT ON performance_schema.* TO 'datadog'@'%';
FLUSH PRIVILEGES;
"
```
