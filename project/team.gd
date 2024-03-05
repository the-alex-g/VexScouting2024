class_name Team
extends VBoxContainer

enum AutonTasks {CORNER_TRIBALL, SCORE_PRELOAD, TOUCH_BAR, PRELOAD_TO_OFFENSIVE_ZONE, CROSSED_LINE}

var team_id : String : get = get_team_id
var _next_note_field : LineEdit : set = _set_next_note_field

@onready var _team_id_line_edit : LineEdit = $TeamID
@onready var _note_container : VBoxContainer = $Notes


func _ready()->void:
	_set_next_note_field($Notes/NoteField)


func get_team_id()->String:
	return _team_id_line_edit.text


func get_notes()->Array[String]:
	var notes : Array[String] = []
	for note_field : LineEdit in _note_container.get_children():
		if note_field.text != "":
			notes.append(note_field.text)
	return notes


func get_auton()->Dictionary:
	return {
		AutonTasks.CORNER_TRIBALL:$Auton/Corner.button_pressed,
		AutonTasks.SCORE_PRELOAD:$Auton/Scored.button_pressed,
		AutonTasks.TOUCH_BAR:$Auton/Bar.button_pressed,
		AutonTasks.PRELOAD_TO_OFFENSIVE_ZONE:$Auton/OffensiveZone.button_pressed,
		AutonTasks.CROSSED_LINE:$Auton/CrossedLine.button_pressed
	}


func clear()->void:
	_team_id_line_edit.text = ""
	for note_field :LineEdit in _note_container.get_children():
		note_field.queue_free()
	for auton_task_button : CheckBox in $Auton.get_children():
		auton_task_button.button_pressed = false
	_add_new_note_field()


func _set_next_note_field(value:LineEdit)->void:
	if _next_note_field:
		if _next_note_field.text_changed.is_connected(_on_next_note_field_text_changed):
			_next_note_field.text_changed.disconnect(_on_next_note_field_text_changed)
	_next_note_field = value
	_next_note_field.text_changed.connect(_on_next_note_field_text_changed)


func _add_new_note_field()->void:
	var note_field := LineEdit.new()
	note_field.placeholder_text = "Notes"
	_note_container.add_child(note_field)
	_set_next_note_field(note_field)


func _on_next_note_field_text_changed(new_text:String)->void:
	if new_text != "":
		_add_new_note_field()
