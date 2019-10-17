#include <Arduino.h>
#include <nbClient.h>

nbClient tcp;
#define HOST "wizio.eu"

void tcp_http()
{
  int timeout = 0;
  int r = tcp.connect(HOST, 80);
  DBG("connect: %d\n", r);
  if (r == 1)
  {
    char data[] = "GET /iot.php HTTP/1.1\r\nHost:" HOST "\r\n\r\n";
    r = tcp.write(data, strlen(data));
    DBG("sent: %d\n", r);
    delay(100);
    do
    {
      while (tcp.available())
      {
        r = tcp.read(); // read byte
        if (r > 0)
          Serial.print((char)r); // print result
        else
          goto end;
      }
      delay(100);
    } while (++timeout < 100);
  end:
    delay(10);
  }
  tcp.stop();
}

void setup() {
  String imei;
	Dev.setBand(3);
  Dev.noSleep();
  Serial.begin(115200);
  Serial.printf("Arduino %s\n", Dev.getVersion());
  Dev.getImei(imei);
  Serial.printf("IMEI %s\n", imei.c_str());
  Dev.waitSimReady();
  Serial.println("Sim Ready");
  Dev.waitCereg();
  delay(200); // must
  Serial.println("Net Ready");
  Serial.println("Test TCP\n");
  tcp_http();
  pinMode(LED, OUTPUT);
}

void loop() {
  static int led = 0;
  delay(500);
  digitalWrite(LED, ++led & 1);
}

/*
Arduino BC66NBR01A04
IMEI 867997030026081
Sim Ready
Net Ready
Test TCP
HTTP/1.1 200 OK
Date: Wed, 03 Apr 2019 06:44:09 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade
Cache-Control: max-age=0
Expires: Wed, 03 Apr 2019 06:44:09 GMT
Content-Length: 47
Content-Type: text/html
[WIZIO.EU] Hello World ( 2019-04-03 09:44:10 )
*/
