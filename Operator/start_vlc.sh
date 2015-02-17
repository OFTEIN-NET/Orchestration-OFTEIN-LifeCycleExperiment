cvlc -q --no-osd -L -f --no-video-title-show --x11-display :1  nongak.sd --loop --sout '#rtp{dst=192.168.2.100,port=1234,sdp=rtsp://192.168.2.100:8080/test.sdp}' 2&>1 >/dev/null &

