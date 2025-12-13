# Albos Docker Setup

This repository contains the Docker setup for running Albos and GigPeppers WordPress applications in containerized environments.

## Overview

The setup supports both local development and server deployment configurations for two WordPress applications:
- **Albos**: Main WordPress application
- **GigPeppers**: Secondary WordPress application (different version)

## File Structure

### Database Files

#### `albos_dump.sql`
Database dump file for the Albos application. Contains all the database structure and data.
- **Usage**: Import this dump to restore the Albos database
- **Export Command**: See `commands.md` for database export commands

#### `gigpeppers_dump.sql`
Database dump file for the GigPeppers application. Contains all the database structure and data.
- **Usage**: Import this dump to restore the GigPeppers database
- **Export/Import Commands**: See `commands.md` for detailed database commands

### Docker Configuration Files

#### `docker-compose.yml`
Main Docker Compose configuration for **local development** setup.
- **Usage**: `docker-compose up -d`
- **Environment**: Local development

#### `docker-compose-server.yml`
Docker Compose configuration for **server/production** deployment.
- **Usage**: Use this file when deploying to server
- **Environment**: Production server

### Docker Images

#### `Dockerfile`
Dockerfile for building the **Albos** Docker image.
- **Purpose**: Builds the main Albos WordPress container
- **Entrypoint**: Uses `entrypoint.sh`

#### `Dockerfile.gigpeppers`
Dockerfile for building the **GigPeppers** Docker image.
- **Purpose**: Builds GigPeppers container (different WordPress version than Albos)
- **Entrypoint**: Uses `entrypoint-gigpeppers.sh`
- **Note**: Separate Dockerfile needed due to version differences

### Entrypoint Scripts

#### `entrypoint.sh`
Entrypoint script for the Albos Docker container.
- **Usage**: Automatically executed when Albos container starts
- **Purpose**: Container initialization and setup

#### `entrypoint-gigpeppers.sh`
Entrypoint script for the GigPeppers Docker container.
- **Usage**: Automatically executed when GigPeppers container starts
- **Purpose**: Container initialization and setup

### WordPress Files

#### `public/`
Complete WordPress directory for **Albos** application.
- **Contents**: All WordPress files, plugins, themes, images, etc.
- **Sync Command**: See `commands.md` for rsync commands
- **Purpose**: Main WordPress installation files

#### `public_gp/`
Complete WordPress directory for **GigPeppers** application.
- **Contents**: All WordPress files, plugins, themes, images, etc.
- **Sync Command**: See `commands.md` for rsync commands
- **Purpose**: GigPeppers WordPress installation files

### Configuration Files

#### `custom-php.ini`
Custom PHP configuration file.
- **Usage**: Mounted in Docker containers as:
  ```
  ./custom-php.ini:/usr/local/etc/php/conf.d/custom-php.ini
  ```
- **Purpose**: Override default PHP settings

#### `nginx.conf`
Nginx configuration for **local development**.
- **Environment**: Local setup
- **Purpose**: Reverse proxy and web server configuration

#### `nginx_server.conf`
Nginx configuration for **server/production**.
- **Environment**: Production server
- **Purpose**: Production web server configuration with SSL

### Environment Configuration

#### `.env`
Environment variables file containing sensitive information.
- **Contents**: Database passwords, DD_API_KEY, and other secrets
- **Location**: Copy from server (contains actual values)
- **Security**: Never commit to version control

#### `.env.sample`
Sample environment file with placeholder values.
- **Purpose**: Template for creating actual `.env` file
- **Usage**: Copy and fill with actual values

## Setup Instructions

### Local Development Setup

1. **Copy necessary files**:
   - Copy `.env` file from server
   - Ensure `public/` and `public_gp/` folders contain WordPress files

2. **Start services**:
   ```bash
   docker-compose up -d
   ```

3. **Import databases**:
   - Import `albos_dump.sql` for Albos
   - Import `gigpeppers_dump.sql` for GigPeppers
   - See `commands.md` for specific commands

### Server/Production Setup

1. **Copy all necessary files to server**:
   - All Docker files and configurations
   - WordPress directories (`public/`, `public_gp/`)
   - Database dumps
   - `.env` file with production values

2. **Start services**:
   ```bash
   docker-compose -f docker-compose-server.yml up -d
   ```

3. **Import databases**:
   - Export/import database data using commands in `commands.md`

4. **SSL Configuration**:
   - SSL is enabled using Let's Encrypt
   - Standard Let's Encrypt setup for both Albos and GigPeppers

## Important Notes

- **Different Versions**: Albos and GigPeppers run on different WordPress versions, hence separate Dockerfiles
- **Database Commands**: All database export/import commands are documented in `commands.md`
- **File Sync**: WordPress file sync commands (rsync) are available in `commands.md`
- **Environment Variables**: Production `.env` file is stored on the server with actual credentials
- **SSL**: Production setup includes Let's Encrypt SSL certificates for both applications

## Reference Files

- `commands.md`: Contains detailed commands for database operations and file synchronization
- `.env.sample`: Template for environment variables
- Server `.env`: Contains actual production credentials and API keys