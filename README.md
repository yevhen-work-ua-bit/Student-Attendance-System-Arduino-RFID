# Student-Attendance-System-Arduino-RFID
IoT-based smart attendance system with RFID and biometric authentication

This project is an **IoT-based smart attendance tracking system** built using:

- Arduino + PN532 (RFID/NFC)
- Optional biometric fingerprint module
- Relay-controlled electronic door lock
- PowerShell communication scripts
- Microsoft Access database with VBA automation

A student identifies themselves using an NFC card or smartphone.  
The microcontroller reads:

- the NFC UID  
- the student’s encrypted 16-character key  

The data is then sent to the PC, where an Access database automatically processes and logs it into the `AttendanceLog` table.

📌 **This is a real engineering thesis project**, fully designed and implemented from scratch.

---

# 🧩 System Architecture
[Student]
↓ (NFC tag / phone)
[PN532 → Arduino]
↓ (UID check)
[Door Unlock]
↓ (Send encrypted key)
[PowerShell Listener]
↓ (Incoming_keys.txt)
[MS Access VBA]
↓ (Student identification)
[AttendanceLog table]

## 🛠 Technologies Used

### **Embedded**
- Arduino (C/C++)
- PN532 NFC module
- I2C communication
- Relay control

### **Software**
- PowerShell (COM-port automation)
- Microsoft Access (VBA)
- Serial data parsing

### **Database**
- Access `.accdb`
- Tables:
  - Students
  - AttendanceLog
  - EncryptedKeys

---

## 🔐 Security Notes

- No personal student data is included in this repository  
- Access database contains only **empty template tables**
- Encryption keys in examples are **placeholders**

---

## 🚀 Future Improvements

- Replace Access with SQLite or PostgreSQL  
- Add AES encryption for data transfer  
- Replace serial COM monitoring with a network API  
- Add biometric verification as a mandatory step  
- Build PCB for the entire device  
- Integrate ESP32 for Wi-Fi connection  

