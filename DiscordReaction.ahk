;   INIT
	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	Tray_Icon = %A_ScriptDir%\test_tube.ico
	IfExist, %Tray_Icon%
	Menu, Tray, Icon, %Tray_Icon%
	#SingleInstance, Force
	SetTitleMatchMode, 2
	SetKeyDelay , 100, 100
	AutoTrim, Off

; -----------------------------------------------------------------------------------------------

; Function Name: GeneralReaction
; Parameters: None.
; Purpose: Selects everything on the text box, copies it, then sends that to DoubleWord(). Serves as a general purpose reaction tool.
; Returns: Calls DoubleWord.
; -----------------------------------------------------------------------------------------------

	GeneralReaction(){
		ClipSave := Clipboard
		Clipboard =							   ; Empties Clipboard for ClipWait
		SendInput, {Backspace 1}             
		SendInput, ^a  						 ; Selects Everything 
		SendInput, ^c						              
		ClipWait							     ; Wait for the clipboard to contain text
		DoubleWord(Clipboard)      ; Should take care of the RegionalIndicators if a match
		Clipboard = %ClipSave%
	}

; -----------------------------------------------------------------------------------------------

; Function name: RegionalIndicator
; Parameters: Chars, State. (String, Boolean)
; Purpose: Types either Regional_Indicator_ or 2__ and then each letter of the Chars string.
; Returns: Nothing. Directly writes on the screen.
; -----------------------------------------------------------------------------------------------

	RegionalIndicator(Chars, State){
		Characters := StrSplit(Chars)
		SendInput, ^a 	                           ; Selects everything before
		if (State == "Two")
			SendInput, 2__
		Else
			SendInput, regional_indicator__
		Loop % Characters.MaxIndex(){
			SendInput, {Backspace}
			SendInput, % Characters[A_Index] 
			SendInput, {ShiftDown}{Enter}{ShiftUp} 	; Clicks on Enter without exiting the emote list
			Sleep, 850
		}
	}

; -----------------------------------------------------------------------------------------------

; Function Name: ReactionEmote()
; Parameters: Reaction (String)
; Purpose: Deletes everything and types the emote in Reaction without the : :
; Returns: Nothing. Directly writes on the screen.
; -----------------------------------------------------------------------------------------------

	ReactionEmote(Reaction){
		SendInput, ^a    			               ; Selects everything before
		SendInput, %Reaction%
		SendInput, {ShiftDown}{Enter}{ShiftUp}     ; Clicks on Enter without exiting the emote list
		Sleep, 850
	}

; -----------------------------------------------------------------------------------------------

; Function name: SortArray
; Parameters: Array, Order (string)
; Purpose: To sort arrays in either ascending (A), descending (D) or Reverse (R)
; Returns: Nothing. Directly changes the array
; -----------------------------------------------------------------------------------------------

	SortArray(Array, Order="A") {
		MaxIndex := ObjMaxIndex(Array)
		If (Order = "R") {
			count := 0
			Loop, % MaxIndex
				ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
			Return
		}
		Partitions := "|" ObjMinIndex(Array) "," MaxIndex
		Loop {
			comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
			spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
			if (Order = "A") {    
				Loop, % epos - spos {
					if (Array[pivot] > Array[A_Index+spos])
						ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
				}
			} else {
				Loop, % epos - spos {
					if (Array[pivot] < Array[A_Index+spos])
						ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
				}
			}
			Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
			if (pivot - spos) > 1    ;if more than one elements
				Partitions .= "|" spos "," pivot-1        ;the left partition
			if (epos - pivot) > 1    ;if more than one elements
				Partitions .= "|" pivot+1 "," epos        ;the right partition
		} Until !Partitions
	}

; -----------------------------------------------------------------------------------------------

; Function name: SingleRegionalIndicator
; Parameters: Char, State. (Character, Boolean)
; Purpose: Types either Regional_Indicator_, 2__ or 3__ and then a single letter of the character string
; Returns: Nothing. Directly writes on the screen.
; -----------------------------------------------------------------------------------------------

	SingleRegionalIndicator(Char, State){
		
		if (Char == " "){
			if (State == "One") 
				ReactionEmote("__")
			if (State == "Two")
				ReactionEmote("2__")
			if (State == "Three")
				ReactionEmote("3__")
		}
		else {
			SendInput, ^a 	                           ; Selects everything before

			if (State == "One")
				SendInput, regional_indicator_
			if (State == "Two")
				SendInput, 2_
			if (State == "Three")
				SendInput, 3_

			SendInput, % Char 
			SendInput, {Shift Down}{Enter}{Shift Up} 	; Clicks on Enter without exiting the emote list
			Sleep, 850
		}
	}


; Function to test if a string contains 2 repeating letters. 
	DoubleWord(Var){
		; ------------------------------------------------------------------------------------------
		; How this works: Use two arrays to enumerate the order in which the letters appear. The FirstLetter array has the order in which all letters appear, and SecondLetters has the order in which the repeated letters appear. Example String: "Elephant" FirstLetters: [1,2,3,4,5,6,7,8] SecondLetters: [3]. Then a comparisson of the arrays determines which printing method to use.
		; ------------------------------------------------------------------------------------------
		StringLower, LowerVar, Var                       ; Makes the string lower case
		Word := StrSplit(LowerVar,, "." "," ";" ":" "\") ; Ignores ,.;:\
		State := true
		Letters := []
		FirstLetters := [] 
		SecondLetters := []
		ThirdLetters := []
		Loop % Word.MaxIndex(){        
			RepeatCounter := 0	
			B_Index += 1	
			SelectedLetter := Word.RemoveAt(1)  		; Removes and returns the first element
			Letters.Push(SelectedLetter)       			; Inserts at the end of array
			FirstLetters.Push(A_Index)         
			For m in Word{
				if (SelectedLetter == Word[m]){ 
					RepeatCounter += 1
					if      (RepeatCounter == 1)
						SecondLetters.Push(A_Index + B_Index)
					else if (RepeatCounter == 2)
						ThirdLetters.Push(A_Index + B_Index)
				}
				if (RepeatCounter > 2){                ; If more than 2 repeated letter, break both loops.
					State := false
					Break 2
				}
			}		
		}
		if (State == false){
			SendInput {Backspace}
			Return
		}
		
		; Print Letters array in the order of FirstLetters and SecondLetters. 
		Else{ 
			For n in Letters {
				SecondLetters.push(Letters.MaxIndex()+1) ; Makes sure the array is filled with values so that the comparisons below don't break.
				ThirdLetters.push(Letters.MaxIndex()+2)
			}

			SortArray(SecondLetters)   					 ; Sorts the arrays in ascending order
			SortArray(ThirdLetters)
			
			FirstIndex := 1
			SecondIndex := 1
			ThirdIndex := 1
			For n in Letters{
				if (FirstLetters[A_Index] != SecondLetters[SecondIndex] && FirstLetter[A_Index] != ThirdLetters[ThirdIndex]){
					SingleRegionalIndicator(Letters[n], "One")
				}
				if (FirstLetters[A_Index] == SecondLetters[SecondIndex] && SecondLetters[SecondIndex] != ThirdLetters[ThirdIndex]){ 
					SecondIndex += 1
					SingleRegionalIndicator(Letters[n], "Two")
				}
				if (FirstLetters[A_Index] == ThirdLetters[ThirdIndex]){
					SecondIndex += 1
					ThirdIndex += 1
					SingleRegionalIndicator(Letters[n], "Three")
				}
			}
			SendInput, {Enter}
		}
	}


; -----------------------------------------------------------------------------------------------
;  Main procedure
; -----------------------------------------------------------------------------------------------
#If WinActive("- Discord")

::!!r::		;Type !!r in a discord emote box to type out the phrase in reactions
	GeneralReaction()
	Return