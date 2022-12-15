const uint8_t P1_UP_PIN = 25;
const uint8_t P1_DOWN_PIN = 26;
const uint8_t P1_FIRE_PIN = 27;

const uint8_t P2_UP_PIN = 14;
const uint8_t P2_DOWN_PIN = 12;
const uint8_t P2_FIRE_PIN = 13;

void setup() {
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, 16, 17);
  pinMode(P1_UP_PIN, OUTPUT);
  pinMode(P1_DOWN_PIN, OUTPUT);
  pinMode(P1_FIRE_PIN, OUTPUT);
  pinMode(P2_UP_PIN, OUTPUT);
  pinMode(P2_DOWN_PIN, OUTPUT);
  pinMode(P2_FIRE_PIN, OUTPUT);
}

boolean buttonOneStatus = 0;
boolean buttonTwoStatus = 0;
double wheelOnePosition;
double wheelTwoPosition;

const int debounceDelay = 50;
int buttonOnePrev = 0;
int buttonOneLast = 0;
int buttonTwoPrev = 0;
int buttonTwoLast = 0;
int buttonOneRaw = 0;
int buttonTwoRaw = 0;

void processInputs() {
  char data[100]{};
  if (Serial2.available()) {
    Serial2.readStringUntil('\n').toCharArray(data, 100);
  }
  
  if (data[0] != 'X' or data[1] != '1') return;
  int varArray[6];
  for (int i = 3, j = 0, sum = 0; data[i] != 0; i++) {
    if (data[i] >= '0' and data[i] <= '9') {
      sum = sum * 10 + data[i] - '0';
    }
    if (data[i] == ':') {
      sum = 0;
    }
    if (data[i] == ',') {
      varArray[j++] = sum;
    }
  }

  double p1PosX = varArray[0];
  double p1PosY = varArray[1];
	buttonOneRaw = varArray[2];
  double p2PosX = varArray[3];
  double p2PosY = varArray[4];
	buttonTwoRaw = varArray[5];

  digitalWrite(P1_DOWN_PIN, p1PosX <= 100);
  digitalWrite(P1_UP_PIN, p1PosX >= 900);
  digitalWrite(P1_FIRE_PIN, buttonOneRaw <= 15);

  digitalWrite(P2_DOWN_PIN, p2PosX <= 100);
  digitalWrite(P2_UP_PIN, p2PosX >= 900);
  digitalWrite(P2_FIRE_PIN, buttonTwoRaw <= 15);

  // Serial.println("P1: " + String(p1PosX <= 100) + " " + String(p1PosX >= 900) + " " + String(buttonOneRaw <= 15));
  // Serial.println("P1: " + String(p1PosY <= 100) + " " + String(p1PosY >= 900) + " " + String(buttonOneRaw <= 15));
  // Serial.println("P2: " + String(p2PosX <= 100) + " " + String(p2PosX >= 900) + " " + String(buttonTwoRaw <= 15));
  // Serial.println("P2: " + String(p2PosY <= 100) + " " + String(p2PosY >= 900) + " " + String(buttonTwoRaw <= 15));
}

void loop() {
  processInputs();
  delay(40);
}
