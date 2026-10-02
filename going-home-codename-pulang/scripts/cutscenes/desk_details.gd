class_name DeskDetails
extends RefCounted

static func badge(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = Vector3(-.5,.915,-.35)
	LowPoly.box(root,Vector3.ZERO,Vector3(.15,.025,.23),Color("637775"))
	LowPoly.box(root,Vector3(0,.013,0),Vector3(.136,.002,.211),Color("e8e0c7"))
	LowPoly.box(root,Vector3(0,.0145,-.083),Vector3(.133,.001,.035),Color("497d78"))
	LowPoly.box(root,Vector3(-.035,.0145,-.025),Vector3(.050,.001,.067),Color("a2b8ae"))
	LowPoly.sphere(root,Vector3(-.035,.016,-.037),Vector3(.023,.002,.027),Color("bd8b69"))
	LowPoly.box(root,Vector3(-.035,.016,-.01),Vector3(.035,.002,.023),Color("617262"))
	for z in [-.045,-.024,-.003]: LowPoly.box(root,Vector3(.027,.0145,z),Vector3(.051,.001,.004),Color("8b927e"))
	for i in range(14): LowPoly.box(root,Vector3(-.049+i*.0075,.0145,.083),Vector3(.002 if i%3 else .004,.001,.024),Color("415550"))
	LowPoly.box(root,Vector3(0,.019,-.11),Vector3(.035,.013,.05),Color("b3b8a7"))
	return root

static func lanyard(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	# The loop stays to the right of the mug footprint rather than under it.
	var points := [Vector3(-.5,.922,-.48),Vector3(-.54,.895,-.62),Vector3(-.59,.895,-.83),Vector3(-.73,.895,-.94),Vector3(-.81,.895,-.86),Vector3(-.77,.895,-.68),Vector3(-.64,.895,-.59),Vector3(-.5,.922,-.48)]
	for i in range(points.size()-1):
		var middle: Vector3 = (points[i]+points[i+1])*.5
		var strip := LowPoly.box(root,middle,Vector3(.018,.004,points[i].distance_to(points[i+1])+.004),Color("426d70"))
		strip.quaternion = Quaternion(Vector3.BACK,(points[i+1]-points[i]).normalized())
	return root
