VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Add_Student"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


#If VBA7 Then
    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)
#Else
    Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#End If

Private Sub btnAddStudent_Click()
    Dim Key As String
    Dim symbols As String
    Dim i As Integer
    
    ' Generation 16-bit identification key
    symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    Randomize
    Key = ""
    For i = 1 To 16
        Key = Key & Mid(symbols, Int((Len(symbols) * Rnd) + 1), 1)
    Next i
    
    ' Add student on database Students
    CurrentDb.Execute "INSERT INTO Students (FirstName, LastName, Course, Specialty, StudentKey) " & _
                      "VALUES ('" & Me.FirstName & "', '" & Me.txtLastName & "', '" & Me.txtCourse & "', '" & Me.txtSpecialty & "', '" & Key & "')"
    
    MsgBox "Student added successfully!" & vbCrLf & "Key: " & Key, vbInformation
    
    ' Cleaning
    Me.FirstName = ""
    Me.txtLastName = ""
    Me.txtCourse = ""
    Me.txtSpecialty = ""
    
    ' Prepairing identitfication key to sending to arduino
    Me.txtStudentKey = Key
End Sub




Private Sub btnSendToArduino_Click()
    Dim Key As String
    Dim killCommand As String
    Dim psCommand As String
    Dim result As Double

    Key = Me.txtStudentKey.Value
    If Len(Key) <> 16 Then
        MsgBox "Êכ‏ק המכזום בûעü 16 סטלגמכמג!", vbExclamation
        Exit Sub
    End If
    ' Starting a PowerShell script SendToArduino & sending key
    psCommand = "powershell -ExecutionPolicy Bypass -File ""E:\GitHub\Student-Attendance-System-Arduino-RFID\PowerShell\SendToArduino.ps1"" -Key """ & Key & """"
    
    result = shell(psCommand, vbHide)

    MsgBox "The key was sent to the Arduino successfully!", vbInformation
End Sub

Private Sub Form_Current()

End Sub
