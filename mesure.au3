#include <WindowsConstants.au3>
#include <GuiListBox.au3>

Global $g_StartSearch = False, $gOldCursor
Global $ICON_TARGET_FULL = @TempDir & "\122345567.ico"
Global $ICON_TARGET_EMPTY = @TempDir & "\112314645.ico"
Global $CURSOR_TARGET = @TempDir & "\134234323"

FileInstall("122345567.ico", $ICON_TARGET_FULL)
FileInstall("112314645.ico", $ICON_TARGET_EMPTY)
FileInstall("134234323", $CURSOR_TARGET)

$hTargetCursor = DllCall("User32.dll", "int", "LoadCursorFromFile", "str", $CURSOR_TARGET)
$hTargetCursor = $hTargetCursor[0]

Opt("GUIOnEventMode", 1)

$Form1_1 = GUICreate("距离测量工具", 350, 200, 209, 157)
$Group1 = GUICtrlCreateGroup("距离测量", 20, 16, 310, 145)
$Group3 = GUICtrlCreateGroup("拖动定位", 52, 32, 65, 57)
$Icon1 = GUICtrlCreateIcon($ICON_TARGET_FULL, -0, 67, 50, 32, 32)

$Label11 = GUICtrlCreateLabel("第一个点的坐标:", 150, 35, 150, 17)
$Label12 = GUICtrlCreateLabel("第二个点的坐标:", 150, 55, 150, 17)
$Label13 = GUICtrlCreateLabel("他们之间的距离:", 150, 75, 150, 17)

$List2 = GUICtrlCreateList("", 52, 100, 180, 58)
GUICtrlSetTip(-1, "点击坐标列表")
$Button7 = GUICtrlCreateButton("删除", 250, 100, 43, 25)
$Button11 = GUICtrlCreateButton("清空", 250, 130, 43, 25)

GUICtrlSetTip(-1, "拖动该图标到点击点进行定位")
GUISetState(@SW_SHOW)

GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEClicked")
GUICtrlSetOnEvent($Button7, "DeletePoint")
GUICtrlSetOnEvent($Button11, "ClearPoint")
GUICtrlSetOnEvent($Icon1, "StartDrag")
GUIRegisterMsg($WM_MOUSEMOVE, "Draging")
GUIRegisterMsg($WM_LBUTTONUP, "StopDrag")

Global $status = 0
Global $point1 = 0

While 1
    Sleep(100)
WEnd

Func StartDrag()
	$g_StartSearch = True
	DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $Form1_1)
	$gOldCursor = DllCall("user32.dll", "int", "SetCursor", "int", $hTargetCursor)
	If Not @error Then $gOldCursor = $gOldCursor[0]
	GUICtrlSetImage($Icon1, $ICON_TARGET_EMPTY)
    $tmpsta = $status
    if $tmpsta = 0 Then 
        $status = 1
        GUICtrlSetData($Label11, "第一个点的坐标:")
        GUICtrlSetData($Label12, "第二个点的坐标:")
        GUICtrlSetData($Label13, "两点间距离是:")
    EndIf
    if $tmpsta = 1 Then $status = 2
EndFunc   ;==>StartDrag

Func Draging($hWnd, $nMsg, $wParam, $lParam)
	If Not $g_StartSearch Then Return 1
	$pos = MouseGetPos()
    if $status = 1 Then GUICtrlSetData($Label11, "第一个点的坐标:"&$pos[0]&","&$pos[1])
    if $status = 2 Then 
        GUICtrlSetData($Label12, "第二个点的坐标:"&$pos[0]&","&$pos[1])
        $dis = sqrt(($point1[0]-$pos[0])^2 +($point1[1]-$pos[1])^2)
        GUICtrlSetData($Label13, "两点间距离是:"&Floor($dis))
    EndIf
EndFunc   ;==>Draging

Func StopDrag($hWnd, $nMsg, $wParam, $lParam)
	If Not $g_StartSearch Then Return 1
	$g_StartSearch = False
	; Release captured cursor
	DllCall("user32.dll", "int", "ReleaseCapture")
	DllCall("user32.dll", "int", "SetCursor", "int", $gOldCursor)
	GUICtrlSetImage($Icon1, $ICON_TARGET_FULL)
	$pos = MouseGetPos()
    if $status = 1 Then 
        $point1 = $pos
    EndIf
    if $status = 2 Then 
        $dis = sqrt(($point1[0]-$pos[0])^2 +($point1[1]-$pos[1])^2)
        GUICtrlSetData($Label13, "两点间距离是:"&Floor($dis))
        $status = 0
        _GUICtrlListBox_InsertString($List2, $point1[0]&","&$point1[1]&"|"&$pos[0]&","&$pos[1]&"|"&Floor($dis))
    EndIf
	
	Return 1
EndFunc   ;==>StopDrag

Func CLOSEClicked()
	; MsgBox(0, "GUI Event", "You clicked CLOSE! Exiting...")
	Exit
EndFunc   ;==>CLOSEClicked

Func DeletePoint()
    $idx = _GUICtrlListBox_GetCurSel($List2)
	_GUICtrlListBox_DeleteString($List2,$idx)
EndFunc

Func ClearPoint()
    _GUICtrlListBox_ResetContent($List2)
    $point1 = 0
    $status = 0
    GUICtrlSetData($Label11, "第一个点的坐标:")
    GUICtrlSetData($Label12, "第二个点的坐标:")
    GUICtrlSetData($Label13, "两点间距离是:")
EndFunc


























;While 1
;	$nMsg = GUIGetMsg()
;	Switch $nMsg
;		Case $GUI_EVENT_CLOSE
;			Exit
;		Case $Button1
;			MsgBox(0,"tt","Button1")
;			if $getting_pos = 0 Then
;            	$getting_pos = 1
;		    Else
;				$getting_pos = 0
;			EndIf
;		Case $GUI_EVENT_MOUSEMOVE
;			 $pos = MouseGetPos()
;			 if $getting_pos = 1 Then
;              GUICtrlSetData($Input1,$pos[0])
;               GUICtrlSetData($Input2,$pos[1])
;		   EndIf
;		Case $WM_LBUTTONDOWN
;         _WinAPI_SetCursor(32515)
;	EndSwitch
;WEnd



;While True
;	sleep(1)
;  if _WinAPI_GetAsyncKeyState(0x01) Then
;	MsgBox(0,"left mouse","down")
;  EndIf
;  if _WinAPI_GetAsyncKeyState(0x02) Then
;	MsgBox(0,"right mouse","down")
;EndIf
;  if _WinAPI_GetAsyncKeyState(0x1b) Then
;	MsgBox(0,"escape","escape")
;	Exit
;  EndIf
;WEnd
