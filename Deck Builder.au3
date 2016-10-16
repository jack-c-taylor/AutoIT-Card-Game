#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#include <GuiImageList.au3>
#include <GUIListBox.au3>
#include <EditConstants.au3>

GUICreate("Deck Builder", 730, 440)
GUISetState(@SW_SHOW)
GUISetBkColor(0xD8E4DF)

GUISetFont(8.5, 700)
 $buttonList = _GUIImageList_Create(100,30)
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonNormal.bmp');1 - Normal
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonHot.bmp')   ;2 - Hot
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonPressed.bmp') ;3 - Pressed
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonDisabled.bmp');4 - Disabled
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonHot.bmp');5 - Defaulted
_GUIImageList_AddBitmap($buttonList, @ScriptDir&'\Graphics\GUI\ButtonHot.bmp');6 - Stylus Hot (tablet computers only)
$1=GUICtrlCreateButton("Add Card", 90, 350, 100)
$2=GUICtrlCreateButton("Remove Card", 350, 350, 100)
$3=GUICtrlCreateButton("Reset", 280, 400, 100)
$4=GUICtrlCreateButton("Quit", 410, 400, 100)
$5=GUICtrlCreateButton("Remove All", 150, 400, 100)
$6=GUICtrlCreateButton("Add All", 20, 400, 100)
_GUICtrlButton_SetImageList($1, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($2, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($3, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($4, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($5, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($6, $buttonList, 4,-2)
GUISetFont(9,0)

GUICtrlCreateLabel("In deck:", 20, 20)
GUICtrlCreateLabel("Possible cards:", 280, 20)
$list=GUICtrlCreateList("", 20, 50, 230, 300)
$list2=GUICtrlCreateList("", 280, 50, 230, 300)
GUICtrlSetState($list,$GUI_FOCUS)

$pic=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',530, 240, 180, 180)
$hand_description=GUICtrlCreateInput("", 530, 60, 180, 140,$ES_MULTILINE)
$name=GUICtrlCreateInput("", 530, 20, 180, 20)
$typemonster=GUICtrlCreateInput("", 530, 210, 80, 20)
$typeelement=GUICtrlCreateInput("", 630, 210, 80, 20)
GUICtrlSetState($name,128)
GUICtrlSetState($typemonster,128)
GUICtrlSetState($typeelement,128)


FillList()
FillList2()
_GUICtrlListBox_SetCurSel($list, 0)
GUICtrlSetState($1,128)
While 1
   $msg =GUIGetMsg(1)
   Select
   Case $msg[0]=$1 ;Add Card
	  If Not GUICtrlRead($list2)="" Then
	  $decksize=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",40)
	  $j=False
	  For $i=1 to $decksize
		 $a=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck",$i,"")
		 If GUICtrlRead($list2)=StringLeft($a,StringInStr($a,'~')-1) Then
			$j=True
			ExitLoop
		 EndIf
	  Next
	  If $j=False Then
		 $b=IniRead(@ScriptDir&'\Settings\Definitions.ini',"cardref",GUICtrlRead($list2),"")
		 IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck",$decksize+1,IniRead(@ScriptDir&'\Settings\Definitions.ini',"cards",$b,""))
		 IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",$decksize+1)
		 Update()
	  EndIf
	  EndIf
	  _GUICtrlListBox_SetCurSel($list2, _GUICtrlListBox_GetCurSel($list2)+1)
	  Define($list2)
   Case $msg[0]=$2 ;Remove Card
	  $decksize=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",40)
	  If $decksize>1 And GUICtrlRead($list)<>"" Then
		 $j=40
		 For $i=1 to $decksize
			$a=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck",$i,"")
			If GUICtrlRead($list)=StringLeft($a,StringInStr($a,'~')-1) Then
			   $j=$i
			   ExitLoop
			EndIf
		 Next
		 For $i=$j to $decksize-1
			IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck",$i, IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck",$i+1,""))
		 Next
		 IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck",$decksize)
		 IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",$decksize-1)
		 $c=_GUICtrlListBox_GetCurSel($list)
		 Update()
		 _GUICtrlListBox_SetCurSel($list, $c)
	  EndIf
	  Define($list)
   Case $msg[0]=$3 ;Reset
	  IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck")
	  IniWriteSection(@ScriptDir&'\Settings\Definitions.ini',"deck",IniReadSection(@ScriptDir&'\Settings\Definitions.ini',"recommended"))
	  IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck","CardNo")
	  IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize", 40)
	  Update()
   Case $msg[0]=$4 ;Quit
	  ExitLoop
   Case $msg[0]=$5 ;Remove All
	  $decksize=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",40)
	  For $i=2 to $decksize
		 IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck",$i)
	  Next
	  IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",1)
	  Update()
	  If GUICtrlRead($list2)="" Then _GUICtrlListBox_SetCurSel($list, 0)
   Case $msg[0]=$6 ;Add All
	  IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck")
	  IniWriteSection(@ScriptDir&'\Settings\Definitions.ini',"deck",IniReadSection(@ScriptDir&'\Settings\Definitions.ini',"cards"))
	  IniDelete(@ScriptDir&'\Settings\Definitions.ini',"deck","CardNo")
	  IniWrite(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize", IniRead(@ScriptDir&'\Settings\Definitions.ini',"cards","CardNo",1))
	  Update()
	  If GUICtrlRead($list2)="" Then _GUICtrlListBox_SetCurSel($list, 0)
   Case $msg[0]=$list
	  GUICtrlSetState($1,128)
	  GUICtrlSetState($2,64)
	   _GUICtrlListBox_SetCurSel($list2, -1)
	   Define($list)
   Case $msg[0]=$list2
	  GUICtrlSetState($1,64)
	  GUICtrlSetState($2,128)
	  _GUICtrlListBox_SetCurSel($list, -1)
	  Define($list2)
   Case $msg[0]=$GUI_EVENT_CLOSE
	  ExitLoop

   EndSelect
WEnd

Func FillList()
   For $i=1 to IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",40)
	  $a=IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck",$i,"")
	  GUICtrlSetData($list,StringLeft($a,StringInStr($a,'~')-1))
   Next
EndFunc

Func FillList2()
   For $i=1 to IniRead(@ScriptDir&'\Settings\Definitions.ini',"cards","CardNo",40)
	  $a=IniRead(@ScriptDir&'\Settings\Definitions.ini',"cards",$i,"")
	  GUICtrlSetData($list2,StringLeft($a,StringInStr($a,'~')-1))
   Next
EndFunc

Func Update()
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 50, 230, 300)
   FillList()
EndFunc

Func Define($var)
   $b=GUICtrlRead($var)
   $a=IniRead(@ScriptDir&'\Settings\Definitions.ini',"cardref",$b,"")
   If Not $a="" Then
	  $array=Stringsplit(IniRead(@ScriptDir&'\Settings\Definitions.ini',"cards",$a,""),'~')
	  GUICtrlSetData($hand_description, $array[5]&" mana."&@CRLF&$array[2])
	  GUICtrlSetData($name, $array[1])
	  GUICtrlSetData($typemonster, $array[3])
	  GUICtrlSetData($typeelement, $array[4])
	  GUICtrlDelete($pic)
	  $b=StringReplace($b," ","_")
	  $pic=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$b&'.jpg',530, 240, 180, 180)
   EndIf
EndFunc