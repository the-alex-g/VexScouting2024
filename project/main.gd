extends Control

const CONFIG_PATH := "res://team_record.cfg"

@onready var _teams : Array[Team] = [
	%RedTeam1,
	%RedTeam2,
	%BlueTeam1,
	%BlueTeam2
]
@onready var _red_team_score_field : LineEdit = %RedTeamScore
@onready var _blue_team_score_field : LineEdit = %BlueTeamScore
@onready var _lookup_results_label : Label = $ScrollContainer/VBoxContainer/LookupResults


func _on_save_button_pressed()->void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	for team in _teams:
		_save_team(team, config)
		team.clear()
	
	config.save(CONFIG_PATH)


func _save_team(team:Team, config:ConfigFile)->void:
	var team_id : String = team.team_id
	# save scores
	var team_scores : Array = config.get_value(team_id, "scores", [])
	if team.name.begins_with("Red"):
		team_scores.append(int(_red_team_score_field.text))
	else:
		team_scores.append(int(_blue_team_score_field.text))
	config.set_value(team_id, "scores", team_scores)
	# save auton
	config.set_value(team_id, "auton", team.get_auton())
	# save notes
	var current_notes : Array = config.get_value(team_id, "notes", [])
	var new_notes := team.get_notes()
	for note : String in new_notes:
		if current_notes.has(note):
			current_notes.erase(note)
	new_notes.append_array(current_notes)
	config.set_value(team_id, "notes", new_notes)


func _on_team_lookup_text_changed(new_text:String)->void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	if not config.has_section(new_text):
		_lookup_results_label.text = "Team Not Found"
	else:
		# display average score
		var scores : Array = config.get_value(new_text, "scores", [])
		var average_score : int = roundf(_get_sum(scores) / (2.0 * scores.size()))
		_lookup_results_label.text = "Average Score: " + str(average_score)
		_lookup_results_label.text += "\n\nAutononous Tasks:\n"
		var auton_tasks : Dictionary = config.get_value(new_text, "auton", {})
		if auton_tasks[Team.AutonTasks.CORNER_TRIBALL]:
			_lookup_results_label.text += "triball removed from corner\n"
		if auton_tasks[Team.AutonTasks.SCORE_PRELOAD]:
			_lookup_results_label.text += "preload scored in goal\n"
		if auton_tasks[Team.AutonTasks.TOUCH_BAR]:
			_lookup_results_label.text += "touched climb bar\n"
		if auton_tasks[Team.AutonTasks.PRELOAD_TO_OFFENSIVE_ZONE]:
			_lookup_results_label.text += "preload put in offensive zone\n"
		if auton_tasks[Team.AutonTasks.CROSSED_LINE]:
			_lookup_results_label.text += "robot crossed to other side of field\n"
		_lookup_results_label.text += "\nNotes:\n"
		for note : String in config.get_value(new_text, "notes", []):
			_lookup_results_label.text += note + "\n"


func _get_sum(of:Array)->int:
	if of.size() > 0:
		var value : int = of[0]
		return value + _get_sum(of.slice(1))
	return 0
