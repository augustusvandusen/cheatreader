EnableExplicit

Global MainWindow, TextArea, FileList, ButtonRefresh

; variables
Define text.s  ; text from file
Define event.i ; main window event
Define index.i ; file list index

Enumeration FormFont
  #Font_MainWindow_0
  #Font_MainWindow_1
EndEnumeration

LoadFont(#Font_MainWindow_0,"Consolas", 12)
LoadFont(#Font_MainWindow_1,"Consolas", 11)

Procedure OpenMainWindow(x = 80, y = 40, width = 1000, height = 800)
  MainWindow = OpenWindow(#PB_Any, x, y, width, height, " CheatReader", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
  
  AddWindowTimer(MainWindow, 0, 900)
  
  CreateStatusBar(0, WindowID(MainWindow))
  AddStatusBarField(#PB_Ignore)
  AddStatusBarField(#PB_Ignore)
  
  TextArea = EditorGadget(#PB_Any, 10, 10, 800, 760, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
  SetGadgetColor(TextArea, #PB_Gadget_FrontColor,RGB(0,255,0))
  SetGadgetColor(TextArea, #PB_Gadget_BackColor,RGB(0,0,0))
  SetGadgetFont(TextArea, FontID(#Font_MainWindow_0))
  
  FileList = ListViewGadget(#PB_Any, 820, 10, 170, 600)
  SetGadgetColor(FileList, #PB_Gadget_FrontColor,RGB(10,10,10))
  SetGadgetColor(FileList, #PB_Gadget_BackColor,RGB(192,192,192))
  SetGadgetFont(FileList, FontID(#Font_MainWindow_1))
  
  ButtonRefresh = ButtonGadget(#PB_Any, 820, 620, 170, 30, "Refresh")
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
        AddGadgetItem(gadgetID, -1, fileName.s)
      EndIf
    Wend
    FinishDirectory(dirID)
  EndIf
EndProcedure


OpenMainWindow() 
LoadTxtFilesToListView(".", FileList)

  
Repeat
  event = WaitWindowEvent()
  Select event
    Case #PB_Event_Timer
      StatusBarText(0, 1, FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss ", Date()), #PB_StatusBar_Right)
    Case #PB_Event_SizeWindow
      ResizeGadget(TextArea, #PB_Ignore, #PB_Ignore, WindowWidth(MainWindow) - 200, WindowHeight(MainWindow) - 40)
      ResizeGadget(FileList, WindowWidth(MainWindow) - 180, #PB_Ignore, #PB_Ignore, WindowHeight(MainWindow) - 200)
      ResizeGadget(ButtonRefresh, WindowWidth(MainWindow) - 180, WindowHeight(MainWindow) - 180, #PB_Ignore, #PB_Ignore)
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
      EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 88
; FirstLine = 38
; Folding = -
; EnableXP
; DPIAware