https://github.com/rochmad/go-simple-upload-server
branch:develop


NGINX CONF

```
server {
  listen *:80;
  client_max_body_size 25M;
  server_name ci.example.com;
            rewrite ^(.*) https://ci.example.com$1 permanent;
  }

server {
#        listen [::]:443 ssl http2;
        listen 443 ssl;
        server_name ci.example.com;                                                                                                                                                                                                                   server_tokens off;                                                                                                                                                                                                                           client_max_body_size 25M;

        ssl_certificate     /etc/ssl/example/example.crt;
        ssl_certificate_key /etc/ssl/example/example.key;

        ssl_dhparam /etc/ssl/certs/dhparam.pem;

#        gzip  on;
        gzip_comp_level    1;
        gzip_vary on;
        gzip_proxied any;
#        gzip_min_length 10240;
#        gzip_types text/plain text/css text/xml application/x-javascript applica$
        gzip_types image/jpeg image/webp image/svg+xml image/x-ms-bmp image/x-jng image/x-icon image/vnd.wap.wbmp image/png image/tiff
        gzip_disable "MSIE [1-6]\.(?!.*SV1)";
        gzip_buffers 32 4k;
        gzip_static on;

  access_log /var/log/nginx/ci-example-access.log;
  error_log /var/log/nginx/ci-example-error.log debug;



        root /opt/apps/ci-release-files/;
        autoindex on;



        location /devel/release/tai {
                alias /opt/apps/ci-release-files/tai/;

         }

        location /devel/release/tai/uploads {
                proxy_pass http://127.0.0.1:25478/;
                rewrite ^/devel/release/tai/uploads/(.*) /$1 break;

        }


}

```

RUN go_simple_upload
```
 ./go-simple-upload-server -loglevel debug -token 1111 /opt/ci-release-files/ -upload_limit 50000000
```

Example
PUT
```
curl -X PUT -Ffile=@sample.txt "https://ci.example.com/devel/release/tai/uploads/files/tai/devel/another_sample.txt?token=1111111" 
```


GET
```
https://ci.example.com/devel/release/tai/devel/another_sample.txt
```
tree dir

```
https://ci.example.com/devel/release/tai/
```
