class_name TriangleHolder

var triangle1: Triangle
var triangle2: Triangle
var mark: String

func _init(mark, triangle1, triangle2):
	self.mark = mark
	self.triangle1 = triangle1
	self.triangle2 = triangle2


func _to_string():
	return "[%s, %s]" % [self.triangle1, self.triangle2]
