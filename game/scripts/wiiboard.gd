extends Node
@export_subgroup("Connection")
@export var host = "127.0.0.1"
@export var port = 42069
var try_connect = false
var connect_timeout = 0
var connect_retry_sec = 5
var connect_timeout_sec = 5
var client = StreamPeerTCP.new()
var status = null
var weight = 75.0
var vector_scale_x = 2.5
var vector_scale_y = 2.5
var send_half = false
var corners_buffer = []
var buffer_limit = 100

var jump_force_pct = 1.25
var time_since_force_spike = 1
var time_force_spike_timeout = 0.2
var jump_air_force_pct = 0.75
signal boardJump

func parse_data(data: String, delta: float):
	var corners_str = data.split(";")
	if len(corners_str) != 4:
		print("got borked data, skipping!")
		return
	
	var corners = []
	for corner in corners_str:
		corners.append(corner.to_float())
	corners_buffer.push_front(corners)
	if len(corners_buffer) > buffer_limit:
		corners_buffer.pop_back()
	
	var corner_sum = 0
	for corner in corners:
		corner_sum = corner_sum + corner
	
	if corner_sum > (weight * jump_force_pct):
		time_since_force_spike = 0
	else:
		time_since_force_spike = time_since_force_spike + delta

	if corner_sum < (weight * jump_air_force_pct) && time_since_force_spike < time_force_spike_timeout:
		boardJump.emit()
		time_since_force_spike = time_force_spike_timeout

func calibrate_weight():
	print("Recalibrating Weight...")
	var corners = average_corners(20)
	var new_weight = corners.reduce(func(accum, number): return accum + number, 0)
	if new_weight < 20:
		print("Weight below 20kg. Not using new calibration data.")
	else:
		weight = new_weight
		print("New Weight: " + str(weight))

func average_corners(last_x: int=0):
	if len(corners_buffer) == 0:
		return [0,0,0,0]
	var avg_corners = []
	for corner in range(4):
		var value = 0
		for corners_ids in range(0, min(len(corners_buffer), last_x if last_x != 0 else len(corners_buffer))):
			value = value + corners_buffer[corners_ids][corner]
		value = value / min(len(corners_buffer), last_x)
		avg_corners.append(value)
	
	return avg_corners

# Switches between sending x and y data since you can't send both in the same frame
func _physics_process(delta: float) -> void:
	send_half = !send_half
	var corners = average_corners(2)
	if send_half:
		var x_velocity = (corners[0] + corners[1] - corners[2] - corners[3]) / weight * vector_scale_x
		
		var x_event = InputEventAction.new()
		x_event.strength = min(abs(x_velocity),1)
		x_event.pressed = true
		x_event.action = "move_right" if x_velocity >= 0 else "move_left"
		
		Input.parse_input_event(x_event)
	else:
		var y_velocity = (corners[0] - corners[1] + corners[2] - corners[3]) / weight * vector_scale_y
		
		var y_event = InputEventAction.new()
		y_event.strength = min(abs(y_velocity),1)
		y_event.pressed = true
		y_event.action = "move_forward" if y_velocity >= 0 else "move_back"
		Input.parse_input_event(y_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	client.poll()
	var next_status = client.get_status()
	
	if next_status != status:
		match next_status:
			client.STATUS_NONE:
				print("Wiiboard not Connected.")
				corners_buffer = [] 
				try_connect = true
			client.STATUS_ERROR:
				print("Wiiboard TCPClient error. retrying in " + str(connect_retry_sec) + " seconds")
				corners_buffer = []
				try_connect = true
			client.STATUS_CONNECTING:
				print("Wiiboard Connecting...")
			client.STATUS_CONNECTED:
				print("Wiiboard Connected!")
	
	status = next_status
	
	if try_connect:
		if connect_timeout > 0:
			connect_timeout = connect_timeout - delta

		if connect_timeout <= 0:
			connect_to_server()
			try_connect = false
			connect_timeout = connect_timeout_sec
			
	if status == client.STATUS_CONNECTED:
		if client.get_available_bytes() > 0:
			parse_data(client.get_utf8_string(), delta)
	
	if Input.is_action_just_pressed("rekalibrate"):
		calibrate_weight()

func connect_to_server():
	print("Connecting to server")
	client = StreamPeerTCP.new()
	status = null
	if client.connect_to_host(host, port) != OK:
		print("Error connecting to Host")
 
