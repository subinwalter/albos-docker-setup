#!/bin/bash
# Fix permissions at container startup
chown -R www-data:www-data /var/www/html_gp/wp-content/uploads
exec "$@"