extends VBoxContainer

const CONFIG_PATH := "res://team_record.cfg"

@onready var _autonomous_tasks_label : Label = $ResultsContainer/AutonomousTasks
@onready var _notes_label : Label = $ResultsContainer/Notes
@onready var _expected_score_label : Label = $ExpectedScoreLabel


func _on_team_id_text_changed(new_text:String)->void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	if config.has_section(new_text):
		_lookup_team(new_text, config)
	else:
		_clear_results()


func _lookup_team(team_name:String, config:ConfigFile)->void:
	_display_auton_tasks(config.get_value(team_name, "auton", {}))
	_display_notes(config.get_value(team_name, "notes", []))
	_update_score(config.get_value(team_name, "scores", []))


func _clear_results()->void:
	_autonomous_tasks_label.text = ""
	_notes_label.text = ""
	_expected_score_label.text = ""


func _display_auton_tasks(auton_tasks:Dictionary)->void:
	if auton_tasks[Team.AutonTasks.CORNER_TRIBALL]:
		_autonomous_tasks_label.text += "triball removed from corner\n"
	if auton_tasks[Team.AutonTasks.SCORE_PRELOAD]:
		_autonomous_tasks_label.text += "preload scored in goal\n"
	if auton_tasks[Team.AutonTasks.TOUCH_BAR]:
		_autonomous_tasks_label.text += "touched climb bar\n"
	if auton_tasks[Team.AutonTasks.PRELOAD_TO_OFFENSIVE_ZONE]:
		_autonomous_tasks_label.text += "preload put in offensive zone\n"
	if auton_tasks[Team.AutonTasks.CROSSED_LINE]:
		_autonomous_tasks_label.text += "robot crossed to other side of field\n"


func _display_notes(notes:Array)->void:
	for note : String in notes:
		_notes_label.text += note + "\n"


func _update_score(scores:Array)->void:
	_expected_score_label.text = "Average Score: " + str(roundf(_get_sum(scores) / (2.0 * scores.size())))


func _get_sum(of:Array)->int:
	if of.size() > 0:
		var value : int = of[0]
		return value + _get_sum(of.slice(1))
	return 0
