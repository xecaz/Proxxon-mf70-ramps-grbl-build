 A. Make the text (Draft workbench)

  1. File → New (Ctrl+N).
  2. Top workbench dropdown → Draft.
  3. Menu Drafting → ShapeString (or the T-shaped ShapeString toolbar icon). A task panel opens on the left:
    - String: XecaZ.com
    - Height: 10 mm (letter height — keep ≤ ~12 mm so it fits the MF70's short Y axis)
    - Font file: browse to /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
    - Position: set X 0, Y 0, Z 0 in the coordinate fields (or click near the origin).
  4. Click OK. You'll see the letters as outlines lying flat on the XY plane. This is your engraving geometry.

  B. Create the CAM Job

  5. Workbench dropdown → CAM.
  6. In the model tree, click the ShapeString to select it.
  7. Menu CAM → Job (first toolbar icon). In the dialog, the ShapeString is the Base Model — click OK. FreeCAD adds a Job with Stock, a Tools group, and Operations.

  C. Add the 60° V-bit

  8. Double-click the Job in the tree → its editor opens → Tools tab.
  9. Click Add (the toolbit-library button). If prompted to add the default library, accept. Pick 60degree_Vbit → OK. You now have a Tool Controller TC: 60degree_Vbit.
    - While here, set sane feeds on that tool controller: Horizontal feed ≈ 200 mm/min, Vertical/plunge feed ≈ 100 mm/min (you can also just override feed live in
  bCNC).
  10. Close the Job editor.

  D. Add the Engrave operation

  11. In the tree, select the ShapeString (or the Model under Job).
  12. Menu CAM → Engraving → Engrave (dropdown may also list Vcarve/Deburr — pick plain Engrave). Its task panel opens:
    - Base Geometry: should auto-fill with the ShapeString edges. If empty, click Add, then box-select the letters in the 3D view.
    - Tool Controller: TC: 60degree_Vbit.
    - Depths → Final Depth: -0.2 mm (Start Depth 0). (0.2 mm deep with a 60° bit ≈ 0.23 mm line width.)
    - Heights → Clearance: 1 mm, Safe: 0.5 mm ← the engraving numbers we discussed.
  13. OK. A toolpath now traces every letter outline.

  E. Post-process to GRBL G-code

  14. Select the Job → in the Data panel (lower-left), find Post Processor → set it to grbl.
  15. Menu CAM → Post Process (toolbar "Post" icon) → save as:
  /home/xecaz/haxx/millingmachine/gcode/engrave_xecaz.nc
  → confirm/OK. That writes your GRBL-ready file.

  F. Cut it (bCNC)

  16. In bCNC: File → Open → engrave_xecaz.nc. The canvas shows your text.
  17. Fit the 60° V-bit. Jog to the bottom-left of where you want the text; set X0 Y0 there.
  18. Set Z0 on the surface with the paper method (jog down 0.05 mm steps until paper just drags).
  19. Turn the spindle on (your manual knob — decent speed for a V-bit, ~15–20k), hand near power, press Start ▶.

  ---
  That's the whole loop — after this, PCB milling is the same pipeline with a different CAM step. FreeCAD 1.1's labels are 95% what I listed, but if any menu/button
  reads differently on your screen, tell me exactly what you see and I'll steer you. And if you'd rather I hand you a reference .nc + .FCStd built headless (identical
  job) to compare against, just say so. Where do you get to?
