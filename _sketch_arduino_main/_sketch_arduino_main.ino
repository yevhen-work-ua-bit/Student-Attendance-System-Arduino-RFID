#include <Wire.h>
#include <Adafruit_PN532.h>

// connection SDA/SCL pin
#define SDA_PIN A4
#define SCL_PIN A5
#define RELAY_PIN 7

Adafruit_PN532 nfc(SDA_PIN, SCL_PIN);

int ledPin = 2;       // Green led - ready
int ledPinErr = 8;    // Red led - err

bool isWriteMode = false;
bool isKeyReady = false;
String incomingKey = "";
String tagID = "";

uint8_t defaultKeyA[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

// Array of valid UID`s (will write one of then randomly, you can to add a new UID if you want)
String allowedUIDs[] = {
  "A1B2C3D4", "1A2B3C4D", "1234ABCD", "DEADBEEF"
};
const int allowedCount = sizeof(allowedUIDs) / sizeof(allowedUIDs[0]);

void setup() {
  Serial.begin(9600);
  Serial.println("Initializing NFC module...");

  pinMode(ledPin, OUTPUT);
  pinMode(ledPinErr, OUTPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW);
  digitalWrite(ledPin, LOW);
  digitalWrite(ledPinErr, LOW);

  isWriteMode = false; //write mode is off

  nfc.begin();
  uint32_t versiondata = nfc.getFirmwareVersion();
  if (!versiondata) {
    Serial.println("Didn't find PN532 board");
    while (1);
  }

  nfc.SAMConfig();
  Serial.println("Ready. Send '1' for WRITE mode, '2' for READ mode.");
}

void loop() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();

    if (command == "1") {
      isWriteMode = true;
      Serial.println("Switched to WRITE mode.");
    } else if (command == "2") {
      isWriteMode = false;
      Serial.println("Switched to READ mode.");
    } else if (isWriteMode) {
      if (command.length() == 16) {
        incomingKey = command;
        isKeyReady = true;
        Serial.println("Received new key for writing. Please tap the card.");
        digitalWrite(ledPin, HIGH); // Ожидание карты
      } else {
        Serial.println("Invalid key length! Must be 16 characters.");
        digitalWrite(ledPin, LOW);
        digitalWrite(ledPinErr, HIGH);
        delay(3000);
        digitalWrite(ledPinErr, LOW);
      }
    }
  }

  if (isWriteMode && isKeyReady) {
    writeKeyAndUID();
  } else if (!isWriteMode) {
    readKeyAndUID();
  }
}

void writeKeyAndUID() {
  uint8_t uid[7];
  uint8_t uidLength;

  bool success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 50);

  if (success) {
    Serial.println("Card detected. Authenticating...");

    if (nfc.mifareclassic_AuthenticateBlock(uid, uidLength, 4, 0, defaultKeyA) &&
        nfc.mifareclassic_AuthenticateBlock(uid, uidLength, 5, 0, defaultKeyA)) {
      Serial.println("Authentication successful. Writing key and UID...");

      uint8_t keyData[16] = {0};
      incomingKey.getBytes(keyData, 17); // 17 чтобы вместился \0

      // Writing the key into block 4
      if (nfc.mifareclassic_WriteDataBlock(4, keyData)) {
        Serial.println("Key written.");

        // Select a random UID from the array
        int index = random(allowedCount);
        String randomUID = allowedUIDs[index];
        Serial.print("Selected UID to write: ");
        Serial.println(randomUID);

        // Writing the UID into block 5
        uint8_t uidData[16] = {0};
        randomUID.getBytes(uidData, 17);

        if (nfc.mifareclassic_WriteDataBlock(5, uidData)) {
          Serial.println("UID written successfully!");
          digitalWrite(ledPin, LOW);
          isKeyReady = false;
          incomingKey = "";
        } else {
          Serial.println("Error writing UID.");
          digitalWrite(ledPinErr, HIGH);
          delay(2000);
          digitalWrite(ledPinErr, LOW);
        }
      } else {
        Serial.println("Error writing key.");
        digitalWrite(ledPinErr, HIGH);
        delay(2000);
        digitalWrite(ledPinErr, LOW);
      }
    } else {
      Serial.println("Authentication failed!");
      digitalWrite(ledPinErr, HIGH);
      delay(2000);
      digitalWrite(ledPinErr, LOW);
    }
  isWriteMode = false;
  Serial.println("Switched back to READ mode after writing.");
  }
  
}

// read key & UID mode
void readKeyAndUID() {
  uint8_t uid[7];
  uint8_t uidLength;

  bool success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 50);

  if (success) {
    Serial.print("Card UID (physical): ");
    for (uint8_t i = 0; i < uidLength; i++) {
      if (uid[i] < 16) Serial.print("0");
      Serial.print(uid[i], HEX);
    }
    Serial.println();

    if (nfc.mifareclassic_AuthenticateBlock(uid, uidLength, 4, 0, defaultKeyA) &&
        nfc.mifareclassic_AuthenticateBlock(uid, uidLength, 5, 0, defaultKeyA)) {

      Serial.println("Authentication successful. Reading data...");

      uint8_t keyData[16];
      uint8_t uidData[16];

      if (nfc.mifareclassic_ReadDataBlock(4, keyData) && nfc.mifareclassic_ReadDataBlock(5, uidData)) {
        // Key output
        Serial.print("Encrypted Key (ASCII): ");
        for (int i = 0; i < 16; i++) {
          Serial.print((char)keyData[i]);
        }
        Serial.println();

        // UID output
        String storedUID = "";
        for (int i = 0; i < 16; i++) {
          if (uidData[i] != 0) storedUID += (char)uidData[i];
        }
        Serial.print("Stored UID: ");
        Serial.println(storedUID);

        // Check if stored UID is in valid array
        bool accessGranted = false;
        for (int i = 0; i < allowedCount; i++) {
          if (storedUID == allowedUIDs[i]) {
            accessGranted = true;
            break;
          }
        }

        // if stored UID - valid - relay is open, else - relay is close, default relay is close all time
        if (accessGranted) {
          Serial.println("✅ Access granted!");
          digitalWrite(RELAY_PIN, HIGH);
          delay(3000);
          digitalWrite(RELAY_PIN, LOW);
        } else {
          Serial.println("❌ Access Denied!");
          digitalWrite(RELAY_PIN, LOW);
        }
      } else {
        Serial.println("❌ Failed to read data blocks!");
        digitalWrite(ledPinErr, HIGH);
        delay(2000);
        digitalWrite(ledPinErr, LOW);
      }
    } else {
      Serial.println("❌ Authentication failed!");
      digitalWrite(ledPinErr, HIGH);
      delay(2000);
      digitalWrite(ledPinErr, LOW);
    }
    delay(3000);
    Serial.println();
  }
}
