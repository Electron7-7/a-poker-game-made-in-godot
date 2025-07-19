class_name Common extends Node

const _TICK_RATE     : int   = 70
const _TICK_INTERVAL : float = (1.0 / _TICK_RATE)

const _LABEL_WARNING : String = "[WARNING]\t"
const _LABEL_ERROR   : String = "[ERROR]\t"

static func PrintWarn(message : String) -> void:
    push_warning("%s%s", [_LABEL_WARNING, message])

static func PrintErr(message : String) -> void:
    push_error("%s%s", [_LABEL_ERROR, message])
