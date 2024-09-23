This project uses [Redbean](https://redbean.dev/), a single-file distributable web server.

First, download the Redbean executable:

wget -O redbean https://redbean.dev/redbean-latest.com
chmod +x redbean

Then, use this command to relaunch at each source change:

find . \( -name "*.lua" -o -name "*.html" -o -name "*.tmpl" \) | entr -r -s "./redbean -D ./"
