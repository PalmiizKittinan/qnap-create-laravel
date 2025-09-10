# 📚 Laravel Project Creator

![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![NODE.JS](https://img.shields.io/badge/node.js-339933?style=for-the-badge&logo=Node.js&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)<br>
![](https://img.shields.io/badge/version%20-1.2.0%20-blue)<br>
![](https://img.shields.io/badge/QTS_Compatible_Version%20-5.2.6.x%20-green)

---

## 📌 Requirement
### Linux, macOS (Recommended)
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
### Windows
- [Git Bash](https://git-scm.com/downloads/win)
- [Docker Desktop](https://docs.docker.com/desktop/)

--- 

## 🎯 Quick Start
# Laravel Docker Creator for QNAP
> **Automated Laravel Project Creator** for QNAP Container Station, supporting all Laravel versions with the appropriate PHP version
## ✨ Features

- 🐘 **Auto PHP Version Selection** - Automatically selects the correct PHP version based on Laravel requirements
- 📦 **Composer Version Compatibility** - Uses the appropriate Composer version for each Laravel version
- 📁 **QNAP Optimized** - Optimized for QNAP NAS environment

## 🎯 Laravel & PHP Version Support

| Laravel Version | PHP Version | Status |
|-----------------|---|---|
| Laravel 12.x    | PHP 8.2 | ✅ Latest |
| Laravel 11.x    | PHP 8.2 | ✅ LTS |
| Laravel 10.x    | PHP 8.1 | ✅ LTS |
| Laravel 9.x     | PHP 8.1 | ✅ Supported |
| Laravel 8.x     | PHP 8.0 | ✅ Supported |
| Laravel 7.x     | PHP 7.4 | ✅ Supported |
| Laravel 6.x     | PHP 7.4 | ✅ LTS End |
| Laravel 5.8     | PHP 7.3 | ⚠️ Legacy |

### Usage Examples
```text
# Create latest version
./create-laravel.sh my-project

# Version select
./create-laravel.sh my-project 11.*

# Version select with Docker
./create-laravel.sh my-project 11.* --enable-docker
```
---
## ⚙️ Core Script Workflow
1. Check Laravel version → select the appropriate PHP version
2. Generate Laravel project structure using `composer` (via Docker)
3. **No vendor installation** on NAS (to improve sync performance)
4. Prepare essential folders such as `storage/`, `bootstrap/cache/`
5. Create basic files such as `.env.example`, `artisan`
6. If `--enable-docker` is selected, it will generate:
   - `docker-compose.yml`
   - Nginx and PHP config files
   - Setup scripts for Windows (`setup-windows.bat`) and Linux/Mac (`setup-unix.sh`)
7. Includes `setup-native.bat` for non-Docker installation

---

## 🐳 If Docker is enabled
Docker Compose include with:
- **app** → PHP + Composer + Node.js
- **nginx** → Web Server
- **mysql** → Database
- **redis** → Cache

---

## 📖 Development Environment Steps

### 🖥️ With Local Environment
```text
composer install

npm install

cp .env.example .env

php artisan key:generate

php artisan migrate
```

## 🐳 With Docker
### For Windows
```bash
./setup-windows.bat
```
### For Unix
```bash
./setup-unix.sh
```

---

## 🔧 Windows Troubleshooting

### Git Bash
#### Command
```
export MSYS_NO_PATHCONV=1
export COMPOSE_CONVERT_WINDOWS_PATHS=1
```
#### Create Project
```bash
./create-laravel.sh <project-name> <laravel-version>.*
```

---

## 📝 Notes
- After creating the project, sync it to your development machine
- Install dependencies only on your development machine
- Best suited for using NAS as a **central file server**

