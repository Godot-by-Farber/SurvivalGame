extends NavigationRegion3D


func _enter_tree() -> void:
	EventSystem.navmesh_rebake_requested.connect(bake_navigation_mesh)
