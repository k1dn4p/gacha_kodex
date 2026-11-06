scrcpy를 실행 옵션은 아래와 같습니다. USB 연결에서는 특별한 옵션이 필요 없고, WiFi 연결 시에서는 bitrate과  fps조절이 필요합니다. 
 
scrcpy -S

scrcpy --keyboard=uhid -S

    --always-on-top        Make scrcpy window always on top (above other windows).     
-b, --bit-rate value          Encode the video at the given bit-rate, expressed in bits/s.
    --crop width:height:x:y   Crop the device screen on the server. The values are expressed in the device natural orientation     
-f, --fullscreen        Start in fullscreen.    
--max-fps value         Limit the frame rate of screen capture (only supported on  devices with Android >= 10).    
-m, --max-size value   Limit both the width and height of the video to value. The other dimension is computed so that the device aspect-ratio  is preserved.     Default is 0 (unlimited).    
-n, --no-control:   Disable device control (mirror the device in read-only).    
-N, --no-display         Do not display device (only when screen recording is  enabled).    
-p, --port port   Set the TCP port the client listens on.    Default is 27183.    
-s, --serial serial        The device serial number. Mandatory only if several devices   are connected to adb.    
-S, --turn-screen-off    Turn the device screen off immediately.    
-t, --show-touches        Enable "show touches" on start, disable on quit.       It only shows physical touches (not clicks from scrcpy).  


4. WiFi 연결 상태에서 화면 미러링
adb의 WiFi 연결 기능을 활용해서 미러링이 가능합니다.  스마트 폰을 PC와 같은 공유기에 연결하고 「스마트 폰의 IP 주소」로 연결해야 합니다.
Android 스마트폰의 경우, 설정 > 장치 정보 > 상태를 탭하면 IP 주소를 확인할 수 있습니다. 
10.204.176.119

1. PC와 스마트폰을 같은 WiFi AP 공유기에 연결 
2. 스마트폰을 컴퓨터에 USB로 연결하고, 터미널 (or cmd 창)에서 아래 명령어를 입력해주세요.
      $ adb tcpip 5555
      (성공 시) : restarting in TCP mode port: 5555
  * 매번 USB연결이 귀찮다면 setprop
     $ adb shell setprop service.adb.tcp.port 5555
 
3. 스마트 폰의 USB 연결을 해제하고 터미널에서 아래 명령어로 무선 연결
      $adb connect <Smart Phone IP>:5555
     * 스마트폰 설정 > 휴대폰 정보 > IP주소 메뉴에서 연결된 IP 주소 확인 가능합니다. 또는 터미널에서  $ adb shell ifconfig 명령어로 확인 가능합니다. 
스마트 폰의 IP 주소 확인

4. PC에서 scrcpy 실행,  무선 연결 상태에서  bitrate을 낮게 설정해야 화면 delay가 없습니다. 
     $ scrcpy --video-bit-rate 2M --max-size 800
     $ scrcpy -b2M -m800
