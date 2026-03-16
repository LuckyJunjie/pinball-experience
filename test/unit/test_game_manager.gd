# Unit Tests - GameManager (uses autoload)
extends GutTest

var gm: Node = null

func before_each():
	gm = get_node_or_null("/root/GameManager")
	assert_not_null(gm, "GameManager autoload should exist")
	# Reset state for isolated tests
	gm.status = gm.Status.PLAYING
	gm.round_score = 0
	gm.total_score = 0
	gm.multiplier = 1
	gm.rounds = 3
	gm.reset_zone_tracking()

# ============ add_score ============

func test_add_score_only_when_playing():
	gm.status = gm.Status.WAITING
	gm.add_score(1000)
	assert_eq(gm.round_score, 0, "Should not add score when WAITING")

	gm.status = gm.Status.PLAYING
	gm.round_score = 0
	gm.add_score(1000)
	assert_eq(gm.round_score, 1000, "Should add score when PLAYING")

func test_add_score_capped_at_max():
	gm.status = gm.Status.PLAYING
	gm.round_score = gm.MAX_SCORE - 500
	gm.add_score(1000)
	assert_eq(gm.round_score, gm.MAX_SCORE, "round_score should be capped")

# ============ increase_multiplier ============

func test_increase_multiplier_capped_at_six():
	gm.status = gm.Status.PLAYING
	gm.multiplier = 6
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 6, "Multiplier should not exceed 6")

func test_increase_multiplier_increments():
	gm.status = gm.Status.PLAYING
	gm.multiplier = 1
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 2, "Multiplier should increment")
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 3, "Multiplier should increment again")

func test_increase_multiplier_ignored_when_not_playing():
	gm.status = gm.Status.WAITING
	gm.multiplier = 1
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 1, "Should not increase when not playing")

# ============ register_zone_ramp_hit ============

func test_register_zone_ramp_hit_increments():
	gm.status = gm.Status.PLAYING
	gm.reset_zone_tracking()
	gm.register_zone_ramp_hit("android_acres")
	assert_eq(gm.zone_ramp_hits["android_acres"], 1, "First hit")
	gm.register_zone_ramp_hit("android_acres")
	assert_eq(gm.zone_ramp_hits["android_acres"], 2, "Second hit")

func test_register_zone_ramp_hit_increases_multiplier_every_five():
	gm.status = gm.Status.PLAYING
	gm.multiplier = 1
	gm.reset_zone_tracking()
	for i in range(5):
		gm.register_zone_ramp_hit("flutter_forest")
	assert_eq(gm.multiplier, 2, "5 ramp hits should increase multiplier")

# ============ display_score ============

func test_display_score_returns_round_plus_total():
	gm.round_score = 500
	gm.total_score = 1000
	assert_eq(gm.display_score(), 1500, "display_score = round + total")
