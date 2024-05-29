# settings.gd
# This file is part of: SimpleScriptScroll
# Copyright (c) 2024 IcterusGames
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions: 
#
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
@tool
extends Window

var _plugin : EditorPlugin = null

@onready var _style_button: OptionButton = %StyleButton
@onready var _margin_up_spin: SpinBox = %MarginUpSpin
@onready var _margin_down_spin: SpinBox = %MarginDownSpin
@onready var _key_vim_check: CheckBox = %KeyVimCheck


func set_plugin(plugin : EditorPlugin) -> void:
	_plugin = plugin
	_style_button.clear()
	_style_button.add_item("None", _plugin.SCROLL_NONE)
	_style_button.add_item("Margin Lines", _plugin.SCROLL_MARGIN_LINES)
	_style_button.add_item("Middle Page", _plugin.SCROLL_MID_PAGE)
	_style_button.add_item("Jump at end", _plugin.SCROLL_JUMP_AT_END)
	_style_button.select(_style_button.get_item_index(_plugin.scroll_type))
	_margin_up_spin.value = _plugin.scroll_margin_lines_up
	_margin_down_spin.value = _plugin.scroll_margin_lines_down
	_margin_up_spin.editable = _plugin.scroll_type == _plugin.SCROLL_MARGIN_LINES
	_margin_down_spin.editable = _plugin.scroll_type == _plugin.SCROLL_MARGIN_LINES
	_key_vim_check.button_pressed = _plugin.keyvim_style_enabled


func _on_style_button_item_selected(index: int) -> void:
	var id = _style_button.get_item_id(index)
	_margin_up_spin.editable = id == _plugin.SCROLL_MARGIN_LINES
	_margin_down_spin.editable = id == _plugin.SCROLL_MARGIN_LINES
	_plugin.scroll_type = id
	_plugin.tool_script_scroll_set_enable(true)


func _on_margin_up_spin_value_changed(value: float) -> void:
	_plugin.scroll_margin_lines_up = value


func _on_margin_down_spin_value_changed(value: float) -> void:
	_plugin.scroll_margin_lines_down = value


func _on_key_vim_check_toggled(toggled_on: bool) -> void:
	_plugin.keyvim_style_enabled = toggled_on
	_plugin.tool_script_scroll_set_enable(true)


func _on_about_rich_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_close_requested() -> void:
	_plugin.save_config()
	queue_free()
