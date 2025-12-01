VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_AutoStart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim lastLineIndex As Long

Private Sub Form_Load()
    lastLineIndex = 1

    ' Запуск PowerShell скрипта в скрытом режиме
    Dim cmd As String
    cmd = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""E:\GitHub\Student-Attendance-System-Arduino-RFID\PowerShell\MonitorArduino.ps1"""
    shell cmd, vbHide
End Sub

Private Sub Form_Timer()
    Dim filePath As String
    Dim fileLines() As String
    Dim fso As Object, ts As Object
    Dim i As Long
    Dim Key As String

    filePath = "E:\GitHub\Student-Attendance-System-Arduino-RFID\Incoming_keys.txt"

    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(filePath) Then
        Set ts = fso.OpenTextFile(filePath, 1) ' ForReading
        fileLines = Split(ts.ReadAll, vbCrLf)
        ts.Close

        Debug.Print "? Индекс чтения (до): " & lastLineIndex

        ' Если файл полностью пустой — сбросить индекс
        If UBound(fileLines) = 0 And Trim(fileLines(0)) = "" Then
            lastLineIndex = 0
            Debug.Print "? Файл пуст. Индекс сброшен до 0."
            Exit Sub
        End If

        If UBound(fileLines) >= lastLineIndex Then
            For i = lastLineIndex To UBound(fileLines)
                Key = Trim(fileLines(i))
                If Len(Key) = 16 Then
                    InsertAttendance Key
                    Debug.Print "? Ключ записан: " & Key
                    lastLineIndex = lastLineIndex + 1
                ElseIf Len(Key) > 0 Then
                    Debug.Print "? Невалидный ключ: " & Key & " (длина: " & Len(Key) & ")"
                    lastLineIndex = lastLineIndex + 1
                Else
                    Debug.Print "? Пропущена пустая строка на позиции: " & i
                    ' Не увеличиваем индекс
                End If
            Next i
        End If

        Debug.Print "? Индекс чтения (после): " & lastLineIndex
    Else
        Debug.Print "? Файл не найден: " & filePath
    End If
End Sub



Private Sub InsertAttendance(StudentKey As String)
    Dim sql As String
    Dim rs As DAO.Recordset

    On Error Resume Next
    StudentKey = Trim(StudentKey)

    Set rs = CurrentDb.OpenRecordset("SELECT * FROM Students WHERE StudentKey = '" & StudentKey & "'")

    If Not rs.EOF Then
        sql = "INSERT INTO AttendanceLog (StudentKey, DetectedTime, FirstName, LastName, Specialty, Course) VALUES (" & _
              "'" & StudentKey & "', Now(), " & _
              "'" & rs!FirstName & "', " & _
              "'" & rs!LastName & "', " & _
              "'" & rs!Specialty & "', " & _
              "'" & rs!Course & "')"

        CurrentDb.Execute sql
        Debug.Print "? Посещение добавлено: " & StudentKey
    Else
        Debug.Print "? Студент не найден: " & StudentKey
    End If

    rs.Close
    Set rs = Nothing
End Sub


