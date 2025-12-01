VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Add_Student"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

' В САМОМ ВЕРХУ модуля:
#If VBA7 Then
    Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As LongPtr)
#Else
    Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
#End If

Private Sub btnAddStudent_Click()
    Dim Key As String
    Dim symbols As String
    Dim i As Integer
    
    ' Генерация 16-символьного ключа
    symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    Randomize
    Key = ""
    For i = 1 To 16
        Key = Key & Mid(symbols, Int((Len(symbols) * Rnd) + 1), 1)
    Next i
    
    ' Добавляем запись в таблицу Students
    CurrentDb.Execute "INSERT INTO Students (FirstName, LastName, Course, Specialty, StudentKey) " & _
                      "VALUES ('" & Me.FirstName & "', '" & Me.txtLastName & "', '" & Me.txtCourse & "', '" & Me.txtSpecialty & "', '" & Key & "')"
    
    MsgBox "Student added successfully!" & vbCrLf & "Key: " & Key, vbInformation
    
    ' Очищаем поля ввода
    Me.FirstName = ""
    Me.txtLastName = ""
    Me.txtCourse = ""
    Me.txtSpecialty = ""
    
    ' Записываем ключ в текстовое поле для отправки на Arduino
    Me.txtStudentKey = Key
End Sub




Private Sub btnSendToArduino_Click()
    Dim Key As String
    Dim killCommand As String
    Dim psCommand As String
    Dim result As Double

    Key = Me.txtStudentKey.Value
    If Len(Key) <> 16 Then
        MsgBox "Ключ должен быть 16 символов!", vbExclamation
        Exit Sub
    End If
    ' Команда запуска PowerShell с передачей ключа
    psCommand = "powershell -ExecutionPolicy Bypass -File ""E:\GitHub\Student-Attendance-System-Arduino-RFID\PowerShell\SendToArduino.ps1"" -Key """ & Key & """"
    
    result = shell(psCommand, vbHide)

    MsgBox "Ключ отправлен на Arduino!", vbInformation
End Sub

Private Sub Form_Current()

End Sub
