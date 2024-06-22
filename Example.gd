extends CanvasLayer
class_name Game


class CustomObject extends Object:
	var link_id : int = -1
	var position : Vector2i = Vector2i.ZERO
	
	func _init( _position : Vector2i ):
		position = _position
	
	func print_to_console():
		print( "  ", link_id, ": ", self, " pos: ", position )


var current_index : int = -1
var current_list : LinkedList.List = null
var list_array : Array[LinkedList.List] = []


func _ready():
	list_array.resize( 5 )
	build()


func build():
	for _n in get_children():
		remove_child( _n )
		_n.queue_free()
	
	var _pos_x = 0
	var _pos_y = 0
	for _list in list_array:
		if _list != null:
			_pos_y = 0
			var _list_name : Label = Label.new()
			add_child( _list_name )
			_list_name.position.x = _pos_x
			_list_name.position.y = _pos_y
			_list_name.text = "List\n%d" % _list.get_instance_id()
			if _list == current_list:
				_list_name.modulate = Color.BLACK
			_pos_y += 50
			
			var _iterator = _list.iterate()
			while _iterator >= 0:
				var _object : CustomObject = _list.get_object_by_id( _iterator )
				var _member : Label = Label.new()
				add_child( _member )
				_member.position.x = _pos_x
				_member.position.y = _pos_y
				_pos_y += 20
				_member.text = "%04d: %s" % [ _object.link_id, _object.position ]
				
				_iterator = _list.iterate( _iterator )
			
		_pos_x += 120
	
	_pos_y = 0
	var _title : Label = Label.new()
	add_child( _title )
	_title.position.x = _pos_x
	_title.position.y = _pos_y
	_title.text = "Links"
	_pos_y += 30
	
	for _link in LinkedList.List._list_links:
		var _label : Label = Label.new()
		add_child( _label )
		_label.position.x = _pos_x
		_label.position.y = _pos_y
		_pos_y += 20
		if _link.object != null:
			_label.text = "%04d: %s" % [ _link.id, _link.object.position ]
		else:
			_label.text = "%04d: empty" % _link.id
	
	_pos_x += 120
	_pos_y = 0
	
	_title = Label.new()
	add_child( _title )
	_title.position.x = _pos_x
	_title.position.y = _pos_y
	_title.text = "Trash"
	_pos_y += 30
	
	var _link = LinkedList.List._trash
	while _link != null:
		var _label : Label = Label.new()
		add_child( _label )
		_label.position.x = _pos_x
		_label.position.y = _pos_y
		_pos_y += 20
		_label.text = "%04d" % _link.id
		_link = _link.next
	
	_pos_x += 120
	_pos_y = 0
	
	var _instructions : Label = Label.new()
	add_child( _instructions )
	_instructions.position.x = _pos_x
	_instructions.position.y = _pos_y 
	_instructions.text = "1 to 5\n  Create/Select a list\nDel\n  Remove selected list\nSpace\n  Insert a sorted member\nHome\n  Insert a member in the beginning\nEnd\n  Insert a member in the end\nPageUp\n  Sustract the first member\nPageDown\n  Sustract the last member"


func _sort_by_position(
	_obj0 : CustomObject, 
	_obj1 : CustomObject
) -> bool:
	if _obj0.position.y > _obj1.position.y:
		return true
	if _obj0.position.y < _obj1.position.y:
		return false
	if _obj0.position.x > _obj1.position.x:
		return true
	return false


func print_iterated( _list : LinkedList.List ):
	print( "List: ", _list, "\n size: ", _list.size() )
	var _iterator : int = _list.iterate()
	while _iterator >= 0:
		var _object : CustomObject = _list.get_object_by_id( _iterator )
		_object.print_to_console()
		_iterator = _list.iterate( _iterator )


func _unhandled_input( _event ):
	if _event is InputEventKey:
		if _event.pressed:
			match _event.keycode:
				KEY_1:
					current_index = 0
					if list_array[current_index] == null:
						list_array[current_index] = LinkedList.List.new()
					current_list = list_array[current_index]
					build()
				
				KEY_2:
					current_index = 1
					if list_array[current_index] == null:
						list_array[current_index] = LinkedList.List.new()
					current_list = list_array[current_index]
					build()
				
				KEY_3:
					current_index = 2
					if list_array[current_index] == null:
						list_array[current_index] = LinkedList.List.new()
					current_list = list_array[current_index]
					build()
				
				KEY_4:
					current_index = 3
					if list_array[current_index] == null:
						list_array[current_index] = LinkedList.List.new()
					current_list = list_array[current_index]
					build()
				
				KEY_5:
					current_index = 4
					if list_array[current_index] == null:
						list_array[current_index] = LinkedList.List.new()
					current_list = list_array[current_index]
					build()
				
				KEY_DELETE:
					if current_list != null:
						var _iterator : int = current_list.iterate()
						while _iterator >= 0:
							var _object : CustomObject = current_list.get_object_by_id( _iterator )
							_object.free()
							_iterator = current_list.iterate( _iterator )
						current_list.free()
						current_list = null
						list_array[current_index] = null
						current_index = -1
						build()
				
				KEY_HOME:
					if current_list != null:
						var _object : CustomObject = CustomObject.new( Vector2i.ZERO )
						_object.link_id = current_list.push_front( _object )
						build()
				
				KEY_END:
					if current_list != null:
						var _object : CustomObject = CustomObject.new( Vector2i( 8, 8 ) )
						_object.link_id = current_list.push_back( _object )
						build()
				
				KEY_SPACE:
					if current_list != null:
						var _object : CustomObject = CustomObject.new( Vector2i( randi() % 8, randi() % 8 ) )
						_object.link_id = current_list.push_sorted( _object, _sort_by_position )
						build()
				
				KEY_PAGEUP:
					if current_list != null:
						var _object : CustomObject = current_list.pop_front()
						if _object:
							_object.free()
							build()
				
				KEY_PAGEDOWN:
					if current_list != null:
						var _object : CustomObject = current_list.pop_back()
						if _object:
							_object.free()
							build()
				
