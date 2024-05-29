# simplescriptscroll.gd
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
extends EditorPlugin

enum {
	SCROLL_DEFAULT,
	SCROLL_MARGIN_LINES,
	SCROLL_MID_PAGE,
	SCROLL_JUMP_AT_END,
}

const SETTINGS = preload("res://addons/simplescriptscroll/settings.tscn")

var scroll_type := SCROLL_MARGIN_LINES
var scroll_margin_lines_up := 5
var scroll_margin_lines_down := 5


func _enter_tree() -> void:
	load_config()
	if scroll_type != SCROLL_DEFAULT:
		tool_script_scroll_set_enable(true)
	add_tool_menu_item("Simple Script Scroll Settings", _on_tool_menu_item_pressed)


func _exit_tree() -> void:
	if scroll_type != SCROLL_DEFAULT:
		tool_script_scroll_set_enable(false)
	remove_tool_menu_item("Simple Script Scroll Settings")


func load_config() -> void:
	var config := ConfigFile.new()
	config.load(get_editor_interface().get_editor_paths().get_config_dir().path_join("simplescriptscroll.cfg"))
	scroll_type = config.get_value("scroll", "type", SCROLL_MARGIN_LINES)
	scroll_margin_lines_up = config.get_value("scroll", "margin_lines_up", 5)
	scroll_margin_lines_down = config.get_value("scroll", "margin_lines_down", 5)


func save_config() -> void:
	var config := ConfigFile.new()
	config.set_value("scroll", "type", scroll_type)
	config.set_value("scroll", "margin_lines_up", scroll_margin_lines_up)
	config.set_value("scroll", "margin_lines_down", scroll_margin_lines_down)
	config.save(get_editor_interface().get_editor_paths().get_config_dir().path_join("simplescriptscroll.cfg"))


func tool_script_scroll_set_enable(enable : bool) -> void:
	if scroll_type == SCROLL_DEFAULT:
		enable = false
	if enable:
		var script_editor : ScriptEditor = get_editor_interface().get_script_editor()
		if not script_editor.editor_script_changed.is_connected(_on_editor_script_changed):
			script_editor.editor_script_changed.connect(_on_editor_script_changed)
		_on_editor_script_changed(null)
	else:
		var script_editor : ScriptEditor = get_editor_interface().get_script_editor()
		if script_editor.editor_script_changed.is_connected(_on_editor_script_changed):
			script_editor.editor_script_changed.disconnect(_on_editor_script_changed)
		for script in get_editor_interface().get_script_editor().get_open_script_editors():
			var codeedit = script.get_base_editor()
			if not codeedit is CodeEdit:
				continue
			codeedit.scroll_past_end_of_file = get_editor_interface().get_editor_settings().get("text_editor/behavior/navigation/scroll_past_end_of_file")
			if codeedit.caret_changed.is_connected(_on_codeedit_caret_changed):
				codeedit.caret_changed.disconnect(_on_codeedit_caret_changed)


func _on_editor_script_changed(_script : Script) -> void:
	var editor := get_editor_interface().get_script_editor().get_current_editor()
	if editor == null:
		return
	var codeedit = editor.get_base_editor()
	if codeedit == null or not codeedit is CodeEdit:
		return
	if not codeedit.caret_changed.is_connected(_on_codeedit_caret_changed):
		codeedit.caret_changed.connect(_on_codeedit_caret_changed.bind(codeedit))
	var end : int = codeedit.get_line_count()
	var page : int = codeedit.get_v_scroll_bar().page
	if end > page and page > 1:
		codeedit.scroll_past_end_of_file = true


func _on_codeedit_caret_changed(codeedit : CodeEdit) -> void:
	var line : int = codeedit.get_caret_line()
	var end : int = codeedit.get_line_count()
	var page : int = codeedit.get_v_scroll_bar().page
	if codeedit.is_dragging_cursor():
		return
	if end > page and page > 1:
		codeedit.scroll_past_end_of_file = true
	match scroll_type:
		SCROLL_DEFAULT:
			pass
		SCROLL_MARGIN_LINES:
			if line <= codeedit.scroll_vertical + scroll_margin_lines_up:
				codeedit.scroll_vertical = line - scroll_margin_lines_up
			if line >= codeedit.scroll_vertical + (page - scroll_margin_lines_down):
				codeedit.scroll_vertical = line - (page - scroll_margin_lines_down)
		SCROLL_MID_PAGE:
			if line >= codeedit.scroll_vertical + (page / 2):
				codeedit.scroll_vertical = line - (page / 2)
		SCROLL_JUMP_AT_END:
			if line >= end - 1:
				codeedit.scroll_vertical = line - ((page / 2) - (line - end))


func _on_tool_menu_item_pressed() -> void:
	var window = SETTINGS.instantiate()
	get_editor_interface().get_base_control().add_child(window)
	window.set_plugin(self)
