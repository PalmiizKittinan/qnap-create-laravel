#!/bin/bash
# create-laravel.sh - Modern Dockerized Laravel + Nginx + MySQL + phpMyAdmin Generator

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

get_php_version() {
    local laravel_ver=$1
    case $laravel_ver in
        12.*|^12) echo "8.2" ;;
        11.*|^11) echo "8.2" ;;
        10.*|^10) echo "8.1" ;;
        9.*|^9)   echo "8.1" ;;
        8.*|^8)   echo "8.0" ;;
        7.*|^7)   echo "7.4" ;;
        *) echo "8.2" ;;
    esac
}

show_usage() {
    echo "Usage: $0 <project-name> [laravel-version] [--enable-docker]"
    echo ""
    echo "Examples:"
    echo "  $0 my-project"
    echo "  $0 my-project 11.*"
    echo "  $0 my-project 11.* --enable-docker"
}

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

PROJECT_NAME=$1
LARAVEL_VERSION=""
ENABLE_DOCKER=false

for arg in "$@"; do
    if [[ "$arg" == "--enable-docker" ]]; then
        ENABLE_DOCKER=true
    elif [[ "$arg" != "$PROJECT_NAME" ]]; then
        LARAVEL_VERSION="$arg"
    fi
done

if [ -n "$LARAVEL_VERSION" ]; then
    PHP_VERSION=$(get_php_version "$LARAVEL_VERSION")
    DISPLAY_LARAVEL_VERSION="$LARAVEL_VERSION"
else
    PHP_VERSION="8.2"
    DISPLAY_LARAVEL_VERSION="Latest (12.x)"
fi

echo -e "${BOLD}${BLUE}================================================${RESET}"
echo -e "${BOLD}${GREEN} 🚀 QNAP Laravel + Nginx + MySQL + phpMyAdmin Generator${RESET}"
echo -e "${BOLD}${BLUE}================================================${RESET}"
echo -e "Project: ${YELLOW}$PROJECT_NAME${RESET}"
echo -e "Laravel: ${GREEN}$DISPLAY_LARAVEL_VERSION${RESET}"
echo -e "PHP: ${RED}$PHP_VERSION${RESET}"
echo -e "Docker: ${CYAN}$ENABLE_DOCKER${RESET}"
echo -e "Web Server: ${GREEN}Nginx${RESET}"
echo -e "Database: ${BLUE}MySQL + phpMyAdmin${RESET}"
echo ""

COMPOSER_IMAGE="composer:2"

echo -e "${CYAN}🔄 Creating temporary Laravel project to extract structure...${RESET}"

TEMP_DIR="${PROJECT_NAME}_temp"

if [ -n "$LARAVEL_VERSION" ] && [[ "$LARAVEL_VERSION" != "--enable-docker" ]]; then
    docker run --rm -v $(pwd):/app -w /app --user $(id -u):$(id -g) $COMPOSER_IMAGE \
        create-project laravel/laravel $TEMP_DIR "$LARAVEL_VERSION" --prefer-dist
else
    docker run --rm -v $(pwd):/app -w /app --user $(id -u):$(id -g) $COMPOSER_IMAGE \
        create-project laravel/laravel $TEMP_DIR --prefer-dist
fi

if [ ! -d "$TEMP_DIR" ]; then
    echo -e "${RED}❌ Failed to create temporary Laravel project${RESET}"
    exit 1
fi

echo -e "${CYAN}🔧 Extracting Laravel structure without dependencies...${RESET}"

mkdir -p "$PROJECT_NAME"

echo -e "${CYAN}📁 Copying essential Laravel files and folders...${RESET}"
rsync -av --exclude='vendor' --exclude='node_modules' "$TEMP_DIR/" "$PROJECT_NAME/"

echo -e "${CYAN}🗑️ Cleaning up temporary files...${RESET}"
rm -rf "$TEMP_DIR"

cd "$PROJECT_NAME"

echo -e "${CYAN}📁 Ensuring complete directory structure...${RESET}"
mkdir -p storage/{app/{public},framework/{cache/data,sessions,testing,views},logs}
mkdir -p bootstrap/cache
mkdir -p vendor
mkdir -p node_modules
mkdir -p database/{factories,migrations,seeders}
mkdir -p public/{css,js,images}
mkdir -p resources/{css,js,views}
mkdir -p routes
mkdir -p tests/{Feature,Unit}

echo -e "${CYAN}📄 Adding .gitkeep files to empty folders...${RESET}"
touch storage/app/.gitkeep
touch storage/app/public/.gitkeep
touch storage/framework/cache/.gitkeep
touch storage/framework/cache/data/.gitkeep
touch storage/framework/sessions/.gitkeep
touch storage/framework/testing/.gitkeep
touch storage/framework/views/.gitkeep
touch storage/logs/.gitkeep
touch bootstrap/cache/.gitkeep
touch vendor/.gitkeep
touch node_modules/.gitkeep

echo -e "${CYAN}📄 Creating .env.example file tailored for Docker setup...${RESET}"

cp .env.example ENV-EXAMPLE.txt

echo -e "${CYAN}Creating ENV.txt to Copy to .env${RESET}"
cat > ENV.txt << EOF
APP_NAME="${PROJECT_NAME}"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

# Docker Database Connection
DB_CONNECTION=mysql
DB_HOST=database
DB_PORT=3306
DB_DATABASE=${PROJECT_NAME//-/_}
DB_USERNAME=laravel
DB_PASSWORD=laravelpassword

# File-based Drivers (No Redis needed)
BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Mail
MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="\${APP_NAME}"

# Vite
VITE_APP_NAME="\${APP_NAME}"
EOF

echo -e "${CYAN}Creating ENV-EXAMPLE.txt to Copy to .env.example${RESET}"

cp .env.example ENV-EXAMPLE.txt

echo -e "${CYAN}Creating README-DEV.md${RESET}"
cat > README-DEV.md << EOF
# Laravel Development on QNAP NAS 
![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
#### **Project Name:** \`$PROJECT_NAME\`
#### **Laravel Version:** $DISPLAY_LARAVEL_VERSION
#### **PHP Version:** $PHP_VERSION
#### **Docker Support:** ✅ Enabled
#### **Web Server:** Nginx
#### **Database:** MySQL + phpMyAdmin
#### **PHPStorm:** ✅ Pre-configured
#### **Dependencies:** ❌ Disabled
#### **Created At:** $(date)

---

## 📖 Quick Start Guide

> **Note:** Dependencies (vendor, node_modules) will be installed on development machine only

### For Windows
\`\`\`bash
./setup-windows.bat
\`\`\`

### For Unix
\`\`\`bash
./setup-unix.sh
\`\`\`

### PHPStorm Setup
1. Open project in PHPStorm
2. Settings → PHP → CLI Interpreter
3. Choose "From Docker Compose"
4. Choose docker-compose.yml
5. Choose service "app"

---

### Swoole Web Server

## 🖥️ Swoole Web Server

#### 1. Require laravel/octane >> package.json
\`\`\`bash
docker-compose exec app composer require laravel/octane
\`\`\`

#### 2. Install laravel/octane
\`\`\`bash
docker-compose exec app php artisan octane:install
\`\`\`

#### 3. Install chokidar select **3)swoole**
\`\`\`bash
docker-compose exec app npm install chokidar --save-dev
\`\`\`

#### 4. Run octane with --watch option
\`\`\`bash
docker-compose exec app php artisan octane:start --port=8001 --host=0.0.0.0 --watch
\`\`\`

---

## 🌐 Service URLs & Credentials

| Service | URL | Username | Password |
|---|---|---|---|
| **Swoole** 👍 | [http://localhost:8001](http://localhost:8001) | - | - |
| **Laravel App** | [http://localhost:8000](http://localhost:8000) | - | - |
| **phpMyAdmin** | [http://localhost:8080](http://localhost:8080) | \`root\` | \`rootpassword\` |
| **Database** | \`localhost:3306\` (from host) | \`laravel\` | \`laravelpassword\` |

---

## 📁 Project Structure

\`\`\`
$PROJECT_NAME/
├── app/                    # Laravel Application Logic
├── bootstrap/              # Bootstrap files
├── config/                 # Configuration files
├── database/               # Migrations, Factories, Seeders
├── public/                 # Web accessible files
├── resources/              # Views, CSS, JS source
├── routes/                 # Route definitions
├── storage/                # Generated files, logs, cache
├── tests/                  # Test files
├── vendor/                 # Composer dependencies (empty on QNAP)
├── node_modules/           # NPM dependencies (empty on QNAP)
├── .idea/                  # PHPStorm configuration
├── docker/                 # Docker configuration
├── docker-compose.yml      # Docker Compose setup
├── Dockerfile             # PHP-FPM container
├── .env.example           # Environment template
└── ENV.txt                # Environment for Docker setup
\`\`\`

---

## 🐳 Docker Commands

| Command | Description |
|---|---|
| \`docker-compose up -d --build\` | Build Images and Start Services |
| \`docker-compose up -d\` | Start Services |
| \`docker-compose down\` | Stop and Remove Containers |
| \`./artisan <command>\` | Run Artisan Command (shortcut) |
| \`docker-compose exec app composer <command>\` | Run Composer Command |
| \`docker-compose exec app npm <command>\` | Run NPM Command |
| \`docker-compose logs -f app\` | View Laravel Real-time Logs |

## ✨ Laravel Commands

| Command                                                                | Description       |
|----------------------------------------------------------------------|------------------|
| \`docker-compose exec app php artisan {artisanCommand}\`               | Artisan Command  |
| \`docker-compose exec app php artisan make:controller {controllerName}\` | Make Controller |
| \`docker-compose exec app php artisan make:model {modelName}\`         | Make Model      |

---

## ✅ QNAP Sync Optimization

This project is compatible with QNAP QSync:

- ✅ **Laravel Structure:** Complete Laravel project structure
- ✅ **Essential Files:** bootstrap/app.php included
- ❌ **No Dependencies:** vendor/ and node_modules/ not pre-installed on QNAP
- ✅ **PHPStorm Ready:** .idea/ folder ready for use
- ✅ **Docker Ready:** Complete Docker configuration

### .qsyncignore Status:
- \`/vendor/\` - ❌ Not Synced
- \`/node_modules/\` - ❌ Not Synced

---

## 🔧 Troubleshooting

### Permission Issues
\`\`\`bash
docker-compose exec -u root app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
\`\`\`

### Missing Dependencies
If you encounter missing classes error:
\`\`\`bash
# Install dependencies on dev machine
docker-compose exec app composer install
docker-compose exec app npm install
\`\`\`

### PHPStorm Issues
\`\`\`bash
# After installing dependencies
./artisan ide-helper:generate
./artisan ide-helper:models --write
./artisan ide-helper:meta
\`\`\`

### Sync Validation
\`\`\`bash
./validate-sync.sh
\`\`\`

---
# 🎯 Laravel FTPS Deployment Script

This script is designed to simplify the deployment process of Laravel projects to servers via FTPS (FTP over SSL/TLS) protocol. It will sync only necessary files and exclude files that shouldn't be on production such as node_modules, .git, .env, etc.

#### ⚠️ Warning: This script is suitable for servers that cannot be accessed via Git or modern CI/CD tools and should be used with caution.

#### ⚙️ Initial Setup (One-time only)
1. **Set destination path on server**: Open the ftp-upload-project.sh file with a text editor and modify the REMOTE_PROJECTS_BASE_PATH variable to be the main path for your projects on the FTP server. Example: If you want the project to be located at /var/www/html/my-project, set it as follows:
\`\`\`text
# In ftp-upload-project.sh file
REMOTE_PROJECTS_BASE_PATH="/var/www/html"
\`\`\`
2. **Make script executable**: Open Terminal or Command Line and run this command only once in your project folder:
\`\`\`text
chmod +x ftp-upload-project.sh
\`\`\`

## 🚀 How to Deploy
Every time you need to deploy the project, follow these steps:
1. Open Terminal at the root directory of your Laravel project
2. Run the script with the command:
3. Enter password: The script will ask for your FTPS password (password won't be displayed on screen while typing)
\`\`\`text
./ftp-upload-project.sh <SERVER_ADDRESS> <USERNAME>
\`\`\`
4. Confirm deployment: Read the deployment details displayed by the script. If correct, type y and press Enter to start the process
5. Wait for script completion: The script will create a temporary package, upload files, and handle basic .env file management

## 🔐 Important Steps After Deployment (Required Every Time)
Since some FTP servers have limitations and don't support changing file permissions via FTP directly, **after the script finishes uploading files, you need to SSH into the server to set up permissions and run various Laravel commands properly.**

The script will display all necessary commands at the final step, which typically look like this:
\`\`\`text
# SSH to your server and run these commands:

# 1. Navigate to project folder
cd /var/www/html/my-project

# 2. Fix permissions for security (Very Important!)
chmod -R 755 .
find . -type f -exec chmod 644 {} \;

# 3. Install Laravel dependencies
composer install --no-dev --optimize-autoloader

# 4. Setup environment, key, and database
nano .env
php artisan key:generate --ansi
php artisan migrate --force

# 5. Set permissions for folders Laravel needs to write to
chmod -R 775 storage bootstrap/cache
chown -R your_user:www-data storage bootstrap/cache

# 6. Create cache to improve application performance
php artisan config:cache
php artisan route:cache
php artisan view:cache
\`\`\`
EOF

echo -e "${CYAN}🔐 Setting proper permissions...${RESET}"
chmod -R 775 storage bootstrap/cache
chown -R $(whoami):$(whoami) storage bootstrap/cache 2>/dev/null || true

if [ "$ENABLE_DOCKER" = true ]; then
    echo -e "${BLUE}🐳 Setting up Docker configuration...${RESET}"
    mkdir -p docker/{nginx,php,mysql}

    echo -e "${CYAN}📄 Creating Performance-Tuned Dockerfile...${RESET}"
    cat > Dockerfile <<EOF
FROM php:${PHP_VERSION}-fpm-alpine

WORKDIR /var/www

RUN apk add --no-cache \\
        \$PHPIZE_DEPS \\
        git curl unzip libzip-dev oniguruma-dev libxml2-dev icu-dev \\
        libpng-dev libjpeg-turbo-dev freetype-dev \\
        nodejs npm linux-headers \\
    && pecl install swoole \\
    && docker-php-ext-enable swoole \\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \\
    && docker-php-ext-install \\
        pdo_mysql \\
        bcmath \\
        sockets \\
        zip \\
        mbstring \\
        exif \\
        pcntl \\
        intl \\
        gd \\
        opcache \\
    && rm -rf /var/cache/apk/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN addgroup -g 1000 laravel && \\
    adduser -u 1000 -G laravel -s /bin/sh -D laravel

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
EOF

cat > docker/mysql/init.sql << EOF
CREATE DATABASE IF NOT EXISTS \`${PROJECT_NAME//-/_}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`${PROJECT_NAME//-/_}_test\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`${PROJECT_NAME//-/_}\`.* TO 'laravel'@'%';
GRANT ALL PRIVILEGES ON \`${PROJECT_NAME//-/_}_test\`.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
EOF

cat > docker/nginx/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /var/www/public;
    index index.php index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS off;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_read_timeout 300;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
}
EOF

cat > docker/php/local.ini << 'EOF'
upload_max_filesize=40M
post_max_size=40M
memory_limit=512M
max_execution_time=300
max_input_vars=3000

opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=0
opcache.validate_timestamps=1
opcache.fast_shutdown=1

display_errors=On
log_errors=On
error_reporting=E_ALL
EOF

echo -e "${CYAN}🐳 Creating Enhanced docker-compose.yml...${RESET}"
cat > docker-compose.yml << EOF
services:
  # Nginx Web Server
  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME}-nginx
    restart: unless-stopped
    ports:
      - "8000:80"
    volumes:
      - ./:/var/www:cached
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    networks:
      - laravel
    depends_on:
      app:
        condition: service_healthy

  # PHP Application
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}-app
    restart: unless-stopped
    working_dir: /var/www
    ports:
      - "8001:8001"
    volumes:
      - ./:/var/www:cached
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
    environment:
      - WWWUSER=1000
      - WWWGROUP=1000
      - CHOKIDAR_USEPOLLING=true
    networks:
      - laravel
    healthcheck:
      test: ["CMD-SHELL", "php-fpm -t || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3

  # MySQL Database
  database:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${PROJECT_NAME//-/_}
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_USER: laravel
      MYSQL_PASSWORD: laravelpassword
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
    volumes:
      - db_data:/var/lib/mysql
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    networks:
      - laravel
    command: --default-authentication-plugin=mysql_native_password --innodb-buffer-pool-size=256M
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5

  # phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: ${PROJECT_NAME}-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: database
      MYSQL_ROOT_PASSWORD: rootpassword
      PMA_ARBITRARY: 1
    ports:
      - "8080:80"
    networks:
      - laravel
    depends_on:
      database:
        condition: service_healthy

volumes:
  db_data:
    driver: local

networks:
  laravel:
    driver: bridge
EOF

cat > .qsyncignore << 'EOF'
/vendor/
/node_modules/

/.env
/.env.local
/.env.production

/storage/logs/
/bootstrap/cache/
*.log

/db_data/

.DS_Store
Thumbs.db

/artisan

/.vscode/

/public/hot
/public/storage
/storage/*.key
EOF

fi

echo -e "${CYAN}📋 Creating Enhanced Setup Scripts...${RESET}"

cat > setup-windows.bat << EOF
@echo off
setlocal EnableDelayedExpansion

echo =========================================================
echo  Laravel Development Setup - QNAP Optimized (Windows)
echo =========================================================
echo.
echo  Project: my-project-latest
echo  Laravel: Latest (12.x)  
echo  PHP: 8.2
echo.
echo  NOTE: Dependencies will be installed in development machine only
echo       (QNAP contains structure without vendor/node_modules)
echo.

REM Check Docker
echo [1/8] Checking Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found! Please install Docker Desktop.
    pause
    exit /b 1
)
echo ✅ Docker is available.

echo.
echo [2/8] Validating Laravel project structure...
if not exist "bootstrap\app.php" (
    echo ❌ Laravel structure incomplete! bootstrap\app.php missing.
    echo    Please re-sync from QNAP or recreate project.
    pause
    exit /b 1
)
if not exist "composer.json" (
    echo ❌ composer.json missing! Please re-sync from QNAP.
    pause
    exit /b 1
)
echo ✅ Laravel project structure is complete.

echo.
echo [3/8] Building and starting Docker containers...
docker-compose up -d --build
if %errorlevel% neq 0 (
    echo ❌ Failed to start Docker containers.
    pause
    exit /b 1
)

echo.
echo [4/8] Waiting for services to be ready...
timeout /t 15 /nobreak > nul
echo ✅ Services should be ready.

echo.
echo [5/8] Installing Composer dependencies...
echo     This may take several minutes on first run...
docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader
if %errorlevel% neq 0 (
    echo ❌ Composer install failed.
    echo    Check if composer.json exists and is valid.
    pause
    exit /b 1
)

echo.
echo [6/8] Installing NPM dependencies...
docker-compose exec app npm install
if %errorlevel% neq 0 (
    echo ⚠️  NPM install failed (may be normal if no package.json)
    REM ไม่ exit เพราะบางโปรเจคอาจไม่มี package.json
)

echo.
echo [7/8] Setting up Laravel environment and permissions...
REM Create .env file first
docker-compose exec app cp ENV.txt .env
docker-compose exec app cp ENV-EXAMPLE.txt .env.example

REM Fix permissions using ROOT user inside the container
echo Fixing directory permissions...
REM [FIX 1] Change owner to 'laravel:laravel' which is the correct user
docker-compose exec -u root app chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache 2>nul
REM [FIX 2] Run chmod as ROOT user to guarantee permission
docker-compose exec -u root app chmod -R 775 /var/www/storage /var/www/bootstrap/cache

REM Now run Laravel setup commands
docker-compose exec app php artisan key:generate --ansi
docker-compose exec app php artisan storage:link

REM Try to run migrations (may fail if no migrations exist yet)
echo Running database setup...
docker-compose exec app php artisan migrate --force
if %errorlevel% neq 0 (
    echo ⚠️  Migration failed (normal if no migrations exist yet)
)

echo.
echo [8/8] Installing Laravel IDE Helper for PHPStorm...
docker-compose exec app composer require --dev barryvdh/laravel-ide-helper
docker-compose exec app php artisan ide-helper:generate
docker-compose exec app php artisan ide-helper:models --write
docker-compose exec app php artisan ide-helper:meta

echo.
echo [FINAL] Running health checks...
docker-compose exec app php artisan --version
docker-compose exec app php artisan route:list 2>nul || echo Routes: Default Laravel routes loaded

echo.
echo =========================================================
echo ✅ Setup Complete! Laravel is ready for development!
echo =========================================================
echo.
echo   🌐 Laravel App:  http://localhost:8000
echo   🗄️  phpMyAdmin:  http://localhost:8080
echo   📊 Database:     localhost:3306 (user: laravel, pass: laravelpassword)
echo.
echo 💡 Development Notes:
echo   - Dependencies installed: vendor/ and node_modules/
echo   - These folders are NOT synced back to QNAP
echo   - PHPStorm is pre-configured and ready to use
echo.
echo 🔧 PHPStorm Users:
echo   1. Open project in PHPStorm
echo   2. Go to Settings → PHP → CLI Interpreter  
echo   3. Add "From Docker Compose" → docker-compose.yml → Service: app
echo.
echo 📋 Useful commands:
echo   docker-compose exec app php artisan migrate    : Run migrations
echo   docker-compose exec app php artisan tinker     : Laravel REPL
echo   docker-compose logs -f                         : View all logs
echo   docker-compose down                            : Stop services
echo.
pause
EOF

cat > setup-unix.sh << 'EOF'
#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

handle_error() {
    echo -e "${RED}❌ Error occurred during setup: $1${NC}"
    echo -e "${YELLOW}🔧 You may need to run: docker-compose down${NC}"
    exit 1
}

trap 'handle_error "Unexpected error"' ERR

echo -e "${BLUE}==========================================================${NC}"
echo -e "${GREEN}🚀 Laravel Development Setup - QNAP Optimized (Unix)${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo ""
echo "  Project: $PROJECT_NAME"
echo "  Laravel: $DISPLAY_LARAVEL_VERSION"
echo "  PHP: $PHP_VERSION"
echo ""
echo -e "${YELLOW}  NOTE: Dependencies will be installed in development machine only${NC}"
echo -e "${YELLOW}        (QNAP contains structure without vendor/node_modules)${NC}"
echo ""

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found! Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found! Please install Docker Compose first.${NC}"
    exit 1
fi

echo "[1/8] Validating Laravel project structure..."
if [ ! -f "bootstrap/app.php" ]; then
    echo -e "${RED}❌ Laravel structure incomplete! bootstrap/app.php missing.${NC}"
    echo "   Please re-sync from QNAP or recreate project."
    exit 1
fi

if [ ! -f "composer.json" ]; then
    echo -e "${RED}❌ composer.json missing! Please re-sync from QNAP.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Laravel project structure is complete.${NC}"

echo ""
echo "[2/8] Building and starting Docker containers..."
if ! docker-compose up -d --build; then
    handle_error "Failed to start Docker containers"
fi

echo ""
echo "[3/8] Waiting for services to be ready..."
sleep 15
echo -e "${GREEN}✅ Services should be ready.${NC}"

echo ""
echo "[4/8] Installing Composer dependencies..."
echo "     This may take several minutes on first run..."
if ! docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader; then
    handle_error "Composer install failed - check if composer.json exists and is valid"
fi

echo ""
echo "[5/8] Installing NPM dependencies..."
if ! docker-compose exec app npm install; then
    echo -e "${YELLOW}⚠️  NPM install failed (may be normal if no package.json)${NC}"
fi

echo ""
echo "[6/8] Setting up Laravel environment..."
docker-compose exec app cp ENV.txt .env
docker-compose exec app php artisan key:generate --ansi
docker-compose exec app php artisan storage:link

# Try to run migrations (may fail if no migrations exist yet)
echo "Running database setup..."
if ! docker-compose exec app php artisan migrate --force; then
    echo -e "${YELLOW}⚠️  Migration failed (normal if no migrations exist yet)${NC}"
fi

# Fix permissions
echo "Fixing directory permissions..."
docker-compose exec -u root app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null || true
docker-compose exec app chmod -R 775 storage bootstrap/cache

echo ""
echo "[7/8] Installing Laravel IDE Helper for PHPStorm..."
docker-compose exec app composer require --dev barryvdh/laravel-ide-helper
docker-compose exec app php artisan ide-helper:generate
docker-compose exec app php artisan ide-helper:models --write  
docker-compose exec app php artisan ide-helper:meta

echo ""
echo "[8/8] Running health checks..."
echo "Laravel version:"
docker-compose exec app php artisan --version
echo ""

echo -e "${BLUE}==========================================================${NC}"
echo -e "${GREEN}✅ Setup Complete! Laravel is ready for development!${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo ""
echo -e "   🌐 Laravel App:  ${CYAN}http://localhost:8000${NC}"
echo -e "   🗄️  phpMyAdmin:  ${CYAN}http://localhost:8080${NC}" 
echo -e "   📊 Database:     ${CYAN}localhost:3306${NC} (user: laravel, pass: laravelpassword)"
echo ""
echo -e "${YELLOW}💡 Development Notes:${NC}"
echo "   - Dependencies installed: vendor/ and node_modules/"
echo "   - These folders are NOT synced back to QNAP"
echo "   - PHPStorm is pre-configured and ready to use"
echo ""
echo -e "${CYAN}🔧 PHPStorm Users:${NC}"
echo "   1. Open project in PHPStorm"
echo "   2. Go to Settings → PHP → CLI Interpreter"
echo "   3. Add 'From Docker Compose' → docker-compose.yml → Service: app"
echo ""
echo -e "${CYAN}📋 Useful commands:${NC}"
echo "   docker-compose logs -f        : View all logs"
echo "   docker-compose down          : Stop services"  
echo "   ./artisan tinker             : Laravel REPL (via shortcut)"
echo ""
EOF

chmod +x setup-unix.sh

echo -e "${CYAN}Creating Artisan shortcut...${RESET}"
cat > laravel-artisan << 'EOF'
#!/bin/bash
# Laravel Artisan shortcut for Docker
if [ ! -f "vendor/autoload.php" ]; then
    echo "❌ Dependencies not installed! Please run setup script first."
    echo "   Windows: setup-windows.bat"
    echo "   Unix:    ./setup-unix.sh"
    exit 1
fi

docker-compose exec app php artisan "$@"
EOF

chmod +x laravel-artisan

echo -e "${CYAN}Creating Windows Artisan shortcut...${RESET}"
cat > laravel-artisan.bat << 'EOF'
@echo off
if not exist "vendor\autoload.php" (
    echo ❌ Dependencies not installed! Please run setup script first.
    echo    Windows: setup-windows.bat
    echo    Unix: ./setup-unix.sh
    exit /b 1
)

docker-compose exec app php artisan %*
EOF

chmod +x artisan

echo -e "${CYAN}Creating enhanced sync validation script...${RESET}"
cat > validate-sync.sh << 'EOF'
#!/bin/bash
echo "🔍 Validating QNAP sync status for Laravel project..."
echo ""

echo "Checking essential Laravel files:"
core_files=(
    "bootstrap/app.php"
    "composer.json"
    "package.json"
    "artisan"
    "public/index.php"
    "config/app.php"
    "routes/web.php"
)

echo ""
echo "Checking development setup files:"
dev_files=(
    ".idea/modules.xml"
    ".idea/laravel-plugin.xml"
    ".idea/php.xml"
    "docker-compose.yml"
    "Dockerfile"
    ".env.example"
    "ENV.txt"
    "setup-unix.sh"
    "setup-windows.bat"
    "README-DEV.md"
)

missing_files=()
synced_files=()

for file in "${core_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
        synced_files+=("$file")
    else
        echo "❌ $file - MISSING!"
        missing_files+=("$file")
    fi
done

echo "" 
for file in "${dev_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
        synced_files+=("$file")
    else
        echo "❌ $file - MISSING!"
        missing_files+=("$file")
    fi
done

echo ""
echo "📁 Checking directory structure:"
required_dirs=(
    "app"
    "bootstrap"
    "config"
    "database"
    "public"
    "resources"
    "routes"
    "storage"
    "tests"
)

missing_dirs=()
for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/"
    else
        echo "❌ $dir/ - MISSING!"
        missing_dirs+=("$dir")
    fi
done

echo ""
echo "🚫 Checking excluded directories (should be empty or missing):"
excluded_dirs=("vendor" "node_modules")
for dir in "${excluded_dirs[@]}"; do
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "⚠️  $dir/ - Contains files (will be recreated in dev machine)"
    else
        echo "✅ $dir/ - Empty or missing (correct for QNAP)"
    fi
done

echo ""
echo "📊 Sync Summary:"
echo "   ✅ Files synced: ${#synced_files[@]}"
echo "   ❌ Files missing: ${#missing_files[@]}"  
echo "   ❌ Directories missing: ${#missing_dirs[@]}"

if [ ${#missing_files[@]} -eq 0 ] && [ ${#missing_dirs[@]} -eq 0 ]; then
    echo ""
    echo "🎉 All essential files and directories synced successfully!"
    echo "   Ready for development setup!"
else
    echo ""
    echo "⚠️  Missing ${#missing_files[@]} files and ${#missing_dirs[@]} directories."
    echo "   Please check:"
    echo "   1. QSync settings and exclusions"
    echo "   2. Network connectivity to QNAP"
    echo "   3. File permissions on QNAP"
    echo "   4. Re-run project creation script if needed"
fi

echo ""
echo "🔧 PHPStorm .idea folder status:"
if [ -d ".idea" ]; then
    idea_files=$(find .idea -name "*.xml" 2>/dev/null | wc -l)
    echo "   ✅ .idea folder exists with $idea_files XML files"
    
    # Check specific PHPStorm files
    phpstorm_files=(".idea/modules.xml" ".idea/laravel-plugin.xml" ".idea/php.xml")
    for file in "${phpstorm_files[@]}"; do
        if [ -f "$file" ]; then
            echo "   ✅ $file"
        else
            echo "   ❌ $file - missing"
        fi
    done
else
    echo "   ❌ .idea folder missing"
fi

echo ""
echo "🎯 Next Steps:"
if [ ${#missing_files[@]} -eq 0 ] && [ ${#missing_dirs[@]} -eq 0 ]; then
    echo "   1. 🐳 Run setup-windows.bat (Windows) or ./setup-unix.sh (Unix)"
    echo "   2. 🎨 Open in PHPStorm and start developing!"
else
    echo "   1. 🔄 Re-sync from QNAP or recreate project"
    echo "   2. 🐳 Run setup script after sync is complete"
fi
EOF

chmod +x validate-sync.sh

# --- GENERATE THE DEPLOYMENT SCRIPT ---
echo -e "${GREEN}🚀 Creating the deployment script: \e[1mftp-upload-project.sh${RESET}"

# We write directly to the file "ftp-upload-project.sh" to avoid variable errors.
# The 'EOF' ensures that the script content is written exactly as is, without
# the parent script trying to interpret variables like $PROJECT_NAME, etc.
cat > "ftp-upload-project.sh" << 'EOF'
#!/bin/bash
# ftp-upload-project.sh - Self-contained FTPS Deployer for Laravel Projects
# FINAL VERSION for servers that DO NOT support permission changes via FTP.

# --- Configuration ---
# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

# !!! IMPORTANT: SET YOUR REMOTE BASE PATH HERE !!!
# Example: "/var/www/html" or "/home/user/public_html"
#REMOTE_PROJECTS_BASE_PATH="/your/ftp/path/test-ftp-folder"

# --- Helper Functions ---
log() {
    echo -e "[$(date '+%H:%M:%S')] $1"
}
cleanup() {
    # This function is called on script exit.
    # It cleans up from the original project directory.
    if [[ -n "$TEMP_DIR" && -d "$PROJECT_PATH/$TEMP_DIR" ]]; then
        log "${YELLOW}🧹 Cleaning up temporary directory...${RESET}"
        rm -rf "$PROJECT_PATH/$TEMP_DIR"
    fi
    if [[ -f "$PROJECT_PATH/.deployignore" ]]; then
        rm "$PROJECT_PATH/.deployignore"
    fi
}
trap cleanup EXIT

show_usage() {
    echo -e "${BOLD}${YELLOW}Usage:${RESET} $0 <ftps-server-address> <ftps-username> [ftps-password]"
}

# --- 1. Argument Parsing & Validation ---
if [ $# -lt 2 ]; then show_usage; exit 1; fi
FTP_HOST="$1"
FTP_USER="$2"
FTP_PASS="$3"
PROJECT_NAME=$(basename "$(pwd)")
PROJECT_PATH=$(pwd) # Store original path
if [ -z "$FTP_PASS" ]; then
    echo -n "Enter FTPS password for $FTP_USER@$FTP_HOST: "
    read -s FTP_PASS; echo
    if [ -z "$FTP_PASS" ]; then log "${RED}❌ Password cannot be empty${RESET}"; exit 1; fi
fi

# --- 2. Initial Confirmation ---
FTP_PATH="$REMOTE_PROJECTS_BASE_PATH/$PROJECT_NAME"
echo -e "${BOLD}${BLUE}================================================${RESET}"
echo -e "${BOLD}${GREEN}     LARAVEL FTPS DEPLOYMENT (Source Code Only)${RESET}"
echo -e "${BOLD}${BLUE}================================================${RESET}"
echo -e "📦 ${BOLD}Local Project:${RESET} ${CYAN}$PROJECT_NAME${RESET}"
echo -e "🌐 ${BOLD}Remote Server:${RESET} ${CYAN}$FTP_HOST${RESET}"
echo -e "📁 ${BOLD}Remote Path:${RESET}   ${CYAN}$FTP_PATH${RESET}"
echo -e "${BOLD}${RED}⚠️  WARNING: This script assumes your server does NOT support permission changes via FTP.${RESET}"
echo -e "${BOLD}${RED}   You MUST manually fix permissions via SSH after upload.${RESET}"
echo -e "${BOLD}${BLUE}================================================${RESET}"
echo -n "Are you sure you want to begin? (y/N): "
read -r CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then log "${YELLOW}❌ Deployment cancelled.${RESET}"; exit 0; fi

# --- 3. Pre-flight Checks ---
log "${BLUE}🚀 Starting deployment for $PROJECT_NAME...${RESET}"
if ! command -v lftp >/dev/null 2>&1; then log "${RED}❌ lftp not found.${RESET}"; exit 1; fi
log "${YELLOW}🔍 Testing FTPS connection...${RESET}"
lftp -c "set ftp:ssl-force true; set ftp:ssl-protect-data true; set ssl:verify-certificate no; set net:timeout 15; open ftp://$FTP_USER:\"$FTP_PASS\"@$FTP_HOST; ls; bye" >/dev/null 2>&1
if [ $? -ne 0 ]; then log "${RED}❌ FTPS connection failed! Check credentials.${RESET}"; exit 1; fi
log "${GREEN}✅ FTPS connection successful${RESET}"

# --- 4. Remote Directory Check ---
lftp -c "set ftp:ssl-force true; set ssl:verify-certificate no; open ftp://$FTP_USER:\"$FTP_PASS\"@$FTP_HOST; cd \"$FTP_PATH\"; bye" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    log "${YELLOW}⚠️  Remote directory '$FTP_PATH' already exists.${RESET}"
    echo -n "This will overwrite files. Continue? (y/N): "
    read -r OVERWRITE_CONFIRM
    if [[ ! $OVERWRITE_CONFIRM =~ ^[Yy]$ ]]; then log "${YELLOW}❌ Deployment cancelled.${RESET}"; exit 0; fi
else
    log "${GREEN}✅ Remote directory will be created.${RESET}"
fi

# --- 5. Local Preparation ---
TEMP_DIR="deploy-temp-$(date +%s)"
log "${YELLOW}📝 Creating deploy ignore file...${RESET}"
cat > .deployignore << EOL
.git/
.gitignore
.idea/
node_modules/
vendor/
.env
$TEMP_DIR/
*.sh
.deployignore
.DS_Store
.qsync*
storage/logs/*.log
EOL
log "${YELLOW}📁 Creating temporary package...${RESET}"
mkdir -p "$TEMP_DIR"
rsync -a --exclude-from='.deployignore' . "$TEMP_DIR/" >/dev/null 2>&1
cd "$TEMP_DIR" || exit

# --- 6. FTPS Upload (Upload ONLY) ---
log "${YELLOW}⬆️  Uploading files to $FTP_HOST:$FTP_PATH...${RESET}"
lftp -c "
set ftp:ssl-force true; set ftp:ssl-protect-data true; set ssl:verify-certificate no;
set net:reconnect-interval-base 5; set net:max-retries 3;
open ftp://$FTP_USER:\"$FTP_PASS\"@$FTP_HOST;
mirror -eR --verbose --parallel=5 --ignore-time . \"$FTP_PATH\";
bye
"
if [ $? -ne 0 ]; then log "${RED}❌ Upload failed! Check output.${RESET}"; exit 1; fi

# --- 7. Post-Upload Server Tasks (.env creation ONLY) ---
log "${YELLOW}🔧 Checking for .env file on production server...${RESET}"
lftp -c "set ftp:ssl-force true; set ssl:verify-certificate no; open ftp://$FTP_USER:\"$FTP_PASS\"@$FTP_HOST; cd \"$FTP_PATH\"; glob -f -- .env; bye" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    log "${YELLOW}File .env not found. Creating from .env.example...${RESET}"
    lftp -c "
    set ftp:ssl-force true; set ssl:verify-certificate no;
    open ftp://$FTP_USER:\"$FTP_PASS\"@$FTP_HOST;
    cd \"$FTP_PATH\";
    mv .env.example .env;
    bye
    "
    log "${GREEN}✅ Created .env from .env.example. ${BOLD}You must configure and fix its permissions!${RESET}"
else
    log "${GREEN}✅ Existing .env file found. Leaving it untouched.${RESET}"
fi

# --- 8. Summary & CRITICAL Next Steps ---
# Go back to original directory so the cleanup trap works correctly
cd "$PROJECT_PATH"

echo ""
log "${GREEN}✅ Source code sync completed successfully!${RESET}"
echo ""
echo -e "${BOLD}${RED}=====================================================${RESET}"
echo -e "${BOLD}${RED}   >>>  CRITICAL SECURITY ACTION REQUIRED!  <<<${RESET}"
echo -e "${BOLD}${RED}=====================================================${RESET}"
echo -e "${YELLOW}Your FTP server does not allow permission changes. Files likely have${RESET}"
echo -e "${BOLD}${RED}INSECURE permissions (e.g., 777).${RESET}"
echo -e ""
echo -e "${YELLOW}You MUST SSH into your server and run these commands to secure it:${RESET}"
echo -e "  ${CYAN}cd \"$FTP_PATH\"${RESET}"
echo ""
echo -e "${YELLOW}  # 1. Fix all folder and file permissions (BEST PRACTICE):${RESET}"
echo -e "  ${CYAN}find . -type d -exec chmod 755 {} \\;  # Set directories to 755${RESET}"
echo -e "  ${CYAN}find . -type f -exec chmod 644 {} \\;  # Set files to 644${RESET}"
echo ""
echo -e "${YELLOW}  # 2. Run standard Laravel setup:${RESET}"
echo -e "  ${CYAN}composer install --no-dev --optimize-autoloader${RESET}"
echo -e "  ${CYAN}nano .env            ${RESET}# CONFIGURE YOUR DATABASE AND APP SETTINGS${RESET}"
echo -e "  ${CYAN}php artisan key:generate --ansi${RESET}"
echo -e "  ${CYAN}php artisan migrate --force${RESET}"
echo ""
echo -e "${YELLOW}  # 3. Set specific Laravel permissions (REQUIRED for Laravel to work):${RESET}"
echo -e "  ${CYAN}chown -R \$USER:www-data storage${RESET}"
echo -e "  ${CYAN}chown -R \$USER:www-data bootstrap/cache${RESET}"
echo -e "  ${CYAN}chmod -R 775 storage${RESET}"
echo -e "  ${CYAN}chmod -R 775 storage bootstrap/cache${RESET}"
echo ""
echo -e "${YELLOW}  # 4. Cache everything for production:${RESET}"
echo -e "  ${CYAN}php artisan config:cache${RESET}"
echo -e "  ${CYAN}php artisan route:cache${RESET}"
echo -e "  ${CYAN}php artisan view:cache${RESET}"
echo ""
echo -e "${BOLD}${RED}=====================================================${RESET}"
echo ""

exit 0
EOF

# Make the new script executable
chmod +x "ftp-upload-project.sh"

rm -f "composer.lock"
mv "README-DEV.md" "README.md"

echo -e "${CYAN}✅ Done! You can now place '${BOLD}${FTP_FILENAME}${CYAN}' in any Laravel project.${RESET}"
echo -e "   Run it with: ${BOLD}./${FTP_FILENAME} <server> <user> [password]${RESET}"

echo ""
echo -e "${BOLD}${GREEN}📊 QNAP-Optimized Laravel Project Created Successfully!${RESET}"
echo -e "${BOLD}📂 Project:${RESET} ${YELLOW}$PROJECT_NAME${RESET}"
echo ""
echo -e "${BOLD}✨ QNAP Optimization Features:${RESET}"
echo -e "   📁 Complete Laravel structure (without dependencies)"  
echo -e "   ✅ Essential files: bootstrap/app.php, composer.json, etc."
echo -e "   🚫 Empty vendor/ and node_modules/ folders (with .gitkeep)"
echo -e "   🔧 PHPStorm .idea/ configuration ready"
echo -e "   🐳 Full Docker setup (Nginx + MySQL + phpMyAdmin)"
echo -e "   ⚡ .qsyncignore optimized for QNAP"
echo -e "   📋 Enhanced validation script"
echo ""
echo -e "${BOLD}📦 Directory Structure Created:${RESET}"
echo -e "   ✅ app/, bootstrap/, config/, database/, public/, resources/, routes/, storage/, tests/"
echo -e "   ✅ vendor/ (empty with .gitkeep)"
echo -e "   ✅ node_modules/ (empty with .gitkeep)"  
echo -e "   ✅ .idea/ (PHPStorm configuration)"
echo -e "   ✅ docker/ (Docker configuration)"
echo ""
echo -e "${BOLD}🎯 Next Steps:${RESET}"
echo -e "1. 🔄 Project will sync to dev machine via QSync (excluding vendor/node_modules)"
echo -e "2. 🔍 Run ${YELLOW}./validate-sync.sh${RESET} on dev machine to verify"
echo -e "3. 🐳 Run ${YELLOW}setup-windows.bat${RESET} (Win) or ${YELLOW}./setup-unix.sh${RESET} (Unix)"  
echo -e "4. 🎨 Dependencies will be installed in dev machine only"
echo -e "5. 🚀 Start developing with full Laravel + PHPStorm support!"
echo ""
echo -e "${BOLD}💡 Benefits:${RESET}"
echo -e "   • QNAP space saved (no vendor/node_modules sync)"
echo -e "   • Complete project structure maintained"
echo -e "   • PHPStorm ready out of the box"
echo -e "   • Docker environment pre-configured"
echo ""
echo -e "${BOLD}${BLUE}================================================${RESET}"
echo ""
