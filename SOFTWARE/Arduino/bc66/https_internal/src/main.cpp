#include <Arduino.h>
#include <nbHttpClient.h>

nbHttpClient http;
void http_internal_test(const char *url)
{
  int code;
  http.begin(url, 64, 256);
  http.setTimeout(20);
  code = http.post("Hello Server");
  Serial.printf("CODE: %d\n", code);
  Serial.printf("%s\n", http.getHeader());
  Serial.printf("%s\n", http.getResponse());
}

void setup()
{
  String imei;
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
  Serial.println("Test HTTP\n");
  http_internal_test("http://wizio.eu/iot.php");
  delay(1000);
  Serial.println("Test HTTPS\n");
  http_internal_test("https://tlstest.paypal.com/");
  pinMode(LED, OUTPUT);
}

void loop()
{
  static int led = 0;
  delay(500);
  digitalWrite(LED, ++led & 1);
}

/*
Arduino BC66NBR01A04
IMEI 867997030026081
Sim Ready
Net Ready
Test HTTP
CODE: 206
Date: Wed, 03 Apr 2019 06:25:05 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade
Cache-Control: max-age=0
Expires: Wed, 03 Apr 2019 06:25:05 GMT
Content-Range: bytes 0-46/47
Content-Length: 47
Content-Type: text/html
[WIZIO.EU] Hello World ( 2019-04-03 09:25:06 )

Test HTTPS
CODE: 206
Content-Type: text/html
Date: Wed, 03 Apr 2019 06:25:12 GMT
Content-Range: bytes 0-19/20
Content-Length: 20
Connection: keep-alive
PayPal_Connection_OK
*/