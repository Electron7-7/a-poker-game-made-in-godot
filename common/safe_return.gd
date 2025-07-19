class_name SafeReturn extends Object

var _status : Error   = ERR_UNCONFIGURED
var _data   : Variant = null

func _init(status : Error = ERR_UNCONFIGURED, data : Variant = null):
    _status = status
    _data   = data

func is_ok() -> bool:
    return(_status == OK)

func get_status() -> Error:
    return _status

func get_data() -> Variant:
    return _data

func data_type() -> Variant.Type:
    return typeof(_data) as Variant.Type
