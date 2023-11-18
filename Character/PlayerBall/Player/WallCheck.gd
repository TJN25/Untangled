extends CharacterBody2D

var wall_colliding_left: bool = false
var wall_colliding_right: bool = false
var collider_cooldown_left: float = 0
var collider_cooldown_right: float = 0
var wall_direction: int = 0
var ledge_clipped: bool = false

func _physics_process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var right_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(50, 15), collision_mask, [self])
	var right_query_high = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(30, -15), collision_mask, [self])
	var right_query_short = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(30, 30), collision_mask, [self])
	var right_result = space_state.intersect_ray(right_query)
	var right_result_high = space_state.intersect_ray(right_query_high)
	var right_result_short = space_state.intersect_ray(right_query_short)
	if right_result and collider_cooldown_right > 0:
		wall_colliding_right = true
	elif right_result_high:
		wall_colliding_right = true
	elif right_result:
		collider_cooldown_right += delta
	else:
		collider_cooldown_right = 0
		wall_colliding_right = false
	var left_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(-50, 15), collision_mask, [self])
	var left_result = space_state.intersect_ray(left_query)
	var left_query_high = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(-30, -15), collision_mask, [self])
	var left_result_high = space_state.intersect_ray(left_query_high)
	var left_query_short = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(-30, 30), collision_mask, [self])
	var left_result_short = space_state.intersect_ray(left_query_short)
	if left_result_short:
		wall_direction = 1
	elif right_result_short:
		wall_direction = -1
	else:
		wall_direction = 0
	if (left_result_short and not left_result_high) or (right_result_short and not right_result_high):
		ledge_clipped = true
	else:
		ledge_clipped = false
	if left_result and collider_cooldown_left > 0.05:
		wall_colliding_left = true
	elif left_result_high:
		wall_colliding_left = true
	elif left_result:
		collider_cooldown_left += delta
	else:
		collider_cooldown_left = 0
		wall_colliding_left = false
