; ---------------------------------------------------------------
; bCNC -> GRBL streaming test  (AIR MOVE ONLY - nothing cuts)
; Proxxon MF70 / grbl-Mega-5X 1.2i
; Z stays retracted at +5mm the whole time. Spindle stays OFF.
; Set work zero (X0 Y0) somewhere with >=30mm clear in +X/+Y first!
; ---------------------------------------------------------------
G21            ; units = mm
G90            ; absolute positioning
G17            ; XY arc plane
G94            ; feed = units/min

G0 Z5          ; retract to safe height (no cut)
G0 X0 Y0       ; go to work origin (in the air)

; ---- trace a 20 mm square (feed 200 mm/min) ----
G1 F200
G1 X20 Y0
G1 X20 Y20
G1 X0  Y20
G1 X0  Y0

; ---- trace a circle, radius 10, centered at (10,10) ----
G0 X0 Y10      ; move to a point on the circle (left edge)
G2 X0 Y10 I10 J0 F200   ; full clockwise circle around (10,10)

; ---- park ----
G0 X0 Y0
M2             ; program end
