#!/bin/bash
apt update
apt install nginx -y
rm -rf /var/www/html/*
cat <<EOF > index.html
 <!DOCTYPE html>
 <html lang="en">
 <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mapping volums</title>
 </head>
 <body>
    <h1>Privet ot NGINX</h1>
 </body>
 </html>
EOF
mv index.html /var/www/html/
service nginx restart 