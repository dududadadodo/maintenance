cp -rp ./maintenance-page.conf /etc/nginx/snippets
cp -rp ./error_pages/maintenance-page.html /etc/nginx/html/server-error-pages
cp -rp /etc/nginx/html/server-error-pages/maintenance-page.html /etc/nginx/html/server-error-pages/maintenance-page_off.html