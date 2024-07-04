package main
import "core:os"
import "core:io"
import "core:time"
import "core:encoding/json"
import "core:strconv"
import "core:strings"
import "core:fmt"

Note :: struct {
    contents: string,
    timestamp: i64,
}

List :: struct { }
New :: struct { contents: string }
Edit :: struct { note_index: uint, new_contents: string }
Help :: struct { }
Command :: union #no_nil { List, New, Edit, Help }


NotesLoadError :: enum {
    None,
    FileReadError,
    JsonParseError,
    AllocationError,
}

load_notes :: proc(base_dir: string) -> ([]Note, NotesLoadError) {
    notes := []Note{}
    notes_path, alloc_err := strings.concatenate([]string { base_dir, "/renoter_notes.json" })
    if alloc_err != .None {
        fmt.println("Allocation error")
        return notes, NotesLoadError.AllocationError
    }
    defer delete(notes_path)

    contents, success := os.read_entire_file_from_filename(notes_path)
    if !success {
        fmt.println("Error reading notes file")
        return notes, NotesLoadError.FileReadError
    }
    defer delete(contents)

    json_contents, err := json.parse(contents)
    if err != .None {
        fmt.println("Error decoding notes:", err)
        return notes, NotesLoadError.JsonParseError
    }
    defer json.destroy_value(json_contents)

    fmt.println(json_contents)
    return notes, NotesLoadError.None
}

list_notes :: proc() { }
new_note :: proc() { }
edit_note :: proc() { }

print_help :: proc() {
    fmt.println("Usage: <command> <arguments...>")
    fmt.println("Commands:")
    fmt.println("    list                               - List all notes")
    fmt.println("    new    <note_contents>             - Create a new note")
    fmt.println("    edit   <note_index> <new_contents> - Edit an existing note")
    fmt.println("    retire <note_index>                - Retire an existing note")
    fmt.println("    random                             - Print a random note")
    fmt.println("    help                               - Print this help message")
}

main :: proc() {
    env := os.environ()
    xdg_state_home: string
    for pair in env {
        list, err := strings.split(pair, "=")
        if err != .None {
            fmt.println("Allocation error")
            return
        }

        if list[0] == "XDG_STATE_HOME" {
            xdg_state_home = list[1]
        }
    }

    notes, err := load_notes(xdg_state_home)

    args := os.args
    command := parse_command(args)

    switch _ in command {
    case List: list_notes()
    case New: new_note()
    case Edit: edit_note()
    case Help: print_help()
    }
}

parse_command :: proc(arguments: []string) -> Command {
    if len(arguments) < 2 {
        return Help{}
    }

    program_name := arguments[0]
    command_name := arguments[1]

    switch command_name {
    case "list": return List{}
    case "new": return parse_new(arguments[1:])
    case "edit": return parse_edit(arguments[1:])
    case "help": return Help{}
    case:
        fmt.println("Unknown command:", command_name)
        return Help{}
    }
}

parse_new :: proc(arguments: []string) -> Command {
    if len(arguments) != 1 {
        fmt.println("Usage: new <contents>")
        return Help{}
    }

    return New{contents = arguments[0]}
}

parse_edit :: proc(arguments: []string) -> Command {
    if len(arguments) != 2 {
        fmt.println("Usage: edit <note_index> <new_contents>")
        return Help{}
    }

    note_index, ok := strconv.parse_uint(arguments[0], 10)
    if !ok {
        fmt.println("Invalid note index", arguments[0])
        return Help{}
    }

    return Edit{note_index = note_index, new_contents = arguments[1]}
}
