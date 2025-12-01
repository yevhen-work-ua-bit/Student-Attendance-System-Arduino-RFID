Attribute VB_Name = "Selection"
Option Compare Database

Public Sub FillAttendanceData()
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim studentFirstName As Variant
    Dim studentLastName As Variant
    Dim studentSpecialty As Variant
    Dim studentCourse As Variant

    Set db = CurrentDb()
    Set rs = db.OpenRecordset("AttendanceLog", dbOpenDynaset)

    If Not rs.EOF Then
        rs.MoveFirst
        Do Until rs.EOF
            ' Only update if FirstName is empty (means record is not yet filled)
            If IsNull(rs!FirstName) Or rs!FirstName = "" Then
                studentFirstName = DLookup("FirstName", "Students", "StudentKey = '" & rs!StudentKey & "'")
                studentLastName = DLookup("LastName", "Students", "StudentKey = '" & rs!StudentKey & "'")
                studentSpecialty = DLookup("Specialty", "Students", "StudentKey = '" & rs!StudentKey & "'")
                studentCourse = DLookup("Course", "Students", "StudentKey = '" & rs!StudentKey & "'")

                If Not IsNull(studentFirstName) Then
                    rs.Edit
                    rs!FirstName = studentFirstName
                    rs!LastName = studentLastName
                    rs!Specialty = studentSpecialty
                    rs!Course = studentCourse
                    rs!DetectedTime = Now() ' Set current date and time
                    rs.Update
                End If
            End If
            rs.MoveNext
        Loop
    End If

    rs.Close
    Set rs = Nothing
    Set db = Nothing
End Sub

