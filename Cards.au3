#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <GuiButton.au3>
#include <GuiImageList.au3>
#Include <GUIEdit.au3>

GUICreate("Card Game", 840, 440)
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
$1=GUICtrlCreateButton("Play Card", 20, 400, 100)
$2=GUICtrlCreateButton("End Turn", 150, 350, 100)
$3=GUICtrlCreateButton("Save and Quit", 150, 400, 100)
$4=GUICtrlCreateButton("Quit", 280, 400, 100)
$5=GUICtrlCreateButton("Restart", 280, 350, 100)
$6=GUICtrlCreateButton("Graveyard", 20, 350, 100)
_GUICtrlButton_SetImageList($1, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($2, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($3, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($4, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($5, $buttonList, 4,-2)
_GUICtrlButton_SetImageList($6, $buttonList, 4,-2)
GUISetFont(9,0)

$pic=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',220, 150, 180, 180)
$hand_description=GUICtrlCreateInput("", 20, 190, 180, 140,$ES_MULTILINE)
$typemonster=GUICtrlCreateInput("", 20, 150, 80, 20)
$typeelement=GUICtrlCreateInput("", 120, 150, 80, 20)
GUICtrlSetState($typemonster,128)
GUICtrlSetState($typeelement,128)

$pic2=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',620, 250, 180, 180)
$field_description=GUICtrlCreateInput("", 420, 320, 180, 110,$ES_MULTILINE)
$typemonster2=GUICtrlCreateInput("", 420, 280, 80, 20)
$typeelement2=GUICtrlCreateInput("", 520, 280, 80, 20)
GUICtrlSetState($typemonster2,128)
GUICtrlSetState($typeelement2,128)

$list=GUICtrlCreateList("", 20, 30, 320, 90)
$gamelog=GUICtrlCreateEdit("Game start.", 420, 50, 400, 180, $WS_VSCROLL)
GUICtrlCreateLabel("Hand:" , 20, 10)
GUICtrlCreateLabel("Info:" , 20, 120)
$fieldname=GUICtrlCreateLabel("Field Card: "&IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field", 1, "None") , 420, 250, 200)

$stats=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "stats", 1,"2000,3,8000,1"),",");Health, Mana, Style, Turns
$oppstats=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "stats", 2,"0,0,0"),",");Effect, Duration, Damage
$update=GUICtrlCreateLabel("Health:"&$stats[1]&" Mana:"&$stats[2]&"         Enemy Health:"&$stats[3]&"        " , 420, 20)
$enstatus=GUICtrlCreateLabel("Enemy Status:Normal       ", 690, 20)

$health=GUICtrlCreateProgress(420, 10, 100, 10)
$enhealth=GUICtrlCreateProgress(557, 10, 100, 10)
GUICtrlSetData($health,($stats[1])/20)
GUICtrlSetData($enhealth,($stats[3])/80)

If UBound(IniReadSection ( "Save.ini", "hand" ))=0 then
   Setup(5)
Else
   HandCreate($list, "hand")
EndIf

$shadowscape=True
Update()
While 1
   $msg =GUIGetMsg(1)
   Select
   Case $msg[0]=$1 ;Play Card
	  $iEnd = StringLen(GUICtrlRead($gamelog))
	  _GUICtrlEdit_SetSel($gamelog, $iEnd, $iEnd)
	  $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1,""),",")
	  $array4=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
	  $array5=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 5,""),",")
	  $b=StringLeft(GUICtrlRead($list),StringInStr(GUICtrlRead($list)," *")-1)
	  $a=_ArraySearch ($array, $b)
	  If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Clockwork_Town" And $array4[$a]="Time" And $stats[2]>=$array5[$a]-1 Then
		 $stats[2]-=$array5[$a]-1
		 PlayCard()
	  ElseIf $stats[2]>=$array5[$a] Then
		 $stats[2]-=$array5[$a]
		 PlayCard()
	  Else
		 GUICtrlSetData($gamelog, @CRLF&"Not enough mana!",1)
	  EndIf
	  If $stats[1]>2000 Then $stats[1]=2000
	  Update()
   Case $msg[0]=$2 ;End Turn
	  $iEnd = StringLen(GUICtrlRead($gamelog))
	  _GUICtrlEdit_SetSel($gamelog, $iEnd, $iEnd)
	  $stats[2]=3
	  If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Mundane_World" Then $stats[2]=2
	  If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Astral_Plane" Then $stats[2]=4
	  If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Shadowscape" and $shadowscape= True Then $stats[1]-=200
	  $stats[4]+=1
	  $shadowscape=True
	  EndTurn()
	  Update()
   Case $msg[0]=$3 ;Save and quit
	  ExitLoop
   Case $msg[0]=$4 ;Quit
	  FileDelete(@ScriptDir&'\Settings\'&"Save.ini")
	  ExitLoop
   Case $msg[0]=$5 ;Restart
	  FileDelete(@ScriptDir&'\Settings\'&"Save.ini")
	  GUICtrlDelete($list)
	  $list=GUICtrlCreateList("", 20, 30, 320, 90)
	  Setup(5)
	  $stats=StringSplit("2000,3,8000,1",",");Health, Mana, Style
	  $oppstats=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "stats", 2,"0,0,0"),",");Effect, Duration, Damage
	  GUICtrlSetState($1,64)
	  GUICtrlSetState($2,64)
	  GUICtrlSetState($3,64)
	  GUICtrlSetState($6,64)
	  GUICtrlSetData($gamelog, "Game start.")
	  GUICtrlDelete($pic)
	  $pic=GUICtrlCreateLabel("",0,0)
	  GUICtrlDelete($pic2)
	  $pic2=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',620, 250, 180, 180)
	  GUICtrlSetData($field_description,"")
	  GUICtrlSetData($typemonster2,"")
	  GUICtrlSetData($typeelement2,"")
	  Update()
   Case $msg[0]=$6 ;Graveyard
	  Graveyard()
   Case $msg[0]=$list ;Define
	  Define()
   Case $msg[0]=$GUI_EVENT_CLOSE
	  FileDelete(@ScriptDir&'\Settings\'&"Save.ini")
	  ExitLoop

   EndSelect

WEnd

Func Update()
   GUICtrlSetData($update, "Health:"&$stats[1]&" Mana:"&$stats[2]&"         Enemy Health:"&$stats[3])
   GUICtrlSetData($fieldname, "Field Card: "&IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field", 1, "None"))
   If $stats[1]<=0 Then
	  GUICtrlSetState($1,128)
	  GUICtrlSetState($2,128)
	  GUICtrlSetState($3,128)
	  GUICtrlSetState($6,128)
	  GUICtrlSetData($gamelog, @CRLF&"Game over!",1)
   EndIf
   If $stats[3]<=0 Then
	  GUICtrlSetState($1,128)
	  GUICtrlSetState($2,128)
	  GUICtrlSetState($3,128)
	  GUICtrlSetState($6,128)
	  GUICtrlSetData($gamelog, @CRLF&"Victory!",1)
	  MsgBox(0,"Game Over","Victory!")
   EndIf
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "stats", 1, $stats[1]&","&$stats[2]&","&$stats[3]&","&$stats[4])
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "stats", 2, $oppstats[1]&","&$oppstats[2]&","&$oppstats[3])
   GUICtrlSetData($health,($stats[1])/20)
   GUICtrlSetData($enhealth,($stats[3])/80)
   GUICtrlSetState($list,$GUI_FOCUS)
   Send("{DOWN}{UP}{UP}{UP}{UP}{UP}",0)
   $o=IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")
   If $o="None" Then
	  GUICtrlDelete($pic2)
	  $pic2=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',620, 250, 180, 180)
	  GUICtrlSetData($field_description, "")
	  GUICtrlSetData($typemonster2,"")
	  GUICtrlSetData($typeelement2,"")
   Else
	  $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Definitions.ini", "field", $o,""),"|")
	  GUICtrlDelete($pic2)
	  $pic2=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$o&'.jpg',620, 250, 180, 180)
	  GUICtrlSetData($field_description, $array[1])
	  GUICtrlSetData($typemonster2,"Field")
	  GUICtrlSetData($typeelement2,$array[2])
   EndIf
EndFunc

Func HandCreate($list, $place)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 1,""),",")
   For $i=1 to UBound($array)-1
	  If Not $array[$i]="" Then
	  $count=0
	  For $j=1 to UBound($array)-1
		 If $array[$i]=$array[$j] Then $count+=1
	  Next
	  GUICtrlSetData($list, $array[$i]&" *"&$count)
	  EndIf
   Next
EndFunc

Func ReadHand($place)
   Global $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 1,""),",")
   Global $array2=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 2,""),"|")
   Global $array3=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 3,""),",")
   Global $array4=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 4,""),",")
   Global $array5=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 5,""),",")
EndFunc

Func ReadHand2()
   Global $string=""
   Global $string2=""
   Global $string3=""
   Global $string4=""
   Global $string5=""
EndFunc

Func ReadHand3()
   Global $string=IniRead(@ScriptDir&'\Settings\'&"Save.ini","hand",1,"")
   Global $string2=IniRead(@ScriptDir&'\Settings\'&"Save.ini","hand",2,"")
   Global $string3=IniRead(@ScriptDir&'\Settings\'&"Save.ini","hand",3,"")
   Global $string4=IniRead(@ScriptDir&'\Settings\'&"Save.ini","hand",4,"")
   Global $string5=IniRead(@ScriptDir&'\Settings\'&"Save.ini","hand",5,"")
EndFunc

Func WriteHand($place, $i)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", $place, 1, IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 1, "")&","&$array[$i])
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", $place, 2, IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 2, "")&"|"&$array2[$i])
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", $place, 3, IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 3, "")&","&$array3[$i])
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", $place, 4, IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 4, "")&","&$array4[$i])
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", $place, 5, IniRead(@ScriptDir&'\Settings\'&"Save.ini", $place, 5, "")&","&$array5[$i])
EndFunc

Func WriteHand2()
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1, $string)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 2, $string2)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 3, $string3)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4, $string4)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 5, $string5)
EndFunc

Func PlayCard()
   $effectluck=True
   $o=StringLeft(GUICtrlRead($list),StringInStr(GUICtrlRead($list)," *")-1)
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   ReadHand("hand")
   $a=_ArraySearch ($array, $o)
   If $array4[$a]="Light" Then $shadowscape=False
   If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Arid_Plain" and $array4[$a]="Fire" Then $stats[1]-=100
   If IniRead(@ScriptDir&'\Settings\'&"Save.ini", "field",1,"None")="Cursed_Realm" and $array4[$a]="Luck" Then $effectluck=False
   ReadHand2()
   $otemp=$o
   For $i=1 to UBound($array)-1
	  If $array[$i]<>""  Then
		 If $array[$i]<>$otemp Then
			$string=$string&","&$array[$i]
			$string2=$string2&"|"&$array2[$i]
			$string3=$string3&","&$array3[$i]
			$string4=$string4&","&$array4[$i]
			$string5=$string5&","&$array5[$i]
			$count=0
			For $j=1 to UBound($array)-1
			   If $array[$i]=$array[$j] Then $count+=1
			Next
			GUICtrlSetData($list, $array[$i]&" *"&$count)
		 Else
			WriteHand("graveyard",$i)
			$otemp=""
			$array[$i]=""
		 EndIf
	  EndIf
   Next
   WriteHand2()
   If $effectluck=True Then
	  CardEffect($o)
   Else
	  GUICtrlSetData($gamelog, @CRLF&"Your luck is negated.",1)
   EndIf
EndFunc

Func Define()
   ReadHand("hand")
   $b=StringLeft(GUICtrlRead($list),StringInStr(GUICtrlRead($list)," *")-1)
   $a=_ArraySearch ($array, $b)
   GUICtrlSetData($hand_description, $array5[$a]&" mana."&@CRLF&$array2[$a])
   GUICtrlSetData($typemonster, $array3[$a])
   GUICtrlSetData($typeelement, $array4[$a])

   GUICtrlDelete($pic)
   $b=StringReplace($b," ","_")
   $pic=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$b&'.jpg',220, 150, 180, 180)
EndFunc

Func Setup($setup)
	  ReadHand2()
	  SubDraw($setup)
EndFunc

Func Draw($draw)
	  ReadHand3()
	  SubDraw($draw)
EndFunc

Func SubDraw($subdraw)
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   For $i=1 to $subdraw
	  $drawarray=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Definitions.ini","deck",Random(1,IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",1),1),"a~a~a~a~a"),"~")
	  If IniRead(@ScriptDir&'\Settings\Definitions.ini',"deck","DeckSize",1)=1 Then $drawarray=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Definitions.ini","deck",1,"a~a~a~a~a"),"~")
	  $string=$string&","&$drawarray[1]
	  GUICtrlSetData($gamelog, @CRLF&"You drew "&$drawarray[1]&".",1)
	  $string2=$string2&"|"&$drawarray[2]
	  $string3=$string3&","&$drawarray[3]
	  $string4=$string4&","&$drawarray[4]
	  $string5=$string5&","&$drawarray[5]
   Next
   WriteHand2()
   HandCreate($list, "hand")
EndFunc

Func EndTurn()
   Draw(1)
   OppMove()
EndFunc

Func Graveyard()
   GUICreate("Graveyard:", 800, 200)
   GUISetState(@SW_SHOWNORMAL)
   GUISetBkColor(0xD8E4DF)
   $list2=GUICtrlCreateList("", 20, 20, 280, 140)

   $pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',600, 10, 180, 180)
   $grave_description=GUICtrlCreateInput("", 400, 30, 180, 140,$ES_MULTILINE)
   $typemonster3=GUICtrlCreateInput("", 310, 50, 80, 20)
   $typeelement3=GUICtrlCreateInput("", 310, 130, 80, 20)
   GUICtrlSetState($typemonster3,128)
   GUICtrlSetState($typeelement3,128)
   HandCreate($list2,"graveyard")
   $Button=GUICtrlCreateButton("Close", 120, 170, 100)
   _GUICtrlButton_SetImageList($Button, $buttonList, 4,-2)
   While 1
	  $msg =GUIGetMsg(1)
	  Select
		 Case $msg[0]=$Button
			GUIDelete()
			ExitLoop
		 Case $msg[0]=$list2
			ReadHand("Graveyard")
			$b=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			$a=_ArraySearch ($array, $b)
			GUICtrlSetData($grave_description, $array5[$a]&" mana."&@CRLF&$array2[$a])
			GUICtrlSetData($typemonster3, $array3[$a])
			GUICtrlSetData($typeelement3, $array4[$a])
			GUICtrlDelete($pic3)
			$b=StringReplace($b," ","_")
			$pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$b&'.jpg',600, 10, 180, 180)
		 Case $msg[0]=$GUI_EVENT_CLOSE
			GUIDelete()
			ExitLoop
	  EndSelect
   WEnd
EndFunc

Func CardEffect($o)
   $o=StringReplace($o," ","_")
   Call($o)
EndFunc

Func OppMove()
   If $oppstats[1]=0 Then
	  $oppstats[3]=Random(1,5,1)
	  GUICtrlSetData($gamelog, @CRLF&"Opponent deals "&$oppstats[3]*100&" damage.",1)
	  $stats[1]-=$oppstats[3]*100
	  GUICtrlSetData($enstatus,"Enemy Status:Normal")
	  If Random(1,4,1)=4 Then
		 $names=Random(1,4,1)
		 If $names=1 Then IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Shadowscape")
		 If $names=2 Then IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Mundane_World")
		 If $names=3 Then IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Cursed_Realm")
		 If $names=4 Then IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Arid_Plain")
	  EndIf
   ElseIf $oppstats[2]=0 Then
	  $oppstats[1]=0
	  OppMove()
   Else
	  $oppstats[2]-=1
	  If $oppstats[1]=2 Then
		 $oppstats[3]=Random(1,10,1)
		 GUICtrlSetData($gamelog, @CRLF&"The darkness deals "&$oppstats[3]*100&" damage.",1)
		 $stats[1]-=$oppstats[3]*100
	  EndIf
	  If $oppstats[1]=3 Then
		 $oppstats[3]=Random(0,3,1)
		 GUICtrlSetData($gamelog, @CRLF&"Opponent is slowed, and deals "&$oppstats[3]*100&" damage.",1)
		 $stats[1]-=$oppstats[3]*100
	  EndIf
   EndIf
EndFunc

Func Alchemical_Breakthrough()
   GUICtrlSetData($gamelog, @CRLF&"[Alchemical Breakthrough] It'll cost an arm and a leg...",1)
   $stats[3]-=300
EndFunc

Func Burial_Rites()
   GUICtrlSetData($gamelog, @CRLF&"[Burial Rites] The dead break their bonds.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 1,""),",")
   $stats[3]-=100*(UBound($array)-1)
EndFunc

Func Calling_Card()
   GUICtrlSetData($gamelog, @CRLF&"[Calling Card] Once more with feeling.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If Not $array[$i]="" Then
	  For $j=1 to UBound($array)-1
		 If $array[$i]=$array[$j] Then $count+=1
	  Next
	  EndIf
   Next
   $stats[3]-=300*($count-UBound($array)+2)
EndFunc

Func Deadly_Trap()
   GUICtrlSetData($gamelog, @CRLF&"[Deadly Trap]Return to sender.",1)
   $stats[3]-=200*$oppstats[3]
EndFunc

Func Execution_Order()
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1,""),",",2)
   $count=0
   For $i=1 to UBound($array)-1
	  If Not $array[$i]="" Then $count+=1
   Next
   If $count>0 Then
   GUICtrlSetData($gamelog, @CRLF&"[Execution Order] A message to the others.",1)
   GUICreate("Select a card:", 400, 140)
   GUISetBkColor(0xD8E4DF)
   GUISetState(@SW_SHOWNORMAL)
   $list2=GUICtrlCreateList("", 20, 20, 320, 80)
   HandCreate($list2,"hand")
   $Button=GUICtrlCreateButton("Discard", 150, 100, 100)
   _GUICtrlButton_SetImageList($Button, $buttonList, 4,-2)
   While 1
	  $msg =GUIGetMsg(1)
	  Select
		 Case $msg[0]=$Button ;Play Card
			If Not GUICtrlRead($list2)="" Then
			   $o=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			   GUIDelete()
			   ExitLoop
			EndIf
	  EndSelect
   WEnd
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   ReadHand("hand")
   ReadHand2()
   For $i=1 to UBound($array)-1
	  If $array[$i]<>$o Then
		 If $array[$i]<>""  Then
		 $string=$string&","&$array[$i]
		 $string2=$string2&"|"&$array2[$i]
		 $string3=$string3&","&$array3[$i]
		 $string4=$string4&","&$array4[$i]
		 $string5=$string5&","&$array5[$i]
		 $count=0
		 For $j=1 to UBound($array)-1
			If $array[$i]=$array[$j] Then $count+=1
		 Next
		 GUICtrlSetData($list, $array[$i]&" *"&$count)
		 EndIf
	  Else
		 WriteHand("graveyard",$i)
		 $o=""
		 $array[$i]=""
	  EndIf
   Next
   WriteHand2()
   $stats[3]-=1500
   EndIf
EndFunc

Func Fireworks()
   GUICtrlSetData($gamelog, @CRLF&"[Fireworks] A simple distraction.",1)
   $stats[3]-=200
   $oppstats[1]=1
   $oppstats[2]=1
   GUICtrlSetData($enstatus,"Enemy Status:Harmless")
EndFunc

Func Glass_Houses()
   GUICtrlSetData($gamelog, @CRLF&"[Glass Houses] Casting stones.",1)
   $stats[3]-=100*$oppstats[3]
   $oppstats[1]=1
   $oppstats[2]=1
EndFunc

Func Healing_Magic()
   GUICtrlSetData($gamelog, @CRLF&"[Healing Magic] Better than a band-aid!",1)
   $stats[1]+=500
EndFunc

Func Invisibility()
   GUICtrlSetData($gamelog, @CRLF&"[Invisibility] Hidden from plain sight.",1)
   $oppstats[1]=1
   $oppstats[2]=2
   GUICtrlSetData($enstatus,"Enemy Status:Harmless")
EndFunc

Func Judgement_Day()
   GUICtrlSetData($gamelog, @CRLF&"[Judgement Day] The earth cracks.",1)
   $stats[1]-=100*Random(1,5,1)
   $stats[3]-=100*Random(8,12,1)
   IniDelete("Save.ini","field")
EndFunc

Func Keen_Eye()
   GUICtrlSetData($gamelog, @CRLF&"[Keen Eye] What's that on the floor?",1)
   Draw(2)
EndFunc

Func Life_Exchange()
   GUICtrlSetData($gamelog, @CRLF&"[Life Exchange] A necessary sacrifice.",1)
   $stats[1]-=200
   $stats[2]+=2
EndFunc

Func Magical_Overload()
   GUICtrlSetData($gamelog, @CRLF&"[Magical Overload] Dangerous, but pretty.",1)
   $stats[3]-=100*Random(1,3,1)
   $stats[2]+=1
EndFunc

Func Nightmare()
   GUICtrlSetData($gamelog, @CRLF&"[Nightmare] He's watching.",1)
   $stats[3]-=100*Random(5,8,1)
   $oppstats[1]=2
   $oppstats[2]=1
   GUICtrlSetData($enstatus,"Enemy Status:Empowered")
EndFunc

Func Old_Gods()
   GUICtrlSetData($gamelog, @CRLF&"[Old Gods] Dead, but not forever.",1)
   $stats[3]-=100*Random(10,14,1)
   $oppstats[1]=2
   $oppstats[2]=2
   GUICtrlSetData($enstatus,"Enemy Status:Empowered")
EndFunc

Func Petty_Revenge()
   GUICtrlSetData($gamelog, @CRLF&"[Petty Revenge] An eye for an eye.",1)
   $stats[3]-=100
   $oppstats[2]+=1
EndFunc

Func Quandary()
   GUICtrlSetData($gamelog, @CRLF&"[Quandary] Not stopped, but slowed.",1)
   $oppstats[1]=3
   $oppstats[2]=2
   $stats[3]-=200
   GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Reshuffling()
   GUICtrlSetData($gamelog, @CRLF&"[Reshuffling] A fresh start.",1)
   IniDelete("Save.ini", "hand")
   Setup(5)
EndFunc

Func Scientific_Revolution()
   GUICtrlSetData($gamelog, @CRLF&"[Scientific Revolution] Knowledge is power.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 1,""),",")
   If $array[UBound($array)-2]="Alchemical Breakthrough" Then
	  $stats[3]-=100*Random(8,15,1)
   Else
	  $stats[1]+=500
   EndIf
EndFunc

Func Time_Slows()
   GUICtrlSetData($gamelog, @CRLF&"[Time Slows] A magical respite.",1)
   $oppstats[1]=3
   $oppstats[2]=3
   GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Unholy_Ritual()
   GUICtrlSetData($gamelog, @CRLF&"[Unholy Ritual] Something stirs.",1)
   $stats[1]+=1000
   $oppstats[1]=2
   $oppstats[2]=3
   GUICtrlSetData($enstatus,"Enemy Status:Empowered")
EndFunc

Func Vendetta()
   GUICtrlSetData($gamelog, @CRLF&"[Vendetta] A history of violence.",1)
   $stats[3]-=500*$oppstats[3]
   $stats[1]-=500
EndFunc

Func Wildcard()
   GUICtrlSetData($gamelog, @CRLF&"[Wildcard] A joker in the mix.",1)
   $stats[3]-=100*Random(1,5,1)
   $oppstats[1]=Random(0,3,1)
   $oppstats[1]=Random(1,3,1)
   If $oppstats[1]=0 Then GUICtrlSetData($enstatus,"Enemy Status:None")
   If $oppstats[1]=1 Then GUICtrlSetData($enstatus,"Enemy Status:Harmless")
   If $oppstats[1]=2 Then GUICtrlSetData($enstatus,"Enemy Status:Empowered")
   If $oppstats[1]=3 Then GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Walrus_Attack()
   GUICtrlSetData($gamelog, @CRLF&"[Walrus Attack] Dangerous creatures.",1)
   $stats[3]-=100*Random(1,10,1)
EndFunc

Func Yesterday_Repeats()
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 1,""),",")
   If $array[UBound($array)-2] = "Yesterday Repeats" Then
	  GUICtrlSetData($gamelog, @CRLF&"[Yesterday Repeats] -Paradox.",1)
	  $stats[3]-=100*Random(10,30,1)
   Else
   GUICtrlSetData($gamelog, @CRLF&"[Yesterday Repeats] Deja vu.",1)
   CardEffect($array[UBound($array)-2])
   EndIf
EndFunc

Func Zombie_Horde()
   GUICtrlSetData($gamelog, @CRLF&"[Zombie Horde] Something of a shambles.",1)
   $stats[3]-=100*Random(5,10,1)
EndFunc

Func Artillery_Strike()
   GUICtrlSetData($gamelog, @CRLF&"[Artillery Strike] Mundane intervention.",1)
   $stats[3]-=700
EndFunc

Func Barrier()
   GUICtrlSetData($gamelog, @CRLF&"[Barrier] A safety bubble.",1)
   $oppstats[1]=1
   $oppstats[2]=1
   GUICtrlSetData($enstatus,"Enemy Status:Harmless")
EndFunc

Func Cold_Snap()
   GUICtrlSetData($gamelog, @CRLF&"[Cold Snap] An ice trick.",1)
   $stats[3]-=400
   $oppstats[1]=3
   $oppstats[2]=1
   GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Druidic_Curse()
   GUICtrlSetData($gamelog, @CRLF&"[Druidic Curse] Don't mess with trees.",1)
   $stats[3]-=400*$stats[2]
EndFunc

Func Ethereal_Force()
   GUICtrlSetData($gamelog, @CRLF&"[Ethereal Force] Ill-gotten power.",1)
   $stats[2]+=2
   $oppstats[1]=2
   $oppstats[2]=3
   GUICtrlSetData($enstatus,"Enemy Status:Empowered")
EndFunc

Func Fire_Spirits()
   GUICtrlSetData($gamelog, @CRLF&"[Fire Spirits] Hot stuff.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 4,""),",")
   $stats[3]-=500
   If $array[UBound($array)-2] = "Fire" Then $stats[3]-=500
EndFunc

Func Good_Fortune()
   GUICtrlSetData($gamelog, @CRLF&"[Good Fortune] See a penny, pick it up...",1)
   Draw(3)
   $stats[1]+=200
EndFunc

Func Heat_Wave()
   GUICtrlSetData($gamelog, @CRLF&"[Heat Wave] Drought season came early.",1)
   $oppstats[1]=3
   $oppstats[2]=3
   $stats[1]-=200
   GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Incantations()
   GUICtrlSetData($gamelog, @CRLF&"[Incantations] A smattering of spells.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 3,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Spell" Then $count+=1
   Next
   $stats[3]-=200*$count
EndFunc

Func Justice()
   GUICtrlSetData($gamelog, @CRLF&"[Justice] New crimes have come to light.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
   $count=1
   $count2=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Light" Then $count+=1
	  If $array[$i]="Light" Then $count2+=1
   Next
   $stats[3]-=400*$count
   $stats[1]-=200*$count
EndFunc

Func Kindness()
   GUICtrlSetData($gamelog, @CRLF&"[Kindness] A little out of place, here.",1)
   $stats[1]+=500
   $stats[3]+=200
EndFunc

Func Last_Laugh()
   GUICtrlSetData($gamelog, @CRLF&"[Last Laugh] A spiteful gesture.",1)
   $stats[3]-=300*Floor((2000-$stats[1])/400)
EndFunc

Func Mist()
   GUICtrlSetData($gamelog, @CRLF&"[Mist] Something's moving in there...",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Air" Then $count+=1
   Next
   $oppstats[1]=1
   $oppstats[2]=$count+1
   GUICtrlSetData($enstatus,"Enemy Status:Harmless")
EndFunc

Func Necromancy()
   GUICtrlSetData($gamelog, @CRLF&"[Necromancy] That which is dead may not eternal lie.",1)
   GUICreate("Graveyard:", 800, 200)
   GUISetState(@SW_SHOWNORMAL)
   GUISetBkColor(0xD8E4DF)
   $list2=GUICtrlCreateList("", 20, 20, 280, 140)
   $pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',600, 10, 180, 180)
   $grave_description=GUICtrlCreateInput("", 400, 30, 180, 140,$ES_MULTILINE)
   $typemonster3=GUICtrlCreateInput("", 310, 50, 80, 20)
   $typeelement3=GUICtrlCreateInput("", 310, 130, 80, 20)
   GUICtrlSetState($typemonster3,128)
   GUICtrlSetState($typeelement3,128)
   HandCreate($list2,"graveyard")

   $Button=GUICtrlCreateButton("Select", 120, 170, 100)
   _GUICtrlButton_SetImageList($1, $buttonList, 4,-2)
   While 1
	  $msg =GUIGetMsg(1)
	  Select
	  Case $msg[0]=$Button
			$o=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			GUIDelete()
			CardEffect($o)
			ExitLoop
	  Case $msg[0]=$list2
			ReadHand("graveyard")
			$b=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			$a=_ArraySearch ($array, $b)
			GUICtrlSetData($grave_description, $array5[$a]&" mana."&@CRLF&$array2[$a])
			GUICtrlSetData($typemonster3, $array3[$a])
			GUICtrlSetData($typeelement3, $array4[$a])
			GUICtrlDelete($pic3)
			$b=StringReplace($b," ","_")
			$pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$b&'.jpg',600, 10, 180, 180)
		 Case $msg[0]=$GUI_EVENT_CLOSE
			GUIDelete()
			ExitLoop
	  EndSelect
   WEnd
EndFunc

Func Overtime()
   GUICtrlSetData($gamelog, @CRLF&"[Overtime] A longer respite.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 4,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Time" Then $count+=1
   Next
   $stats[1]+=300*$count
EndFunc

Func Planar_Shift()
   GUICtrlSetData($gamelog, @CRLF&"[Planar Shift] The best way to travel.",1)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"None")
EndFunc

Func Quick_Draw()
   GUICtrlSetData($gamelog, @CRLF&"[Quick Draw] Best in the west.",1)
   $stats[3]-=400
   Draw(1)
EndFunc

Func Resurrection()
   GUICtrlSetData($gamelog, @CRLF&"[Resurrection] Fighting to the death, and beyond.",1)
   GUICreate("Graveyard:", 800, 200)
   GUISetState(@SW_SHOWNORMAL)
   GUISetBkColor(0xD8E4DF)
   $list2=GUICtrlCreateList("", 20, 20, 280, 140)

   $pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\Default.jpg',600, 10, 180, 180)
   $grave_description=GUICtrlCreateInput("", 400, 30, 180, 140,$ES_MULTILINE)
   $typemonster3=GUICtrlCreateInput("", 310, 50, 80, 20)
   $typeelement3=GUICtrlCreateInput("", 310, 130, 80, 20)
   GUICtrlSetState($typemonster3,128)
   GUICtrlSetState($typeelement3,128)

   ReadHand("graveyard")
   $string=""
   For $i=1 to UBound($array)-1
	  If $array3[$i]="Unit" Then
	  $count=0
	  For $j=1 to UBound($array)-1
		 If $array[$i]=$array[$j] Then $count+=1
	  Next
	  GUICtrlSetData($list2, $array[$i]&" *"&$count)
	  EndIf
   Next
   $Button=GUICtrlCreateButton("Select", 120, 170, 100)
   _GUICtrlButton_SetImageList($1, $buttonList, 4,-2)
   While 1
	  $msg =GUIGetMsg(1)
	  Select
	  Case $msg[0]=$Button
			$o=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			GUIDelete()
			CardEffect($o)
			ExitLoop
	  Case $msg[0]=$list2
			$b=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			$a=_ArraySearch ($array, $b)
			GUICtrlSetData($grave_description, $array5[$a]&" mana."&@CRLF&$array2[$a])
			GUICtrlSetData($typemonster3, $array3[$a])
			GUICtrlSetData($typeelement3, $array4[$a])
			GUICtrlDelete($pic3)
			$b=StringReplace($b," ","_")
			$pic3=GUICtrlCreatePic(@ScriptDir & '\Graphics\Cards\'&$b&'.jpg',600, 10, 180, 180)
		 Case $msg[0]=$GUI_EVENT_CLOSE
			GUIDelete()
			ExitLoop
	  EndSelect
   WEnd
EndFunc

Func Sonic_Boom()
   GUICtrlSetData($gamelog, @CRLF&"[Sonic Boom] Wait, what was that?",1)
   $stats[3]-=600
EndFunc

Func Team_Spirit()
   GUICtrlSetData($gamelog, @CRLF&"[Team Spirit] Yay!",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 3,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Unit" Then $count+=1
   Next
   $stats[1]+=200*$count
EndFunc

Func Undercover_Operative()
   GUICtrlSetData($gamelog, @CRLF&"[Undercover Operative] Timely sabotage.",1)
   $stats[3]-=300
   $oppstats[1]=3
   $oppstats[2]=1
   GUICtrlSetData($enstatus,"Enemy Status:Slowed")
EndFunc

Func Veteran_Warrior()
   GUICtrlSetData($gamelog, @CRLF&"[Veteran Warrior] Practice makes perfect.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "graveyard", 3,""),",")
   $stats[3]-=500
   If $array[UBound($array)-2] = "Unit" Then $stats[3]-=500
EndFunc

Func Yin()
   GUICtrlSetData($gamelog, @CRLF&"[Yin] A sudden clarity.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Dark" Then $count+=1
   Next
   Draw($count)
EndFunc

Func Zealous_Knight()
   GUICtrlSetData($gamelog, @CRLF&"[Zealous Knight] We're not sure which side he's fighting for.",1)
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   ReadHand("hand")
   ReadHand2()
   For $i=1 to UBound($array)-1
	  If $array[$i]<>"" And $array3[$i]<>"Unit" Then
	  $string=$string&","&$array[$i]
	  $string2=$string2&"|"&$array2[$i]
	  $string3=$string3&","&$array3[$i]
	  $string4=$string4&","&$array4[$i]
	  $string5=$string5&","&$array5[$i]
	  $count=0
	  For $j=1 to UBound($array)-1
		 If $array[$i]=$array[$j] Then $count+=1
	  Next
	  GUICtrlSetData($list, $array[$i]&" *"&$count)
	  Else
	  WriteHand("graveyard",$i)
	  EndIf
   Next
   WriteHand2()
   $stats[3]-=1200
EndFunc

Func Astral_Plane()
   ReadHand("hand")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array3[$i]="Spell" Then $count+=1
   Next
   If $count>0 Then
   GUICtrlSetData($gamelog, @CRLF&"[Astral Plane] A new dimension.",1)
   GUICreate("Select a card:", 400, 140)
   GUISetBkColor(0xD8E4DF)
   GUISetState(@SW_SHOWNORMAL)
   $list2=GUICtrlCreateList("", 20, 20, 320, 80)
   For $i=1 to UBound($array)-1
	  If $array3[$i]="Spell" Then
	  $count=0
	  For $j=1 to UBound($array)-1
		 If $array[$i]=$array[$j] Then $count+=1
	  Next
	  GUICtrlSetData($list2, $array[$i]&" *"&$count)
	  EndIf
   Next
   $Button=GUICtrlCreateButton("Discard", 150, 100, 100)
   _GUICtrlButton_SetImageList($Button, $buttonList, 4,-2)
   While 1
	  $msg =GUIGetMsg(1)
	  Select
		 Case $msg[0]=$Button ;Play Card
			If Not GUICtrlRead($list2)="" Then
			   $o=StringLeft(GUICtrlRead($list2),StringInStr(GUICtrlRead($list2)," *")-1)
			   GUIDelete()
			   ExitLoop
			EndIf
	  EndSelect
   WEnd
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   ReadHand2()
   For $i=1 to UBound($array)-1
	  If $array[$i]<>$o Then
		 If $array[$i]<>""  Then
		 $string=$string&","&$array[$i]
		 $string2=$string2&"|"&$array2[$i]
		 $string3=$string3&","&$array3[$i]
		 $string4=$string4&","&$array4[$i]
		 $string5=$string5&","&$array5[$i]
		 $count=0
		 For $j=1 to UBound($array)-1
			If $array[$i]=$array[$j] Then $count+=1
		 Next
		 GUICtrlSetData($list, $array[$i]&" *"&$count)
		 EndIf
	  Else
		 WriteHand("graveyard",$i)
		 $o=""
		 $array[$i]=""
	  EndIf
   Next
   WriteHand2()
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Astral_Plane")
Else
   GUICtrlSetData($gamelog, @CRLF&"No spell cards to tribute!",1)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1, IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 1, "")&",Astral Plane")
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 2, IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 2, "")&"|Starting mana per turn is increased by 1. Must discard one spell card to activate.")
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 3, IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 3, "")&",Spell")
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4, IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4, "")&",Air")
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini", "hand", 5, IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 5, "")&",3")
   GUICtrlDelete($list)
   $list=GUICtrlCreateList("", 20, 30, 320, 90)
   HandCreate($list, "hand")
   $stats[2]+=3
   EndIf
EndFunc

Func Benevolence()
   GUICtrlSetData($gamelog, @CRLF&"[Benevolence] Help from a stranger.",1)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
   $count=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Luck" Then $count+=1
   Next
   Draw(3)
   $array=StringSplit(IniRead(@ScriptDir&'\Settings\'&"Save.ini", "hand", 4,""),",")
   $count2=0
   For $i=1 to UBound($array)-1
	  If $array[$i]="Luck" Then $count2+=1
   Next
   $stats[3]-=($count2-$count)*300
EndFunc

Func Clockwork_Town()
   GUICtrlSetData($gamelog, @CRLF&"[Clockwork Town] Efficiency is the least of it.",1)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Clockwork_Town")
EndFunc

Func Doom()
   GUICtrlSetData($gamelog, @CRLF&"[Doom] Bad news for someone.",1)
   IniWrite(@ScriptDir&'\Settings\'&"Save.ini","field",1,"Cursed_Realm")
   $stats[3]-=Random(6,15,1)*100
EndFunc

Func Elven_Archers()
   GUICtrlSetData($gamelog, @CRLF&"[Elven Archers] For those precision strikes.",1)
   $stats[3]-=1000
EndFunc
