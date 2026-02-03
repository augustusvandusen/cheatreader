EnableExplicit

Global MainWindow, TextArea, FileList, ButtonRefresh
Global ButtonFontPlus, ButtonFontMinus, TextFontSize, ButtonExit
Global currentFontSize.i = 12

; variables
Define text.s  ; text from file
Define event.i ; main window event
Define index.i ; file list index

Enumeration FormFont
  #Font_Text
  #Font_FileList
EndEnumeration

LoadFont(#Font_Text, "Consolas", 12)
LoadFont(#Font_FileList, "Consolas", 11)



Procedure UpdateFont()
  LoadFont(#Font_Text, "Consolas", currentFontSize)
  SetGadgetFont(TextArea, FontID(#Font_Text))
  SetGadgetText(TextFontSize, Str(currentFontSize))
EndProcedure


Procedure OpenMainWindow(x = 80, y = 40, width = 1000, height = 800)
  MainWindow = OpenWindow(#PB_Any, x, y, width, height, " CheatReader", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
  
  AddWindowTimer(MainWindow, 0, 900)
  
  CreateStatusBar(0, WindowID(MainWindow))
  AddStatusBarField(#PB_Ignore)
  AddStatusBarField(#PB_Ignore)
  
  TextArea = EditorGadget(#PB_Any, 10, 10, 800, 760, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  SetGadgetColor(TextArea, #PB_Gadget_FrontColor,RGB(0,255,0))
  SetGadgetColor(TextArea, #PB_Gadget_BackColor,RGB(0,0,0))
  SetGadgetFont(TextArea, FontID(#Font_Text))
  
  FileList = ListViewGadget(#PB_Any, 820, 10, 170, 600)
  SetGadgetColor(FileList, #PB_Gadget_FrontColor,RGB(10,10,10))
  SetGadgetColor(FileList, #PB_Gadget_BackColor,RGB(192,192,192))
  SetGadgetFont(FileList, FontID(#Font_FileList))
  
  ButtonRefresh = ButtonGadget(#PB_Any, 820, 620, 170, 30, "Refresh")
  
  ButtonFontMinus = ButtonGadget(#PB_Any, 820, 660, 40, 20, "-")
  TextFontSize = TextGadget(#PB_Any, 860, 664, 90, 20, "Font: " + Str(currentFontSize), #PB_Text_Center)
  ButtonFontPlus = ButtonGadget(#PB_Any, 950, 660, 40, 20, "+")
  SetGadgetFont(TextFontSize, GetGadgetFont(ButtonRefresh))
  
  ButtonExit = ButtonGadget(#PB_Any, 820, 740, 170, 30, "Exit")
EndProcedure

 
Procedure.s LoadFile(filename.s)
  Define text.s
  ReadFile(0, filename)   
  While Eof(0) = 0          
    text = text + ReadString(0) + Chr(13) + Chr(10)       
  Wend
  CloseFile(0)
  ProcedureReturn text
EndProcedure

Procedure LoadTxtFilesToListView(directory.s, GadgetID)
  Protected dirID, fileName.s
  ClearGadgetItems(GadgetID)
  
  If Right(directory, 1) <> "\" And Right(directory, 1) <> "/"
    directory + "\"
  EndIf
  
  dirID = ExamineDirectory(#PB_Any, directory, "*.txt")
  If dirID
    While NextDirectoryEntry(dirID)
      If DirectoryEntryType(dirID) = #PB_DirectoryEntry_File
        fileName.s = DirectoryEntryName(dirID)
        If LCase(fileName.s) <> "start.txt"
          AddGadgetItem(gadgetID, -1, fileName.s)
        EndIf
      EndIf
    Wend
    FinishDirectory(dirID)
  EndIf
EndProcedure


OpenMainWindow() 
LoadTxtFilesToListView(".", FileList)

If FileSize(".\start.txt") > -1
  SetGadgetText(TextArea, LoadFile("start.txt"))
  StatusBarText(0, 0, " start.txt: " + Str(FileSize("start.txt")) + " Chars")
Else
  SetGadgetText(TextArea, "Welcome to CheatReader!" + #CRLF$ + #CRLF$ + "Select a file from the list on the right.")
EndIf

  
Repeat
  event = WaitWindowEvent()
  Select event
    Case #PB_Event_Timer
      StatusBarText(0, 1, FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss ", Date()), #PB_StatusBar_Right)
    Case #PB_Event_SizeWindow
      ResizeGadget(TextArea, #PB_Ignore, #PB_Ignore, WindowWidth(MainWindow) - 200, WindowHeight(MainWindow) - 40)
      ResizeGadget(FileList, WindowWidth(MainWindow) - 180, #PB_Ignore, #PB_Ignore, WindowHeight(MainWindow) - 200)
      ResizeGadget(ButtonRefresh, WindowWidth(MainWindow) - 180, WindowHeight(MainWindow) - 180, #PB_Ignore, #PB_Ignore)
      ResizeGadget(ButtonFontMinus, WindowWidth(MainWindow) - 180, WindowHeight(MainWindow) - 140, #PB_Ignore, #PB_Ignore)
      ResizeGadget(TextFontSize, WindowWidth(MainWindow) - 140, WindowHeight(MainWindow) - 136, #PB_Ignore, #PB_Ignore)
      ResizeGadget(ButtonFontPlus, WindowWidth(MainWindow) - 50, WindowHeight(MainWindow) - 140, #PB_Ignore, #PB_Ignore)
      ResizeGadget(ButtonExit, WindowWidth(MainWindow) - 180, WindowHeight(MainWindow) - 60, #PB_Ignore, #PB_Ignore)
    Case #PB_Event_Gadget
      Select EventGadget()
        Case FileList
          Select EventType()
            Case #PB_EventType_LeftClick          
              index = GetGadgetState(FileList)
              SetGadgetText(TextArea, LoadFile(GetGadgetItemText(FileList, index)))
              StatusBarText(0, 0, " " + GetGadgetItemText(FileList, index) + ": " + FileSize(GetGadgetItemText(FileList, index)) + " Chars")
          EndSelect
        Case ButtonRefresh
          LoadTxtFilesToListView(".", FileList)
        Case ButtonFontPlus
          If currentFontSize < 24
            currentFontSize + 1
            UpdateFont()
          EndIf
        Case ButtonFontMinus
          If currentFontSize > 8
            currentFontSize - 1
            UpdateFont()
          EndIf
        Case ButtonExit
          End
      EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 114
; FirstLine = 71
; Folding = -
; EnableXP
; DPIAware