void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.print("X1:");
  Serial.print(analogRead(A0));
  Serial.print(",");
  Serial.print("Y1:");
  Serial.print(analogRead(A1));
  Serial.print(",");
  Serial.print("S1:");
  Serial.print(analogRead(A2));
  Serial.print(",");
  Serial.print("X2:");
  Serial.print(analogRead(A3));
  Serial.print(",");
  Serial.print("Y2:");
  Serial.print(analogRead(A4));
  Serial.print(",");
  Serial.print("S2:");
  Serial.print(analogRead(A5));
  Serial.print(",");
  Serial.print("\n");
  delay(100);
}
