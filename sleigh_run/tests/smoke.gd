extends SceneTree

var fails := 0
func check(c: bool, msg: String) -> void:
	print(("PASS  " if c else "FAIL  ") + msg)
	if not c: fails += 1

func frames(n: int) -> void:
	for i in n: await physics_frame

func _initialize() -> void:
	run()

func run() -> void:
	var G = root.get_node("Game")
	var main: Node = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await frames(3)
	var train = main.get_node("Train")
	check(train.segments.size() == 4, "train has 3 reindeer + sleigh")
	check(is_equal_approx(train.segments[0].position.y, 300.0), "segments start at y=300 (script ran _ready/reset)")
	check(train.segments[0].get_node("Sprite2D").row == 1, "lead reindeer uses red-nose row")
	check(G.state == G.State.TITLE, "game starts on title screen")

	G.start()
	await frames(2)
	G.speed = 0.0
	check(G.running, "start() -> playing")
	# steering + follow
	Input.action_press("move_down")
	await frames(30)
	Input.action_release("move_down")
	var lead_y: float = train.segments[0].position.y
	var s2_y: float = train.segments[1].position.y
	var sl_y: float = train.segments[3].position.y
	check(lead_y > 340.0, "lead moves down (y=%.0f)" % lead_y)
	check(s2_y < lead_y and s2_y > 300.0, "follower trails lead (y=%.0f < %.0f)" % [s2_y, lead_y])
	check(sl_y < s2_y, "sleigh trails further (y=%.0f)" % sl_y)
	# up clamps
	Input.action_press("move_up"); await frames(120); Input.action_release("move_up")
	check(train.segments[0].position.y >= train.y_min - 0.1, "lead clamped at y_min")

	# pickup
	var pk = load("res://scenes/pickups/present_pickup.tscn").instantiate()
	main.get_node("Spawner").add_child(pk); pk.global_position = train.segments[0].global_position
	await frames(4)
	check(G.presents == 1, "present pickup adds to inventory (presents=%d)" % G.presents)

	# drop onto chimney -> combo
	train.reset(); await frames(2); G.speed = 0.0
	var house = load("res://scenes/world/house.tscn").instantiate()
	main.get_node("HouseSpawner").add_child(house)
	house.global_position = Vector2(train.segments.back().global_position.x - 56.0, 690.0)
	Input.action_press("drop_present"); await frames(2); Input.action_release("drop_present")
	check(G.presents == 0, "drop consumes a present")
	await frames(60)
	check(G.combo == 1 and G.multiplier == 1.5, "landing on chimney: combo=%d mult=%.1f" % [G.combo, G.multiplier])
	check(G.score >= 150.0, "delivery scored (score=%.0f)" % G.score)

	# missed drop breaks combo (remove the delivered house first)
	house.queue_free(); await frames(2)
	G.add_present(); G.speed = 0.0
	Input.action_press("drop_present"); await frames(2); Input.action_release("drop_present")
	await frames(70)
	check(G.combo == 0 and G.multiplier == 1.0, "present hitting the ground breaks combo")

	# house passing without delivery breaks combo
	G.combo = 3; G.multiplier = 2.5
	var h2 = load("res://scenes/world/house.tscn").instantiate()
	main.get_node("HouseSpawner").add_child(h2); h2.global_position = Vector2(100, 690)
	G.speed = 0.0; await frames(3)
	check(G.combo == 0, "house passing undelivered breaks combo")

	# obstacle collision ends game
	var bird = load("res://scenes/obstacles/bird.tscn").instantiate()
	main.get_node("Spawner").add_child(bird); bird.global_position = train.segments[0].global_position
	await frames(4)
	check(G.state == G.State.GAME_OVER, "obstacle collision -> game over")

	# restart clears the world
	G.start(); await frames(3)
	check(main.get_node("Spawner").get_child_count() == 0, "restart clears spawned objects")
	check(is_equal_approx(train.segments[0].position.y, 300.0), "restart resets train")
	# spawners produce things
	G.speed = Game_speed_fix()
	await frames(240)
	var spawned: int = main.get_node("Spawner").get_child_count() + main.get_node("HouseSpawner").get_child_count()
	check(spawned > 0, "spawners create objects over time (%d alive)" % spawned)
	check(root.get_node("Music").tracks.size() >= 1, "music tracks loaded (%d)" % root.get_node("Music").tracks.size())
	check(root.get_node("Sfx").sounds.size() == 4, "4 sfx loaded")
	# soak test: 40 simulated seconds of random play must not error
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	G.start(); await frames(2)
	var restarts := 0
	for i in 2400:
		if i % 20 == 0:
			Input.action_release("move_up"); Input.action_release("move_down")
			match rng.randi() % 3:
				0: Input.action_press("move_up")
				1: Input.action_press("move_down")
		if i % 45 == 0:
			G.add_present(); Input.action_press("drop_present")
		elif i % 45 == 2:
			Input.action_release("drop_present")
		if G.state == G.State.GAME_OVER:
			restarts += 1; G.start()
		await physics_frame
	print("soak finished: %d restarts, score=%.0f" % [restarts, G.score])
	print("\nFAILS: %d" % fails)
	quit(fails)

func Game_speed_fix() -> float: return 420.0
