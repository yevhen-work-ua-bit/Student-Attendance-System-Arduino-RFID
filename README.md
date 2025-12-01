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
