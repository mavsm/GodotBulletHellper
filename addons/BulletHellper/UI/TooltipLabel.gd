extends Label

export (String, MULTILINE) var tip = ""
export var tooltip_wait_time = .75

var has_mouse : bool

var yield_state : GDScriptFunctionState

func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")

func _mouse_entered():
	has_mouse = true
	yield_state = yield(get_tree().create_timer(tooltip_wait_time), "timeout")
	if not has_mouse:
		return
	get_tree().call_group("ToolTip", "appear", get_global_mouse_position(), tip)
	


func _mouse_exited():
	has_mouse = false
	if yield_state and yield_state.is_valid():
		yield_state.resume()
	get_tree().call_group("ToolTip", "disappear")
