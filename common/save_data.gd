class_name SaveData extends Object

static var _sections : Dictionary[String, PackedStringArray] = {}
static var _values   : Dictionary[String, Variant] = {}

static func Init() -> void:
    _sections = {}
    _values = {}

static func _section_key(section : String, key : String) -> String:
    return "%s.%s" % [section, key]

static func _check_section_key(section : String, key : String = "") -> Error:
    if(!_sections.has(section)):
        Common.PrintErr("Requested section '%s' doesn't exist!" % section)
        return ERR_DOES_NOT_EXIST
    if(!key.is_empty() && !_sections.get(section).has(key)):
        Common.PrintErr("Requested key in section '%s' doesn't exist!" % section)
        return ERR_DOES_NOT_EXIST
    return OK

static func SetValue(section : String, key : String, value : Variant) -> void:
    if(!_sections.has(section)):
        Common.PrintWarn("Requested section '%s' doesn't exist. Creating it now." % section)
        _sections[section] = []
    _sections.get(section).append(key)
    _values[_section_key(section, key)] = value

static func GetValue(section : String, key : String) -> SafeReturn:
    if(_check_section_key(section, key) != OK):
        return SafeReturn.new(ERR_DOES_NOT_EXIST, null)
    return SafeReturn.new(OK, _values.get(_section_key(section, key)))
