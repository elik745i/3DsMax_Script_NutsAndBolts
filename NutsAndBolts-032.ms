
----------------------------------------------------------------------------------------------------------
--Nuts & Bolts :: Creates detailed models of nuts and bolts 

--Supported on 3ds Max 2016 to 3ds Max 2025
--Free for any kind of use and modification. The script is being provided as is, with no guarantees or support.
--By Oormi Creations, http://oormi.in
--Version 1.0.0 March 2026 - Max 2025 optimized: tapered thread tip, neck length control, fixed nut thread matching
-----------------------------------------------------------------------------------------------------------
clearlistener()
try closerolloutfloater nabrf
catch()

(
--vars
bolt 			= undefined
nut 			= undefined
washer 		= undefined
	
mtext 		= undefined
alltext 		= undefined
addmark 	= undefined

washht		= undefined
washdia1	= undefined
washdia2	= undefined
washcham	= undefined
	
headht		= undefined
headdia		= undefined
boltht		= undefined
segs 			= undefined
nothreadht = undefined
neckht		= undefined
threadht 	= undefined
threaddia 	= undefined
threadpitch = undefined
threaddepth = undefined
weldThreshold = undefined
threadchamfer = undefined

nutht			= undefined
nutdia1		= undefined
nutdia2		= undefined
nutsegs 		= undefined
nutthreadpitch = undefined
nutthreaddepth = undefined
nutweldThreshold = undefined
nutthreadchamfer = undefined
nutplay 		= undefined

prehead 	= undefined
prebolt 		= undefined
prenut 		= undefined
prewash		= undefined
preview		 = off

-- Thread preset data: #(name, boltDia(mm), pitch(mm), threadDepth(mm), headDia(mm), headHt(mm), nutDia1(mm), nutDia2(mm), nutHt(mm))
-- headDia and nutDia1 are circumscribed hex circle diameters (across-corners).
threadPresets = #(
	-- ISO Metric Coarse (ISO 4017 hex bolt / ISO 4032 hex nut)
	#("M2",         2.00,  0.40, 0.22,   4.6,  1.6,   4.6,  2.00,  1.6),
	#("M2.5",       2.50,  0.45, 0.24,   5.8,  2.0,   5.8,  2.50,  2.0),
	#("M3",         3.00,  0.50, 0.27,   6.4,  2.0,   6.4,  3.00,  2.4),
	#("M4",         4.00,  0.70, 0.38,   8.1,  2.8,   8.1,  4.00,  3.2),
	#("M5",         5.00,  0.80, 0.43,   9.2,  3.5,   9.2,  5.00,  4.0),
	#("M6",         6.00,  1.00, 0.54,  11.5,  4.0,  11.5,  6.00,  5.0),
	#("M8",         8.00,  1.25, 0.68,  15.0,  5.3,  15.0,  8.00,  6.5),
	#("M10",       10.00,  1.50, 0.81,  18.5,  6.4,  18.5, 10.00,  8.0),
	#("M12",       12.00,  1.75, 0.95,  20.8,  7.5,  20.8, 12.00, 10.0),
	#("M16",       16.00,  2.00, 1.08,  27.7, 10.0,  27.7, 16.00, 13.0),
	#("M20",       20.00,  2.50, 1.35,  34.6, 12.5,  34.6, 20.00, 16.0),
	#("M24",       24.00,  3.00, 1.62,  41.6, 15.0,  41.6, 24.00, 19.0),
	-- UNC - Unified National Coarse
	#("UNC #4-40",  2.85,  0.64, 0.34,   5.5,  1.9,   5.5,  2.85,  2.3),
	#("UNC #6-32",  3.51,  0.79, 0.43,   7.3,  2.3,   7.3,  3.51,  2.8),
	#("UNC #8-32",  4.17,  0.79, 0.43,   8.2,  2.7,   8.2,  4.17,  3.3),
	#("UNC #10-24", 4.83,  1.06, 0.57,   9.4,  3.1,   9.4,  4.83,  3.9),
	#("UNC 1/4-20", 6.35,  1.27, 0.69,  12.3,  4.1,  12.3,  6.35,  5.1),
	#("UNC 5/16-18",7.94,  1.41, 0.76,  15.5,  5.2,  15.5,  7.94,  6.4),
	#("UNC 3/8-16", 9.53,  1.59, 0.86,  18.5,  6.2,  18.5,  9.53,  7.6),
	#("UNC 1/2-13",12.70,  1.95, 1.06,  24.7,  8.3,  24.7, 12.70, 10.2),
	#("UNC 3/4-10",19.05,  2.54, 1.37,  37.0, 12.4,  37.0, 19.05, 15.2),
	-- UNF - Unified National Fine
	#("UNF 1/4-28", 6.35,  0.91, 0.49,  12.3,  4.1,  12.3,  6.35,  5.1),
	#("UNF 5/16-24",7.94,  1.06, 0.57,  15.5,  5.2,  15.5,  7.94,  6.4),
	#("UNF 3/8-24", 9.53,  1.06, 0.57,  18.5,  6.2,  18.5,  9.53,  7.6),
	#("UNF 1/2-20",12.70,  1.27, 0.69,  24.7,  8.3,  24.7, 12.70, 10.2),
	-- BSW - British Standard Whitworth (55 deg thread form)
	#("BSW 1/4in",  6.35,  1.27, 0.81,  14.7,  4.0,  14.7,  6.35,  5.5),
	#("BSW 3/8in",  9.53,  1.59, 1.02,  18.3,  6.0,  18.3,  9.53,  8.0),
	#("BSW 1/2in", 12.70,  2.12, 1.36,  22.0,  8.0,  22.0, 12.70, 10.5))

--------------------------------------------------------------------------------------------------------

fn cleanpreview =
(
	try
	(
		delete prehead
		delete prebolt
		delete prenut
		delete prewash
	)
	catch()
	prehead = undefined
	prebolt = undefined
	prenut = undefined
	prewash	= undefined
	preview = off
)
	
fn createwasher washpos wcol = 
(
	cy = Tube smooth:on sides:32 capsegs:1 heightsegs:1 radius1:(washdia1/2) radius2:(washdia2/2) height:washht name:(uniquename "Washer")
	hscale = washdia1/30.0
	
	pcy = convertToPoly(cy)
	pcy.EditablePoly.SetSelection #Edge #{4}
	pcy.EditablePoly.SelectEdgeLoop ()
	pcy.edgeChamferSegments = 4
	pcy.EditablePoly.chamferEdges (washcham*hscale)
	facecount = pcy.EditablePoly.getnumfaces()
	pcy.EditablePoly.SetSelection #Face #{1..facecount}
	pcy.autoSmoothThreshold = 25
	pcy.EditablePoly.autosmooth ()
	
	washer = pcy
	washer.pos = washpos - [0,0,washht]
	washer.wirecolor = wcol
	selectmore washer
)

fn createmark marktext markdia =
(
	toolMode.transformCenter()
	sz = markdia * 0.15
	start 	= 0
	sep 	= 20
	strht 	= markdia/100
	rad 	= markdia/4
	
	for i=1 to marktext.count do
	(
		ch 	= marktext[i]
		txt 	= text text:ch size:sz
		txt.pos = [0,0,headht]
		addmodifier txt (Extrude amount:strht)
		txt.pos.y = rad
		txt.rotation = (EulerAngles 0 0 (start+sep*i))
		ptxt = convertToPoly(txt)
		if i==1 then alltext = txt
		else polyop.attach alltext txt
	)
	toolMode.selectionCenter()
)


fn createnut1 nutpos wcol =
(
	--create the nut
	cy = Cylinder()
	cy.radius = (nutdia1/2)
	cy.height = nutht
	cy.heightsegs = 1
	cy.sides = 6
	cy.smooth = off
	hscale = nutdia1/100.0
	
	pcy = convertToPoly(cy)
	pcy.EditablePoly.SetSelection #Face #{7..8}
	pcy.EditablePoly.ConvertSelection #Face #Edge
	pcy.EditablePoly.chamferEdges (3.0*hscale)
	pcy.EditablePoly.SetSelection #Edge #{24,30}
	pcy.EditablePoly.SelectEdgeRing ()
	pcy.EditablePoly.chamferEdges (11.3*hscale)
	pcy.EditablePoly.chamferEdges (5.5*hscale)
	pcy.EditablePoly.SetSelection #Edge #{19..30, 91..102, 104, 111, 114, 117, 120, 123, 127, 130, 133, 136, 147, 152, 157..158, 161, 164, 167, 170, 175..176, 181, 183, 186, 189, 199..222}
	pcy.EditablePoly.chamferEdges (2.5*hscale)
	pcy.EditablePoly.SetSelection #Edge #{2, 4, 6, 9, 12, 15}
	pcy.EditablePoly.chamferEdges (1.0*hscale)
	pcy.EditablePoly.SetSelection #Face #{7..8}
	pcy.bevelFaces 0.0 (-20.0*hscale)
	facecount = pcy.EditablePoly.getnumfaces()
	pcy.EditablePoly.SetSelection #Face #{1..facecount}
	pcy.autoSmoothThreshold = 25
	pcy.EditablePoly.autosmooth ()

	if nutsegs<3 then nutsegs = 3
	if nutsegs>60 then nutsegs = 60
		
	rem = mod 360 nutsegs
	if rem>0 then
	(
		for i=1 to 360 do
		(
			nutsegs = nutsegs-1
			rem = mod 360 nutsegs
			if rem<1 then exit
		)
	)
	
	-- Direct radii offset for play avoids Push modifier deformation artifacts
	r2 = (nutdia2/2) + nutplay
	r1 = r2-nutthreaddepth
	d1 = nutthreadpitch/2
	d2 = nutthreadpitch
	turns = (nutht/nutthreadpitch)+1
	density = 360/nutsegs

	ep = editable_mesh name:(uniquename "Thread")
	convertTo ep (Editable_Poly)

	for t=0 to turns*360 by density do
	(
		x	=	r1*cos(t)
		y	=	r1*sin(t)
		z	=	(d2*t/360.0)
		v1 = ep.createVertex [x,y,z]
		x2	=	r2*cos(t)
		y2	=	r2*sin(t)
		v2 = ep.createVertex [x2,y2,z+d1]
		v3 = ep.createVertex [x,y,z+d2]
		
		if t>0 then 
		(
			ep.createFace #(v1,v2,v2-3,v1-3)
			ep.createFace #(v2,v3,v2-2,v1-2)
		)
	)

	ep.weldThreshold = nutweldThreshold
	polyop.weldVertsByThreshold ep #{1..(getnumverts ep)}

	ep.EditablePoly.SetSelection #Edge #{2}
	ep.EditablePoly.SelectEdgeLoop ()
	ep.EditablePoly.chamferEdges nutthreadchamfer
	addmodifier ep (Cap_Holes ())
	addmodifier ep (smooth autosmooth:on THRESHOLD:30)
	convertTo ep PolyMeshObject

	--boolean
	ep.pos = [0,0,-nutthreadpitch]
	nut = pcy - ep
	delete ep
	convertToPoly (nut)
	nut.name = uniquename "Nut"
	move nut nutpos
	nut.wirecolor = wcol

	selectMore nut
	--show all
	max zoomext sel all

)

fn createnut2 nutpos wcol =
(
	--create the nut
	cy = Cylinder()
	cy.radius = (nutdia1/2)
	cy.height = nutht
	cy.heightsegs = 1
	cy.sides = 6
	cy.smooth = off
	hscale = nutdia1/100.0
	
	pcy = convertToPoly(cy)
	pcy.EditablePoly.SetSelection #Face #{1,8}
	pcy.EditablePoly.ConvertSelection #Face #Edge
	pcy.EditablePoly.chamferEdges (3.0*hscale)
	pcy.EditablePoly.SetSelection #Edge #{24,30}
	pcy.EditablePoly.SelectEdgeRing ()
	pcy.EditablePoly.chamferEdges (11.3*hscale)
	pcy.EditablePoly.chamferEdges (5.5*hscale)
	pcy.EditablePoly.SetSelection #Edge #{19..30, 91..102, 104, 111, 114, 117, 120, 123, 127, 130, 133, 136, 147, 152, 157..158, 161, 164, 167, 170, 175..176, 181, 183, 186, 189, 199..222}
	pcy.EditablePoly.chamferEdges (2.5*hscale)
	pcy.EditablePoly.SetSelection #Edge #{8..9, 11, 13, 15, 17}
	pcy.EditablePoly.chamferEdges (1.0*hscale)
	pcy.EditablePoly.SetSelection #Face #{1,8}
	pcy.bevelFaces 0.0 (-20.0*hscale)
	facecount = pcy.EditablePoly.getnumfaces()
	pcy.EditablePoly.SetSelection #Face #{1..facecount}
	pcy.autoSmoothThreshold = 25
	pcy.EditablePoly.autosmooth ()

	if nutsegs<3 then nutsegs = 3
	if nutsegs>60 then nutsegs = 60
		
	rem = mod 360 nutsegs
	if rem>0 then
	(
		for i=1 to 360 do
		(
			nutsegs = nutsegs-1
			rem = mod 360 nutsegs
			if rem<1 then exit
		)
	)
	
	-- Direct radii offset for play avoids Push modifier deformation artifacts
	r2 = (nutdia2/2) + nutplay
	r1 = r2-nutthreaddepth
	d1 = nutthreadpitch/2
	d2 = nutthreadpitch
	turns = (nutht/nutthreadpitch)+1
	density = 360/nutsegs

	ep = editable_mesh name:(uniquename "Thread")
	convertTo ep (Editable_Poly)

	for t=0 to turns*360 by density do
	(
		x	=	r1*cos(t)
		y	=	r1*sin(t)
		z	=	(d2*t/360.0)
		v1 = ep.createVertex [x,y,z]
		x2	=	r2*cos(t)
		y2	=	r2*sin(t)
		v2 = ep.createVertex [x2,y2,z+d1]
		v3 = ep.createVertex [x,y,z+d2]
		
		if t>0 then 
		(
			ep.createFace #(v1,v2,v2-3,v1-3)
			ep.createFace #(v2,v3,v2-2,v1-2)
		)
	)

	ep.weldThreshold = nutweldThreshold
	polyop.weldVertsByThreshold ep #{1..(getnumverts ep)}

	ep.EditablePoly.SetSelection #Edge #{2}
	ep.EditablePoly.SelectEdgeLoop ()
	ep.EditablePoly.chamferEdges nutthreadchamfer
	addmodifier ep (Cap_Holes ())
	addmodifier ep (smooth autosmooth:on THRESHOLD:30)
	convertTo ep PolyMeshObject

	--boolean
	ep.pos = [0,0,-nutthreadpitch]
	nut = pcy - ep
	delete ep
	convertToPoly (nut)
	nut.name = uniquename "Nut"
	move nut nutpos
	nut.wirecolor = wcol

	selectMore nut
	--show all
	max zoomext sel all

)

fn createbolt boltpos wcol =
(
	head 	= undefined
	thr 	= undefined
	plain 	= undefined
	
	--create the head
	(
	cy = Cylinder()
	cy.radius = headdia/2
	cy.height = headht
	cy.heightsegs = 1
	cy.sides = 6
	cy.smooth = off
	
	hscale = headdia/100.0
	
	pcy = convertToPoly(cy)
	-- Three clean geometric passes — no hard-coded indices, no overlapping selections.

	-- Pass 1: Bottom rim bevel (bearing face chamfer)
	local btmBits = #{}
	local ne = polyop.getNumEdges pcy
	for i = 1 to ne do
	(
		local ev = polyop.getEdgeVerts pcy i
		local p1 = polyop.getVert pcy ev[1] ; local p2 = polyop.getVert pcy ev[2]
		if p1.z < headht*0.02 and p2.z < headht*0.02 then append btmBits i
	)
	pcy.EditablePoly.SetSelection #Edge btmBits
	pcy.EditablePoly.chamferEdges (3.0*hscale)

	-- Pass 2: Vertical hex corner edges (both verts at circumscribed radius, spans >15% of height)
	-- Require min-z > 5% headht to skip the tiny connector stubs created by Pass 1.
	local corrBits = #{}
	ne = polyop.getNumEdges pcy
	for i = 1 to ne do
	(
		local ev = polyop.getEdgeVerts pcy i
		local p1 = polyop.getVert pcy ev[1] ; local p2 = polyop.getVert pcy ev[2]
		local ra = sqrt(p1.x*p1.x + p1.y*p1.y)
		local rb = sqrt(p2.x*p2.x + p2.y*p2.y)
		local minZ = if p1.z < p2.z then p1.z else p2.z
		if ra > (headdia/2)*0.92 and rb > (headdia/2)*0.92 and abs(p1.z - p2.z) > headht*0.15 and minZ > headht*0.05 then
			append corrBits i
	)
	pcy.EditablePoly.SetSelection #Edge corrBits
	pcy.EditablePoly.chamferEdges (1.0*hscale)

	-- Pass 3: Top rim (both verts at z ≈ headht)
	local topBits = #{}
	ne = polyop.getNumEdges pcy
	for i = 1 to ne do
	(
		local ev = polyop.getEdgeVerts pcy i
		local p1 = polyop.getVert pcy ev[1] ; local p2 = polyop.getVert pcy ev[2]
		if p1.z > headht*0.99 and p2.z > headht*0.99 then append topBits i
	)
	pcy.EditablePoly.SetSelection #Edge topBits
	pcy.EditablePoly.chamferEdges (1.0*hscale)

	facecount = pcy.EditablePoly.getnumfaces()
	pcy.EditablePoly.SetSelection #Face #{1..facecount}
	pcy.autoSmoothThreshold = 25
	pcy.EditablePoly.autosmooth ()
	
	head = pcy
	)


	
	
	if segs<3 then segs = 3
	if segs>60 then segs = 60
		
	rem = mod 360 segs
	if rem>0 then
	(
		for i=1 to 360 do
		(
			segs = segs-1
			rem = mod 360 segs
			if rem<1 then exit
		)
	)
	
	nothreadht = neckht
	r2 = threaddia/2
	r1 = r2-threaddepth
	d1 = threadpitch/2
	d2 = threadpitch
	turns = (threadht/threadpitch)
	density = 360/segs
	local tipRunoutAngle = 360.0  -- fan thread into the tip over the last full turn
	local topRunoutAngle = 180.0  -- flatten minor diameter into the neck over the last half turn
	local tipOffset = r2 * 0.08   -- slightly deeper flat cut based on bolt OD
	local totalEndAngle = turns * 360.0
	local effectiveTopEndAngle = amax -360.0 (totalEndAngle - density)

	ep = editable_mesh name:(uniquename "Thread")
	convertTo ep (Editable_Poly)

	-- Start one full turn before the visible tip. That turn is the bottom runout into the
	-- small OD-based tip cut, so the thread exit tapers evenly around the circumference.
	local firstIter = true
	for t = -360 to effectiveTopEndAngle by density do
	(
		-- Bottom taper: crest grows r1->r2 over the first full turn at the tip.
		local tipFactor = (t + tipRunoutAngle) / tipRunoutAngle
		if tipFactor < 0.0 then tipFactor = 0.0
		if tipFactor > 1.0 then tipFactor = 1.0
		-- Top runout amount over the last half turn. Only the minor diameter fans outward
		-- to the major diameter; the helical Z positions stay unchanged.
		local endFactor = (effectiveTopEndAngle - t) / topRunoutAngle
		if endFactor < 0.0 then endFactor = 0.0
		if endFactor > 1.0 then endFactor = 1.0
		local topFill = 1.0 - (endFactor * endFactor * endFactor)
		curR2 = r1 + (r2 - r1) * tipFactor   -- bottom tip runout only; crest stays full at top

		-- Clamp all vertex Z to [-tipOffset, threadht]. Bottom is clipped; the last generated top
		-- ring stops one step early so we don't create duplicate collapsed points at the exit.
		baseZ = d2*t/360.0
		v1z = baseZ    ; if v1z < -tipOffset then v1z = -tipOffset ; if v1z > threadht then v1z = threadht
		v2z = baseZ+d1 ; if v2z < -tipOffset then v2z = -tipOffset ; if v2z > threadht then v2z = threadht
		v3z = baseZ+d2 ; if v3z < -tipOffset then v3z = -tipOffset ; if v3z > threadht then v3z = threadht

		local v1r = r1 + (r2 - r1) * topFill
		local v2r = curR2
		local v3r = r1 + (r2 - r1) * topFill
		if v1z < 0 then v1r = amin v1r (r1 + v1z)
		if v2z < 0 then v2r = amin v2r (r1 + v2z)
		if v3z < 0 then v3r = amin v3r (r1 + v3z)

		x  = v1r * cos(t)
		y  = v1r * sin(t)
		v1 = ep.createVertex [x, y, v1z]
		x2 = v2r * cos(t)
		y2 = v2r * sin(t)
		v2 = ep.createVertex [x2, y2, v2z]
		v3 = ep.createVertex [v3r * cos(t), v3r * sin(t), v3z]

		if not firstIter then 
		(
			ep.createFace #(v1,v2,v2-3,v1-3)
			ep.createFace #(v2,v3,v2-2,v1-2)
		)
		firstIter = false
	)

	ep.weldThreshold = weldThreshold
	polyop.weldVertsByThreshold ep #{1..(getnumverts ep)}

	ep.EditablePoly.SetSelection #Edge #{2}
	ep.EditablePoly.SelectEdgeLoop ()
	ep.EditablePoly.chamferEdges threadchamfer

	addmodifier ep (Cap_Holes ())
	addmodifier ep (smooth autosmooth:on THRESHOLD:30)
	convertTo ep PolyMeshObject
	thr = ep

	if nothreadht > 0 then
	(
		local neckChamfer = amin threadpitch nothreadht
		local neckBottomRadius = r2 - neckChamfer
		if neckBottomRadius < r1 then neckBottomRadius = r1

		local neckBase = cone height:neckChamfer radius1:neckBottomRadius radius2:r2 sides:segs smooth:on pos:[0,0,threadht]
		ep.EditablePoly.attach neckBase ep

		if nothreadht > neckChamfer then
		(
			local neckStraight = cylinder height:(nothreadht-neckChamfer) radius:r2 heightsegs:1 capsegs:1 sides:segs pos:[0,0,threadht+neckChamfer]
			ep.EditablePoly.attach neckStraight ep
		)
		-- Weld the flat thread-top ring to the cylinder bottom ring (they share the same positions)
		ep.weldThreshold = weldThreshold
		polyop.weldVertsByThreshold ep #{1..(getnumverts ep)}
	)

	--text
	if addmark then
	(
		createmark mtext headdia
		polyop.attach head alltext
	)
 	head.pos = [0,0,nothreadht+threadht]
	
	--attach all
	polyop.attach head thr
	head.name = uniquename "Bolt"
	bolt = head
	bolt.pos = boltpos
	bolt.wirecolor = wcol
	select bolt
	
	--show all
	max zoomext sel all
)

rollout setnab "Settings" --width:180 height:520
(
	groupBox group1 "Bolt" 		pos:[5,  5] width:170 height:250 	
	groupBox group2 "Nut" 		pos:[5,260] width:170 height:240 	
	groupBox group3 "Washer" 	pos:[5,500] width:170 height:120 	
	groupBox group4 "Markings" 	pos:[5,620] width:170 height:70 	
-- 	groupBox group5 "Material" 	pos:[5,525] width:170 height:50 	
	
	label lbl1  "Head Diameter" 	pos:[10, 20]
	label lbl2  "Head Height" 		pos:[10, 40]
	label lbl3  "Bolt Diameter" 		pos:[10, 60]
	label lbl4  "Neck Length" 		pos:[10, 80]
	label lbl5  "Threaded Height" 	pos:[10,100]
	label lbl6  "Thread Depth" 		pos:[10,120]
	label lbl7  "Thread Pitch" 		pos:[10,140]
	label lbl17  "Thread Chamfer" 	pos:[10,160]
	label lbl18  "Weld Threshold" 		pos:[10,180]
	label lbl19  "Segments" 			pos:[10,200]
	
	label lbl24  "Lock Parameters With Bolt" 	pos:[10,280]
	label lbl8  "Outer Diameter" 	pos:[10,300]
	label lbl9  "Inner Diameter" 	pos:[10,320]
	label lbl10 "Nut Height" 		pos:[10,340]
	label lbl11 "Thread Depth" 	pos:[10,360]
	label lbl12 "Thread Pitch" 		pos:[10,380]
	label lbl20  "Thread Chamfer" 	pos:[10,400]
	label lbl21  "Weld Threshold" 		pos:[10,420]
	label lbl22  "Segments" 		pos:[10,440]
	label lbl23  "Play" 				pos:[10,460]
	
	label lbl13  "Outer Diameter" 	pos:[10,520]
	label lbl14  "Inner Diameter" 	pos:[10,540]
	label lbl15  "Washer Height"	pos:[10,560]
	label lbl25  "Washer Chamfer"	pos:[10,580]

	spinner spn1  pos:[100, 20] width:60 range:[1,1000,20] type:#float scale:0.01 align: #left
	spinner spn2  pos:[100, 40] width:60 range:[1,1000,10] type:#float scale:0.01 align: #left
	spinner spn3  pos:[100, 60] width:60 range:[1,1000,10] type:#float scale:0.01 align: #left
	spinner spn4  pos:[100, 80] width:60 range:[0,1000,15] type:#float scale:0.01 align: #left
	spinner spn5  pos:[100,100] width:60 range:[1,1000,35] type:#float scale:0.01 align: #left
	spinner spn6  pos:[100,120] width:60 range:[0,1000,1] type:#float scale:0.01 align: #left
	spinner spn7  pos:[100,140] width:60 range:[0.01,1000,2] type:#float scale:0.01 align: #left
	spinner spn17  pos:[100,160] width:60 range:[0,100,0.15] type:#float scale:0.01 align: #left
	spinner spn18  pos:[100,180] width:60 range:[0,1, 0.01] type:#float scale:0.001 align: #left
	spinner spn19  pos:[100,200] width:60 range:[3,128, 24] type:#integer align: #left
	
	spinner spn8  pos:[100,300] width:60 range:[1,1000,20] type:#float scale:0.01 align: #left enabled:off
	spinner spn9  pos:[100,320] width:60 range:[1,1000,10] type:#float scale:0.01 align: #left enabled:off
	spinner spn10 pos:[100,340] width:60 range:[1,1000,10] type:#float scale:0.01 align: #left enabled:off
	spinner spn11 pos:[100,360] width:60 range:[0,1000,1] type:#float scale:0.01 align: #left enabled:off
	spinner spn12 pos:[100,380] width:60 range:[0.01,1000,2] type:#float scale:0.01 align: #left enabled:off
	spinner spn20  pos:[100,400] width:60 range:[0,100,0.15] type:#float scale:0.01 align: #left enabled:off
	spinner spn21  pos:[100,420] width:60 range:[0,1, 0.01] type:#float scale:0.001 align: #left enabled:off
	spinner spn22  pos:[100,440] width:60 range:[3,128, 24] type:#integer align: #left enabled:off
	spinner spn23  pos:[100,460] width:60 range:[0,100, 0.25] type:#float scale:0.001 align: #left 

	checkbutton lockbtn pos:[140,270] checked:on images:#("LockButton_i.bmp", "LockButton_a.bmp", 1, 1, 1, 1, 1) tooltip:"Lock parameters with those of the bolt"
	pickbutton pickboltpos "Pick Bolt's Position" pos:[10,225] width:160 tooltip:"Right click to reset"
	checkbox chklink "Link to the Bolt" pos:[10,480] checked:true

	spinner spn14  pos:[100,520] width:60 range:[0,1000,30] type:#float scale:0.01 align: #left
	spinner spn15  pos:[100,540] width:60 range:[0,1000,15] type:#float scale:0.01 align: #left
	spinner spn16 pos:[100,560] width:60 range:[0,1000, 2] type:#float scale:0.01 align: #left
	spinner spn24 pos:[100,580] width:60 range:[0,1000, 1] type:#float scale:0.01 align: #left

	checkbox chklink2 "Link to the Bolt" pos:[10,600] checked:true

	edittext marktxt "Text" pos:[10,640] fieldWidth:130 text:"Nuts & Bolts" labelOnTop:false
	checkbox chkmark "Use" pos:[10,660] checked:true

	local pickedboltpos = undefined
	 
	on pickboltpos picked obj do
	( 
		 if obj != undefined do
		 (
			pickedboltpos = obj
			pickboltpos.text = "Position: " + obj.name
		 )
	)-- on
	
	on pickboltpos rightclick do 
	(
		pickedboltpos = undefined
		pickboltpos.text = "Pick Bolt's Position"
	)
	
	on spn5 changed  val do 
	(
		if preview then 
		(
			prebolt.height = spn4.value + val
			prebolt.pos = [0,0,-(spn4.value + val)]
		)
	)
	on spn4 changed  val do 
	(
		if preview then 
		(
			prebolt.height = val + spn5.value
			prebolt.pos = [0,0,-(val + spn5.value)]
		)
	)
	
	--lock parameters
	on spn1 changed  val do 
	(
		if lockbtn.state==on then 
		(
			spn8.value = val
			if preview then prenut.radius = val/2
		)
		if preview then prehead.radius = val/2
	)
	on spn3 changed  val do 
	(
		if lockbtn.state==on then spn9.value = val
		if preview then prebolt.radius = val/2
	)
	on spn2 changed  val do 
	(
		if lockbtn.state==on then 
		(
			spn10.value = val
			if preview then prenut.height = val
		)
		if preview then prehead.height = val
	)
	on spn6 changed  val do 
	(
		if lockbtn.state==on then spn11.value = val
	)
	on spn7 changed  val do 
	(
		if lockbtn.state==on then spn12.value = val
	)
	on spn17 changed  val do 
	(
		if lockbtn.state==on then spn20.value = val
	)
	on spn8 changed  val do 
	(
		if preview then prenut.radius = val/2
	)
	on spn10 changed  val do 
	(
		if preview then prenut.height = val
	)
	on spn18 changed  val do 
	(
		if lockbtn.state==on then spn21.value = val
	)
	on spn19 changed  val do 
	(
		if lockbtn.state==on then spn22.value = val
	)
	on spn14 changed  val do 
	(
		if preview then prewash.radius1 = val/2
	)
	on spn15 changed  val do 
	(
		if preview then prewash.radius2 = val/2
	)
	on spn16 changed  val do 
	(
		if preview then 
		(
			prewash.height = val
			prewash.pos = [0,0,-val]
		)
	)
	
	on lockbtn changed thestate do
	(
		spn8.enabled = not thestate
		spn9.enabled = not thestate
		spn10.enabled = not thestate
		spn11.enabled = not thestate
		spn12.enabled = not thestate
		spn20.enabled = not thestate
		spn21.enabled = not thestate
		spn22.enabled = not thestate
	)
)

rollout helpnab "Help and About" height:100
(
	label lbl2 "Nuts and Bolts Version 1.0.0"
	label lbl3 "Original: Oormi Creations 2018"
	label lbl4 "Updated: March 2026 for 3ds Max 2025"
	button  hbtn1 "Local Help" width:160
	hyperlink hlink3 "GitHub Repository" pos:[35,90] address:"https://github.com/elik745i/3DsMax_Script_NutsAndBolts" color:yellow
	label lbl1 "" pos:[0,110]
	label lbl5 "Whats New in 1.0.0:" pos:[10,125]
	label lbl6 "- Neck Length control" pos:[10,140]
	label lbl7 "- Tapered thread tip" pos:[10,155]
	label lbl8 "- Fixed nut thread (no Push distortion)" pos:[10,170]
	label lbl9 "- 28 thread standard presets" pos:[10,185]
	label lbl10 "- 3D Print mode (FDM/SLA + nozzle gap)" pos:[10,200]
	label lbl11 "- 3ds Max 2016-2025 compatible" pos:[10,215]
	bitmap the_bmp fileName:"nuts_doc//OormiLogo.png" pos:[60,235]
	
	on hbtn1 pressed do 
	(
		sfile = getSourceFileName()
		spath = getFilenamePath sfile
		hfile = spath + "nutshelp-01.html"
		hext = doesFileExist hfile
		if hext then ShellLaunch hfile ""
		else messageBox ("The file nutshelp-01.html was not found.\n\nPlease copy it to " + spath + "\nOr visit the GitHub repository for help.")
	)
)

rollout NABRollout "Nuts & Bolts :: V 1.0.0"  
(
	groupBox group4 "Actions" 	pos:[5,5] width:170 height:200 	
	button  btn1 "Create Nuts & Bolts"	pos:[10,25] width:160 height:40
	checkbutton chkbolt "Bolt" pos:[10,80] width:120 checked:true tooltip:"Enables Bolts" highlightColor:[80,100,80]
	checkbutton chknut  "Nut"  pos:[10,110] width:120 checked:false tooltip:"Enables Nuts" highlightColor:[80,100,80]
	checkbutton chkwash  "Washer"  pos:[10,140] width:120 checked:false tooltip:"Enables Washers" highlightColor:[80,100,80]
	checkbutton chkprev  "Preview"  pos:[10,170] width:120 checked:off tooltip:"Enables Preview" highlightColor:[80,100,80]
	colorpicker cpbolt color: [200,210,220] width: 40 pos:[130,80]
	colorpicker cpnut color: [160,180,220] width: 40 pos:[130,110]
	colorpicker cpwash color: [90,100,110] width: 40 pos:[130,140]
	colorpicker cpprev color: [150,100,100] width: 40 pos:[130,170]

	on NABRollout close do 
	(
		cleanpreview()
		callbackItem=undefined; 
		gc();
-- 		print "NAB Closed"
	)
	
	on chkprev changed thestate do
	(
		--show preview
		if thestate then
		(
			prehead	= cylinder smooth:off heightsegs:1 capsegs:1 sides:6 height:setnab.spn2.value radius:(setnab.spn1.value/2) wirecolor:cpprev.color renderable:off name:(uniquename "BoltHeadPreview")
			prebolt 	= cylinder smooth:on heightsegs:1 capsegs:1 sides:12 height:(setnab.spn4.value + setnab.spn5.value) radius:(setnab.spn3.value/2) wirecolor:cpprev.color renderable:off name:(uniquename "BoltPreview")
			prenut 	= cylinder smooth:off heightsegs:1 capsegs:1 sides:6 height:setnab.spn10.value radius:(setnab.spn8.value/2) wirecolor:cpprev.color renderable:off name:(uniquename "NutPreview")
			prewash = Tube smooth:on sides:32 capsegs:1 heightsegs:1 radius1:(setnab.spn14.value/2) radius2:(setnab.spn15.value/2) height:setnab.spn16.value wirecolor:cpprev.color renderable:off name:(uniquename "WasherPrevview")
			prewash.pos = [0,0,-prewash.height]
			prebolt.pos = [0,0,-prebolt.height]
			prenut.pos = [0,0,((-prebolt.height/2)-prenut.height)]
			preview = on
		)
		else cleanpreview()
	)
	
	on btn1 pressed do
	(
		mtext		= setnab.marktxt.text
		addmark 	= setnab.chkmark.checked
		washht		= setnab.spn16.value
		washdia1	= setnab.spn14.value
		washdia2	= setnab.spn15.value
		washcham	= setnab.spn24.value
		
		neckht		= setnab.spn4.value
		headht		= setnab.spn2.value
		headdia		= setnab.spn1.value
		segs 			= setnab.spn19.value
		threadht 	= setnab.spn5.value
		boltht		= neckht + threadht
		threaddia 	= setnab.spn3.value
		threadpitch = setnab.spn7.value
		threaddepth 	= setnab.spn6.value
		weldThreshold = setnab.spn18.value
		threadchamfer = setnab.spn17.value
		
		nutdia1		= setnab.spn8.value
		nutdia2		= setnab.spn9.value
		nutht			= setnab.spn10.value
		nutplay 		= setnab.spn23.value
		nutsegs 		= setnab.spn22.value
		nutthreadpitch 	= setnab.spn12.value
		nutthreaddepth 	= setnab.spn11.value
		nutweldThreshold = setnab.spn21.value
		nutthreadchamfer = setnab.spn20.value
		
		bolt = undefined
		nut = undefined
		washer = undefined

		boltpos = [0,0,0]
		if setnab.pickedboltpos !=undefined then
		(
			if isdeleted setnab.pickedboltpos then 
			(
				setnab.pickedboltpos = undefined
				setnab.pickboltpos.text = "Pick Bolt's Position"
			)
		)
		
		if setnab.pickedboltpos !=undefined then boltpos = setnab.pickedboltpos.pos
		nutpos  = boltpos + [0,0, -neckht-2*nutht]
		
		undo "Nuts & Bolts" on
		(
			ver = maxversion()
			if chkbolt.state == on then createbolt boltpos cpbolt.color
			if chknut.state  == on then createnut2 nutpos cpnut.color
			if chkwash.state  == on then createwasher boltpos cpwash.color
				
			if setnab.chklink.state == on then 
			(
				if nut !=undefined then nut.parent = bolt
				if washer !=undefined then washer.parent = bolt
			)
		)
		cleanpreview()
		chkprev.checked = off
	)
	
)

rollout presetsnab "Presets & 3D Print"
(
	groupBox grpThr "Thread Standard"           pos:[5,5]   width:170 height:65
	label    lblPrs "Standard:"                 pos:[10,22]
	dropdownList ddPreset                        pos:[10,39] width:155

	groupBox grp3dp "3D Print"                  pos:[5,75]  width:170 height:110
	checkbox chk3dp "Optimize for 3D Printing"  pos:[10,92] checked:false
	label    lblPrType "Printer:"               pos:[10,115]
	dropdownList ddPrType pos:[65,112] width:100 items:#("FDM","SLA") enabled:false
	label    lblNzl "Nozzle:"                    pos:[10,138]
	dropdownList ddNozzle pos:[65,135] width:100 items:#("0.4 mm (standard)","0.2 mm (fine)") enabled:false

	fn applyPrintPlay =
	(
		if chk3dp.checked then
		(
			if ddPrType.selection == 1 then  -- FDM
			(
				if ddNozzle.selection == 1 then setnab.spn23.value = 0.40  -- 0.4 mm nozzle
				else                           setnab.spn23.value = 0.25  -- 0.2 mm nozzle
			)
			else setnab.spn23.value = 0.15  -- SLA: high precision, tight gap
		)
	)

	on presetsnab open do
	(
		local pnames = #("-- Select Preset --")
		for p in threadPresets do append pnames p[1]
		ddPreset.items = pnames
	)

	on ddPreset selected idx do
	(
		if idx > 1 then
		(
			p = threadPresets[idx-1]
			-- p: #(name, boltDia, pitch, threadDepth, headDia, headHt, nutDia1, nutDia2, nutHt)
			setnab.spn3.value  = p[2]  -- Bolt Diameter
			setnab.spn7.value  = p[3]  -- Thread Pitch
			setnab.spn6.value  = p[4]  -- Thread Depth
			setnab.spn1.value  = p[5]  -- Head Diameter
			setnab.spn2.value  = p[6]  -- Head Height
			setnab.spn8.value  = p[7]  -- Nut Outer Diameter
			setnab.spn9.value  = p[8]  -- Nut Inner Diameter
			setnab.spn10.value = p[9]  -- Nut Height
			setnab.spn12.value = p[3]  -- Nut Thread Pitch
			setnab.spn11.value = p[4]  -- Nut Thread Depth
			applyPrintPlay()
		)
	)

	on chk3dp changed theState do
	(
		ddPrType.enabled = theState
		ddNozzle.enabled = (theState and ddPrType.selection == 1)
		applyPrintPlay()
	)

	on ddPrType selected idx do
	(
		ddNozzle.enabled = (chk3dp.checked and idx == 1)
		applyPrintPlay()
	)

	on ddNozzle selected idx do applyPrintPlay()
)

fn CallbackFn1 ev nd = 
(
	predel = off
	if prehead != undefined then
	(
		if isdeleted prehead then predel = on
	)
	if prenut != undefined then
	(
		if isdeleted prenut then  predel = on
	)
	if prebolt != undefined then
	(
		if isdeleted prebolt then  predel = on
	)
	if prewash != undefined then
	(
		if isdeleted prewash then  predel = on
	)
	
	if predel then
	(
		preview = off
		NABRollout.chkprev.checked = off
		try (delete prebolt);catch()
		try (delete prenut);catch()
		try (delete prehead);catch()
		try (delete prewash);catch()
		redrawviews()
-- 		print "Preview deleted"
	)
)

callbackItem = NodeEventCallback deleted:CallbackFn1 

nabrf = newRolloutFloater  "Nuts & Bolts" 200 630
addRollout NABRollout  nabrf
addRollout presetsnab  nabrf
addRollout setnab  nabrf
addRollout helpnab  nabrf

)
