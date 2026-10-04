; MIT License
;
; Copyright (c) 2026 SuperMilkers
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

#NoEnv
#SingleInstance Force
#Persistent

SendMode Event
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
SetMouseDelay, -1
SetKeyDelay, -1, 40
CoordMode, Mouse, Screen


; ============================================================
; SETTINGS
; ============================================================

running := true

cycleCount := 0
moveCount := 0
skillCastCount := 0
runSeconds := 0

nextCycleTime := 0
nextMoveTime := 0


; ------------------------------------------------------------
; SKILL CYCLE TIMING
; ------------------------------------------------------------

cycleMinDelay := 15000
cycleMaxDelay := 45000

; Delay between individual skill activations
delayBetweenSkills := 150


; ------------------------------------------------------------
; RANDOM REPEAT SETTINGS
;
; Remaining percentage becomes single-cast chance.
;
; Defaults:
; 70% single
; 20% double
; 10% triple
; ------------------------------------------------------------

doubleCastChance := 20
tripleCastChance := 10


; ------------------------------------------------------------
; SIX SKILL SLOTS
; ------------------------------------------------------------

skill1Key := "1"
skill2Key := "2"
skill3Key := "3"
skill4Key := "4"
skill5Key := "5"
skill6Key := "RButton"


; ------------------------------------------------------------
; CHANNEL SETTINGS
;
; 0 = normal
; 1 = channeled
; ------------------------------------------------------------

skill1Channel := 0
skill2Channel := 0
skill3Channel := 0
skill4Channel := 0
skill5Channel := 0
skill6Channel := 0


; ------------------------------------------------------------
; CHANNEL HOLD TIMES
; ------------------------------------------------------------

skill1Hold := 1.0
skill2Hold := 1.0
skill3Hold := 1.0
skill4Hold := 1.0
skill5Hold := 1.0
skill6Hold := 1.0


; ------------------------------------------------------------
; MOVEMENT
; ------------------------------------------------------------

moveMinDelay := 20000
moveMaxDelay := 40000

movementMinRadius := 80
movementMaxRadius := 160


; ============================================================
; OVERLAY
; ============================================================

Gui, 1:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, 1:Margin, 10, 8
Gui, 1:Color, 111111

Gui, 1:Font, s13 cFF69B4 Bold, Segoe UI
Gui, 1:Add, Text, w300 Center, Moophisto AFK Farmer

Gui, 1:Font, s11 c00FF00 Bold, Segoe UI
Gui, 1:Add, Text, vStatusText w300 Center, RUNNING

Gui, 1:Font, s10 cFFFFFF Norm, Segoe UI

Gui, 1:Add, Text, vCycleText w300, Skill Cycles: 0
Gui, 1:Add, Text, vCastText w300, Skill Casts: 0
Gui, 1:Add, Text, vMoveText w300, Moves: 0
Gui, 1:Add, Text, vTimerText w300, Runtime: 00:00:00
Gui, 1:Add, Text, vNextCycleText w300, Next Skill Cycle: --
Gui, 1:Add, Text, vNextMoveText w300, Next Move: --
Gui, 1:Add, Text, vSkillsText w300, Skills: 1 | 2 | 3 | 4 | 5 | RButton

Gui, 1:Font, s9 cAAAAAA Norm, Segoe UI
Gui, 1:Add, Text, w300, F8 - Pause / Resume
Gui, 1:Add, Text, w300, F10 - Settings
Gui, 1:Add, Text, w300, F12 - Exit

Gui, 1:Show, x10 y10 NoActivate, Moophisto AFK Farmer

WinSet, Transparent, 220, Moophisto AFK Farmer


; ============================================================
; START
; ============================================================

SetTimer, UpdateRuntime, 1000

ScheduleNextCycle()
ScheduleNextMove()

return


; ============================================================
; F8 - PAUSE / RESUME
; ============================================================

F8::

running := !running

if (running)
{
    GuiControl, 1:, StatusText, RUNNING

    Gui, 1:Font, s11 c00FF00 Bold, Segoe UI
    GuiControl, 1:Font, StatusText

    ScheduleNextCycle()
    ScheduleNextMove()
}
else
{
    GuiControl, 1:, StatusText, PAUSED

    Gui, 1:Font, s11 cFF5555 Bold, Segoe UI
    GuiControl, 1:Font, StatusText

    SetTimer, DoSkillCycle, Off
    SetTimer, DoMove, Off

    nextCycleTime := 0
    nextMoveTime := 0

    GuiControl, 1:, NextCycleText, Next Skill Cycle: PAUSED
    GuiControl, 1:, NextMoveText, Next Move: PAUSED
}

return


; ============================================================
; F10 - SETTINGS
; ============================================================

F10::

settingsWasRunning := running
running := false

SetTimer, DoSkillCycle, Off
SetTimer, DoMove, Off

nextCycleTime := 0
nextMoveTime := 0

GuiControl, 1:, StatusText, SETTINGS

Gui, 1:Font, s11 cFFFF00 Bold, Segoe UI
GuiControl, 1:Font, StatusText


; ------------------------------------------------------------
; SETTINGS WINDOW
; ------------------------------------------------------------

Gui, 2:Destroy
Gui, 2:+AlwaysOnTop
Gui, 2:Margin, 12, 10
Gui, 2:Color, 181818

Gui, 2:Font, s12 cFF69B4 Bold, Segoe UI
Gui, 2:Add, Text, x15 y12 w560 Center, Moophisto AFK Farmer - Settings


; ============================================================
; SKILL SETTINGS HEADERS
; ============================================================

Gui, 2:Font, s9 cFFFFFF Norm, Segoe UI

Gui, 2:Add, Text, x15 y50 w50, Slot
Gui, 2:Add, Text, x75 y50 w90, Key
Gui, 2:Add, Text, x185 y50 w90, Channel
Gui, 2:Add, Text, x295 y50 w120, Hold Seconds


; ------------------------------------------------------------
; SKILL 1
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y80 w50, Skill 1
Gui, 2:Add, Edit, x75 y76 w90 vSetSkill1Key, %skill1Key%
Gui, 2:Add, Checkbox, x195 y78 vSetSkill1Channel Checked%skill1Channel%, Channel
Gui, 2:Add, Edit, x315 y76 w80 vSetSkill1Hold, %skill1Hold%


; ------------------------------------------------------------
; SKILL 2
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y115 w50, Skill 2
Gui, 2:Add, Edit, x75 y111 w90 vSetSkill2Key, %skill2Key%
Gui, 2:Add, Checkbox, x195 y113 vSetSkill2Channel Checked%skill2Channel%, Channel
Gui, 2:Add, Edit, x315 y111 w80 vSetSkill2Hold, %skill2Hold%


; ------------------------------------------------------------
; SKILL 3
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y150 w50, Skill 3
Gui, 2:Add, Edit, x75 y146 w90 vSetSkill3Key, %skill3Key%
Gui, 2:Add, Checkbox, x195 y148 vSetSkill3Channel Checked%skill3Channel%, Channel
Gui, 2:Add, Edit, x315 y146 w80 vSetSkill3Hold, %skill3Hold%


; ------------------------------------------------------------
; SKILL 4
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y185 w50, Skill 4
Gui, 2:Add, Edit, x75 y181 w90 vSetSkill4Key, %skill4Key%
Gui, 2:Add, Checkbox, x195 y183 vSetSkill4Channel Checked%skill4Channel%, Channel
Gui, 2:Add, Edit, x315 y181 w80 vSetSkill4Hold, %skill4Hold%


; ------------------------------------------------------------
; SKILL 5
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y220 w50, Skill 5
Gui, 2:Add, Edit, x75 y216 w90 vSetSkill5Key, %skill5Key%
Gui, 2:Add, Checkbox, x195 y218 vSetSkill5Channel Checked%skill5Channel%, Channel
Gui, 2:Add, Edit, x315 y216 w80 vSetSkill5Hold, %skill5Hold%


; ------------------------------------------------------------
; SKILL 6
; ------------------------------------------------------------

Gui, 2:Add, Text, x15 y255 w50, Skill 6
Gui, 2:Add, Edit, x75 y251 w90 vSetSkill6Key, %skill6Key%
Gui, 2:Add, Checkbox, x195 y253 vSetSkill6Channel Checked%skill6Channel%, Channel
Gui, 2:Add, Edit, x315 y251 w80 vSetSkill6Hold, %skill6Hold%


; ============================================================
; TIMING SETTINGS
; ============================================================

Gui, 2:Font, s10 cFF69B4 Bold, Segoe UI
Gui, 2:Add, Text, x15 y300 w200, Skill Cycle Timing

Gui, 2:Font, s9 cFFFFFF Norm, Segoe UI

cycleMinSeconds := cycleMinDelay / 1000
cycleMaxSeconds := cycleMaxDelay / 1000

Gui, 2:Add, Text, x15 y330 w160, Minimum Cycle Seconds
Gui, 2:Add, Edit, x185 y326 w80 vSetCycleMin, %cycleMinSeconds%

Gui, 2:Add, Text, x295 y330 w160, Maximum Cycle Seconds
Gui, 2:Add, Edit, x465 y326 w80 vSetCycleMax, %cycleMaxSeconds%

Gui, 2:Add, Text, x15 y365 w160, Between Skills (ms)
Gui, 2:Add, Edit, x185 y361 w80 vSetSkillDelay, %delayBetweenSkills%


; ============================================================
; REPEAT SETTINGS
; ============================================================

Gui, 2:Font, s10 cFF69B4 Bold, Segoe UI
Gui, 2:Add, Text, x15 y410 w200, Random Repeat Chances

Gui, 2:Font, s9 cFFFFFF Norm, Segoe UI

Gui, 2:Add, Text, x15 y440 w160, Double Cast Chance `%
Gui, 2:Add, Edit, x185 y436 w80 vSetDoubleChance, %doubleCastChance%

Gui, 2:Add, Text, x295 y440 w160, Triple Cast Chance `%
Gui, 2:Add, Edit, x465 y436 w80 vSetTripleChance, %tripleCastChance%


; ============================================================
; MOVEMENT SETTINGS
; ============================================================

Gui, 2:Font, s10 cFF69B4 Bold, Segoe UI
Gui, 2:Add, Text, x15 y485 w200, Movement

Gui, 2:Font, s9 cFFFFFF Norm, Segoe UI

moveMinSeconds := moveMinDelay / 1000
moveMaxSeconds := moveMaxDelay / 1000

Gui, 2:Add, Text, x15 y515 w160, Minimum Move Seconds
Gui, 2:Add, Edit, x185 y511 w80 vSetMoveMin, %moveMinSeconds%

Gui, 2:Add, Text, x295 y515 w160, Maximum Move Seconds
Gui, 2:Add, Edit, x465 y511 w80 vSetMoveMax, %moveMaxSeconds%

Gui, 2:Add, Text, x15 y550 w160, Minimum Move Radius
Gui, 2:Add, Edit, x185 y546 w80 vSetRadiusMin, %movementMinRadius%

Gui, 2:Add, Text, x295 y550 w160, Maximum Move Radius
Gui, 2:Add, Edit, x465 y546 w80 vSetRadiusMax, %movementMaxRadius%


; ============================================================
; INFO
; ============================================================

Gui, 2:Font, s8 cAAAAAA Norm, Segoe UI

Gui, 2:Add, Text, x15 y590 w540, Skills are shuffled every cycle. Individual skills may randomly cast once, twice, or three times.
Gui, 2:Add, Text, x15 y608 w540, Single-cast chance is whatever remains after Double + Triple chance.
Gui, 2:Add, Text, x15 y626 w540, Example: Double 20 + Triple 10 = 70`% single / 20`% double / 10`% triple.
Gui, 2:Add, Text, x15 y644 w540, Keys can be values such as 1, 2, 3, Q, E, RButton, MButton, or XButton1.


; ============================================================
; BUTTONS
; ============================================================

Gui, 2:Font, s9 cFFFFFF Norm, Segoe UI

Gui, 2:Add, Button, x180 y680 w100 h30 gSaveSettings, Save
Gui, 2:Add, Button, x295 y680 w100 h30 gCancelSettings, Cancel

Gui, 2:Show, w580 h730, Moophisto AFK Farmer Settings

return


; ============================================================
; SAVE SETTINGS
; ============================================================

SaveSettings:

Gui, 2:Submit


; ------------------------------------------------------------
; SKILL KEYS
; ------------------------------------------------------------

if (SetSkill1Key != "")
    skill1Key := SetSkill1Key

if (SetSkill2Key != "")
    skill2Key := SetSkill2Key

if (SetSkill3Key != "")
    skill3Key := SetSkill3Key

if (SetSkill4Key != "")
    skill4Key := SetSkill4Key

if (SetSkill5Key != "")
    skill5Key := SetSkill5Key

if (SetSkill6Key != "")
    skill6Key := SetSkill6Key


; ------------------------------------------------------------
; CHANNEL TOGGLES
; ------------------------------------------------------------

skill1Channel := SetSkill1Channel
skill2Channel := SetSkill2Channel
skill3Channel := SetSkill3Channel
skill4Channel := SetSkill4Channel
skill5Channel := SetSkill5Channel
skill6Channel := SetSkill6Channel


; ------------------------------------------------------------
; CHANNEL HOLD TIMES
; ------------------------------------------------------------

skill1Hold := ValidateHoldTime(SetSkill1Hold)
skill2Hold := ValidateHoldTime(SetSkill2Hold)
skill3Hold := ValidateHoldTime(SetSkill3Hold)
skill4Hold := ValidateHoldTime(SetSkill4Hold)
skill5Hold := ValidateHoldTime(SetSkill5Hold)
skill6Hold := ValidateHoldTime(SetSkill6Hold)


; ------------------------------------------------------------
; CYCLE TIMING
; ------------------------------------------------------------

SetCycleMin := ValidateSeconds(SetCycleMin, 1, 300, 15)
SetCycleMax := ValidateSeconds(SetCycleMax, 1, 300, 45)

if (SetCycleMax < SetCycleMin)
    SetCycleMax := SetCycleMin

cycleMinDelay := Round(SetCycleMin * 1000)
cycleMaxDelay := Round(SetCycleMax * 1000)


; ------------------------------------------------------------
; BETWEEN SKILLS
; ------------------------------------------------------------

SetSkillDelay := ValidateInteger(SetSkillDelay, 0, 5000, 150)

delayBetweenSkills := SetSkillDelay


; ------------------------------------------------------------
; RANDOM REPEAT CHANCES
; ------------------------------------------------------------

SetDoubleChance := ValidateInteger(SetDoubleChance, 0, 100, 20)
SetTripleChance := ValidateInteger(SetTripleChance, 0, 100, 10)

if ((SetDoubleChance + SetTripleChance) > 100)
{
    SetTripleChance := 100 - SetDoubleChance

    if (SetTripleChance < 0)
        SetTripleChance := 0
}

doubleCastChance := SetDoubleChance
tripleCastChance := SetTripleChance


; ------------------------------------------------------------
; MOVEMENT TIMING
; ------------------------------------------------------------

SetMoveMin := ValidateSeconds(SetMoveMin, 1, 600, 20)
SetMoveMax := ValidateSeconds(SetMoveMax, 1, 600, 40)

if (SetMoveMax < SetMoveMin)
    SetMoveMax := SetMoveMin

moveMinDelay := Round(SetMoveMin * 1000)
moveMaxDelay := Round(SetMoveMax * 1000)


; ------------------------------------------------------------
; MOVEMENT RADIUS
; ------------------------------------------------------------

SetRadiusMin := ValidateInteger(SetRadiusMin, 10, 1000, 80)
SetRadiusMax := ValidateInteger(SetRadiusMax, 10, 1000, 160)

if (SetRadiusMax < SetRadiusMin)
    SetRadiusMax := SetRadiusMin

movementMinRadius := SetRadiusMin
movementMaxRadius := SetRadiusMax


Gui, 2:Destroy

UpdateSkillDisplay()

RestoreAfterSettings()

return


; ============================================================
; CANCEL SETTINGS
; ============================================================

CancelSettings:

Gui, 2:Destroy

RestoreAfterSettings()

return


2GuiClose:

Gui, 2:Destroy

RestoreAfterSettings()

return


; ============================================================
; RESTORE AFTER SETTINGS
; ============================================================

RestoreAfterSettings()
{
    global running
    global settingsWasRunning

    running := settingsWasRunning

    if (running)
    {
        GuiControl, 1:, StatusText, RUNNING

        Gui, 1:Font, s11 c00FF00 Bold, Segoe UI
        GuiControl, 1:Font, StatusText

        ScheduleNextCycle()
        ScheduleNextMove()
    }
    else
    {
        GuiControl, 1:, StatusText, PAUSED

        Gui, 1:Font, s11 cFF5555 Bold, Segoe UI
        GuiControl, 1:Font, StatusText

        GuiControl, 1:, NextCycleText, Next Skill Cycle: PAUSED
        GuiControl, 1:, NextMoveText, Next Move: PAUSED
    }
}


; ============================================================
; F12 - EXIT
; ============================================================

F12::
ExitApp
return


; ============================================================
; RANDOMIZED SKILL CYCLE
; ============================================================

DoSkillCycle:

if (!running)
    return


; Create list of six skill slots
skills := [1, 2, 3, 4, 5, 6]


; Shuffle order
ShuffleArray(skills)


; Execute each skill in randomized order
for index, slot in skills
{
    if (!running)
        break

    repeatCount := GetRandomRepeatCount()

    Loop, %repeatCount%
    {
        if (!running)
            break

        CastSkillSlot(slot)

        skillCastCount++

        GuiControl, 1:, CastText, Skill Casts: %skillCastCount%

        if (A_Index < repeatCount)
            Sleep, %delayBetweenSkills%
    }

    if (!running)
        break

    Sleep, %delayBetweenSkills%
}


if (running)
{
    cycleCount++

    GuiControl, 1:, CycleText, Skill Cycles: %cycleCount%

    ScheduleNextCycle()
}

return


; ============================================================
; CAST SKILL SLOT
; ============================================================

CastSkillSlot(slot)
{
    global skill1Key
    global skill2Key
    global skill3Key
    global skill4Key
    global skill5Key
    global skill6Key

    global skill1Channel
    global skill2Channel
    global skill3Channel
    global skill4Channel
    global skill5Channel
    global skill6Channel

    global skill1Hold
    global skill2Hold
    global skill3Hold
    global skill4Hold
    global skill5Hold
    global skill6Hold


    if (slot = 1)
        UseSkill(skill1Key, skill1Channel, skill1Hold)

    else if (slot = 2)
        UseSkill(skill2Key, skill2Channel, skill2Hold)

    else if (slot = 3)
        UseSkill(skill3Key, skill3Channel, skill3Hold)

    else if (slot = 4)
        UseSkill(skill4Key, skill4Channel, skill4Hold)

    else if (slot = 5)
        UseSkill(skill5Key, skill5Channel, skill5Hold)

    else if (slot = 6)
        UseSkill(skill6Key, skill6Channel, skill6Hold)
}


; ============================================================
; RANDOM SINGLE / DOUBLE / TRIPLE
; ============================================================

GetRandomRepeatCount()
{
    global doubleCastChance
    global tripleCastChance

    Random, roll, 1, 100

    if (roll <= tripleCastChance)
        return 3

    if (roll <= (tripleCastChance + doubleCastChance))
        return 2

    return 1
}


; ============================================================
; SHUFFLE ARRAY
; ============================================================

ShuffleArray(ByRef array)
{
    count := array.MaxIndex()

    Loop, % count - 1
    {
        i := count - A_Index + 1

        Random, j, 1, %i%

        temp := array[i]
        array[i] := array[j]
        array[j] := temp
    }
}


; ============================================================
; MOVEMENT
; ============================================================

DoMove:

if (!running)
    return


MouseGetPos, oldMouseX, oldMouseY

centerX := Floor(A_ScreenWidth / 2)
centerY := Floor(A_ScreenHeight / 2)

Random, angleRaw, 0, 6283
angle := angleRaw / 1000.0

Random, distance, %movementMinRadius%, %movementMaxRadius%

targetX := centerX + Round(Cos(angle) * distance)
targetY := centerY + Round(Sin(angle) * distance)


if (targetX < 10)
    targetX := 10

if (targetY < 10)
    targetY := 10

if (targetX > A_ScreenWidth - 10)
    targetX := A_ScreenWidth - 10

if (targetY > A_ScreenHeight - 10)
    targetY := A_ScreenHeight - 10


MouseMove, %targetX%, %targetY%, 0

SendEvent, {LButton down}
Sleep, 50
SendEvent, {LButton up}

Sleep, 75

MouseMove, %oldMouseX%, %oldMouseY%, 0

moveCount++

GuiControl, 1:, MoveText, Moves: %moveCount%

ScheduleNextMove()

return


; ============================================================
; USE SKILL
; ============================================================

UseSkill(key, channel, holdSeconds)
{
    global running

    if (!running)
        return


    if (channel)
    {
        holdMilliseconds := Round(holdSeconds * 1000)

        SendKeyDown(key)

        elapsed := 0

        while (elapsed < holdMilliseconds)
        {
            if (!running)
                break

            Sleep, 50
            elapsed += 50
        }

        SendKeyUp(key)
    }
    else
    {
        SendKeyDown(key)

        Sleep, 40

        SendKeyUp(key)
    }
}


; ============================================================
; KEY DOWN
; ============================================================

SendKeyDown(key)
{
    if (key = "RButton")
        SendEvent, {RButton down}

    else if (key = "LButton")
        SendEvent, {LButton down}

    else if (key = "MButton")
        SendEvent, {MButton down}

    else if (key = "XButton1")
        SendEvent, {XButton1 down}

    else if (key = "XButton2")
        SendEvent, {XButton2 down}

    else
        SendEvent, {%key% down}
}


; ============================================================
; KEY UP
; ============================================================

SendKeyUp(key)
{
    if (key = "RButton")
        SendEvent, {RButton up}

    else if (key = "LButton")
        SendEvent, {LButton up}

    else if (key = "MButton")
        SendEvent, {MButton up}

    else if (key = "XButton1")
        SendEvent, {XButton1 up}

    else if (key = "XButton2")
        SendEvent, {XButton2 up}

    else
        SendEvent, {%key% up}
}


; ============================================================
; VALIDATE HOLD TIME
; ============================================================

ValidateHoldTime(value)
{
    if value is not number
        return 1.0

    value += 0

    if (value < 0.1)
        value := 0.1

    if (value > 30)
        value := 30

    return value
}


; ============================================================
; VALIDATE SECONDS
; ============================================================

ValidateSeconds(value, minValue, maxValue, defaultValue)
{
    if value is not number
        return defaultValue

    value += 0

    if (value < minValue)
        value := minValue

    if (value > maxValue)
        value := maxValue

    return value
}


; ============================================================
; VALIDATE INTEGER
; ============================================================

ValidateInteger(value, minValue, maxValue, defaultValue)
{
    if value is not integer
        return defaultValue

    value += 0

    if (value < minValue)
        value := minValue

    if (value > maxValue)
        value := maxValue

    return value
}


; ============================================================
; UPDATE SKILL DISPLAY
; ============================================================

UpdateSkillDisplay()
{
    global skill1Key
    global skill2Key
    global skill3Key
    global skill4Key
    global skill5Key
    global skill6Key

    text := "Skills: "
        . skill1Key . " | "
        . skill2Key . " | "
        . skill3Key . " | "
        . skill4Key . " | "
        . skill5Key . " | "
        . skill6Key

    GuiControl, 1:, SkillsText, %text%
}


; ============================================================
; UPDATE RUNTIME / COUNTDOWNS
; ============================================================

UpdateRuntime:

if (running)
    runSeconds++

hours := Floor(runSeconds / 3600)
minutes := Floor(Mod(runSeconds, 3600) / 60)
seconds := Mod(runSeconds, 60)

runtime := Format("{:02}:{:02}:{:02}", hours, minutes, seconds)

GuiControl, 1:, TimerText, Runtime: %runtime%


if (running && nextCycleTime > 0)
{
    remainingCycle := Ceil((nextCycleTime - A_TickCount) / 1000)

    if (remainingCycle < 0)
        remainingCycle := 0

    GuiControl, 1:, NextCycleText, Next Skill Cycle: %remainingCycle% sec
}


if (running && nextMoveTime > 0)
{
    remainingMove := Ceil((nextMoveTime - A_TickCount) / 1000)

    if (remainingMove < 0)
        remainingMove := 0

    GuiControl, 1:, NextMoveText, Next Move: %remainingMove% sec
}

return


; ============================================================
; SCHEDULE NEXT SKILL CYCLE
; ============================================================

ScheduleNextCycle()
{
    global running
    global cycleMinDelay
    global cycleMaxDelay
    global nextCycleTime

    if (!running)
        return

    Random, delay, %cycleMinDelay%, %cycleMaxDelay%

    nextCycleTime := A_TickCount + delay

    SetTimer, DoSkillCycle, Off
    SetTimer, DoSkillCycle, % -delay
}


; ============================================================
; SCHEDULE NEXT MOVEMENT
; ============================================================

ScheduleNextMove()
{
    global running
    global moveMinDelay
    global moveMaxDelay
    global nextMoveTime

    if (!running)
        return

    Random, delay, %moveMinDelay%, %moveMaxDelay%

    nextMoveTime := A_TickCount + delay

    SetTimer, DoMove, Off
    SetTimer, DoMove, % -delay
}