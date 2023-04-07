class_name TriangleQueue


var head: TriangleQueueNode = null
var tail: TriangleQueueNode = null


func add(data: Triangle) -> void:
	var node = TriangleQueueNode.new(data)
	if head == null:
		head = node
		tail = node
	else:
		tail.next = node
		tail = node

func pop_front() -> Triangle:
	if head == null:
		return null

	var node = head
	head = head.next
	if head == null:
		tail = null

	return node.data

func walk() ->TriangleQueueIterator:
	return TriangleQueueIterator.new(head, tail)

func is_empty() -> bool:
	return head == null

func _to_string():
	var s = ""
	for t in walk():
		s += " " + str(t.plate_index)
	return s


class TriangleQueueNode:
	var data: Triangle
	var next: TriangleQueueNode = null

	func _init(data: Triangle) -> void:
		self.data = data


class TriangleQueueIterator:
	var head: TriangleQueueNode
	var current: TriangleQueueNode
	var tail: TriangleQueueNode

	func _init(head: TriangleQueueNode, tail: TriangleQueueNode):
		self.head = head
		self.current = head
		self.tail = tail
	
	func _iter_init(arg) -> bool:
		current = head
		return current != null

	func _iter_next(arg) -> bool:
		current = current.next
		return current != null

	func _iter_get(arg) ->Triangle:
		return current.data
