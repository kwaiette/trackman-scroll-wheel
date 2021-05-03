;;
;; trackman-scroll-wheel.ahk
;; Author: Wayne Jensen
;; Version: 0.1
;;
;; Added horizontal scroll
;;
;; modification of the following work:
;; Emulate_Scrolling_Middle_Button.ahk
;; Author: Erik Elmore <erik@ironsavior.net>
;; Version: 1.1 (Aug 16, 2005)
;;
;; Enables you to use any key with cursor movement
;; to emulate a scrolling middle button.  While
;; the TriggerKey is held down, you may move the
;; mouse cursor up and down to send scroll wheel
;; events.  If the cursor does not move by the
;; time the TriggerKey is released, then a middle
;; button click is generated.  I wrote this for my
;; 4-button Logitech Marble Mouse (trackball),
;; which has no middle button or scroll wheel.
;;

;; Configuration

;#NoTrayIcon

;; Higher numbers mean less sensitivity
esmb_Threshold = 5

;; This key/Button activates scrolling
esmb_TriggerKey = XButton1

;; End of configuration

#Persistent
CoordMode, Mouse, Screen
Hotkey, %esmb_TriggerKey%, esmb_TriggerKeyDown
HotKey, %esmb_TriggerKey% Up, esmb_TriggerKeyUp
esmb_KeyDown = n
SetTimer, esmb_CheckForScrollEventAndExecute, 10
return

esmb_TriggerKeyDown:
  esmb_Moved = n
  esmb_HMoved = n
  esmb_FirstIteration = y
  esmb_KeyDown = y
  MouseGetPos, esmb_OrigX, esmb_OrigY, esmb_HoverWnd, esmb_HoverCtl

  ;;ControlFocus, ahk_class %esmb_HoverCtl%, ahk_id %esmb_HoverWnd%
  esmb_AccumulatedDistance = 0
  esmb_HAccumulatedDistance = 0
return

esmb_TriggerKeyUp:
  esmb_KeyDown = n
  ;; Send a middle-click if we did not scroll
  if esmb_Moved = n
    MouseClick, Middle
return

esmb_CheckForScrollEventAndExecute:
  if esmb_KeyDown = n
    return

  MouseGetPos, esmb_NewX, esmb_NewY, id, fcontrol, 1

  esmb_Distance := esmb_NewY - esmb_OrigY
  if esmb_Distance != 0
    esmb_Moved = y

  esmb_HDistance := esmb_NewX - esmb_OrigX
  if esmb_HDistance != 0
    esmb_HMoved = y

  if esmb_Moved = y and esmb_HMoved = y
    return

  esmb_AccumulatedDistance := (esmb_AccumulatedDistance + esmb_Distance)
  esmb_HAccumulatedDistance := (esmb_HAccumulatedDistance + esmb_HDistance)
  esmb_Ticks := (esmb_AccumulatedDistance // esmb_Threshold) ; floor divide
  esmb_HTicks := (esmb_HAccumulatedDistance // esmb_Threshold) ; floor divide
  esmb_AccumulatedDistance := (esmb_AccumulatedDistance - (esmb_Ticks * esmb_Threshold))
  esmb_HAccumulatedDistance := (esmb_HAccumulatedDistance - (esmb_HTicks * esmb_Threshold))
  esmb_WheelDirection := "WheelUp"
  if (esmb_Ticks < 0) {
    esmb_WheelDirection := "WheelDown"
    esmb_Ticks := (-1 * esmb_Ticks)
  }

  esmb_HWheelDirection := "WheelLeft"
  if (esmb_HTicks < 0) {
    esmb_HWheelDirection := "WheelRight"
    esmb_HTicks := (-1 * esmb_HTicks)
  }

  ;; Do not send clicks on the first iteration
  if (esmb_FirstIteration = y) {
    esmb_FirstIteration = n
  } else {
    Loop % esmb_Ticks {
      MouseClick, %esmb_WheelDirection%
    }
    Loop % esmb_HTicks {
      MouseClick, %esmb_HWheelDirection%
    }
    ;MouseMove,esmb_OrigX,esmb_OrigY,0
    DllCall("SetCursorPos", "int", esmb_OrigX, "int", esmb_OrigY)
    ;Tooltip, (%esmb_NewX% . ' ' . %esmb_NewY% . ' ' . %esmb_OrigX% . ' ' . %esmb_OrigY%), 10, 100, 1
  }

return
