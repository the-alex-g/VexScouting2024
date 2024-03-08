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
	var auton_tasks : Dictionary = config.get_value(team_id, "auton", {
		Team.AutonTasks.CORNER_TRIBALL:false,
		Team.AutonTasks.SCORE_PRELOAD:false,
		Team.AutonTasks.TOUCH_BAR:false,
		Team.AutonTasks.PRELOAD_TO_OFFENSIVE_ZONE:false,
		Team.AutonTasks.CROSSED_LINE:false
	})
	var current_team_auton := team.get_auton()
	for task in current_team_auton:
		if current_team_auton[task]:
			auton_tasks[task] = true
	config.set_value(team_id, "auton", auton_tasks)
	# save notes
	var current_notes : Array = config.get_value(team_id, "notes", [])
	var new_notes := team.get_notes()
	new_notes.append_array(current_notes)
	config.set_value(team_id, "notes", _remove_duplicates(new_notes))


func _remove_duplicates(from:Array)->Array:
	var clean_array := []
	for i in from:
		if not clean_array.has(i):
			clean_array.append(i)
	return clean_array
