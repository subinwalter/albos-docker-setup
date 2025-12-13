#!/bin/bash
# Fix permissions at container startup
chown -R www-data:www-data /var/www/html/wp-content/uploads
exec "$@"

