@tool
@abstract
extends RefCounted
class_name Utils


static func ensure_connected(p_signal: Signal, callable: Callable, flags: int = 0) -> void:
	if not p_signal.is_connected(callable):
		p_signal.connect(callable, flags)


static func ensure_disconnected(p_signal: Signal, callable: Callable) -> void:
	if p_signal && p_signal.get_object() && p_signal.is_connected(callable):
		p_signal.disconnect(callable)


static func hashi_range(p_seed: Variant, from: int, to: int) -> int:
	if from == to:
		return from
	
	var mn := mini(from, to)
	var mx := maxi(from, to)
	var bound := mx - mn + 1
	
	return hash(p_seed) % bound + mn


static func hashf_range(p_seed: Variant, from: float, to: float) -> float:
	return float(hash(p_seed) & 0xffffff) / float(0xffffff) * (from - to) + to


static func hash_pick_random(p_seed: Variant, array: Variant) -> Variant:
	return array[hashi_range(p_seed, 0, array.size() - 1)]


static func hash_pick_random_weighted(p_seed: Variant, array: Variant, weights: PackedFloat32Array) -> Variant:
	var total: float = 0.0
	for i in array.size():
		total += weights[i] if i < weights.size() else 1.0
	
	var roll := hashf_range(p_seed, 0.0, total)
	for i in array.size():
		roll -= weights[i] if i < weights.size() else 1.0
		if roll <= 0.0:
			return array[i]
	
	return array[0]
