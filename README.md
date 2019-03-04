# Educast HTTP Uploader
Simple HTTP server to save video artifacts from Educast
Forked from [mayth/go-simple-upload-server](https://github.com/mayth/go-simple-upload-server) project with the following changes:

- allow PUT requests to reference subfolders (i.e `PUT /files/(path-to/filename)`). Subfolders are created if they do not exist on server.
- disable GET requests, this is only an upload server
- added CMD to dockerfile to startup server automatically running as non-root user (uid: 1028)
- ENV var **APP_TOKEN** to set the application token 
- using Alpline:latest for runtime image

# Usage

## Start Server

```
$ mkdir $HOME/tmp
$ ./simple_upload_server -token f9403fc5f537b4ab332d $HOME/tmp
```

(see "Security" section below for `-token` option)

## Uploading

You can upload files with `POST /upload`.
The filename is taken from the original file if available. If not, SHA1 hex digest will be used as the filename.

```
$ echo 'Hello, world!' > sample.txt
$ curl -Ffile=@sample.txt 'http://localhost:25478/upload?token=f9403fc5f537b4ab332d'
{"ok":true,"path":"/files/sample.txt"}
```

```
$ cat $HOME/tmp/sample.txt
hello, world!
```

**OR**

Use `PUT /files/(path-to/filename)`.
In this case, the original file name is ignored, and the name and path to store the file (inside the uploads folder) is taken from the URL. 

```
$ curl -X PUT -Ffile=@sample.txt "http://localhost:25478/files/myfolder/another_sample.txt?token=f9403fc5f537b4ab332d"
{"ok":true,"path":"/files/myfolder/another_sample.txt"}
```

## Existence Check

`HEAD /files/(path-to/filename)`.

```
$ curl -I 'http://localhost:25478/files/myfolder/foobar.txt?token=f9403fc5f537b4ab332d'
HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 9
Content-Type: text/plain; charset=utf-8
Last-Modified: Sun, 09 Oct 2016 14:35:39 GMT
Date: Sun, 09 Oct 2016 14:35:43 GMT

$ curl -I 'http://localhost:25478/files/unknown?token=f9403fc5f537b4ab332d'
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Sun, 09 Oct 2016 14:37:48 GMT
Content-Length: 19
```

# TLS

To enable TLS support, add `-cert` and `-key` options:

```
$ ./simple_upload_server -cert ./cert.pem -key ./key.pem root/
INFO[0000] starting up simple-upload-server
WARN[0000] token generated                               token=28d93c74c8589ab62b5e
INFO[0000] start listening TLS                           cert=./cert.pem key=./key.pem port=25443
INFO[0000] start listening                               ip=0.0.0.0 port=25478 root=root token=28d93c74c8589ab62b5e upload_limit=5242880
...
```

This server listens on `25443/tcp` for TLS connections by default. This can be changed by passing `-tlsport` option.

NOTE: The endpoint using HTTP is still active even if TLS is enabled.


# Security

There is no Basic/Digest authentication. This app implements dead simple authentication: "security token".

All requests should have `token` parameter (it can be passed from query strings or a form parameter). If it is completely matched with the server's token, the access is allowed; otherwise, returns `401 Unauthorized`.

You can specify the server's token on startup by `-token` option. If you don't so, the server generates the token and writes it to STDOUT at WARN level log, like as:

```
$ ./simple_upload_server root
INFO[0000] starting up simple-upload-server
WARN[0000] token generated                               token=2dd30b90536d688e19f7
INFO[0000] start listening                               ip=0.0.0.0 port=25478 root=root token=2dd30b90536d688e19f7 upload_limit=5242880
```

NOTE: The token is generated from the random number, so it will change every time you start the server.

# Docker

To be done...

```
$ docker run -p 25478:25478 -v $HOME/tmp:/tmp/uploads fccn/educast-http-uploader
```
