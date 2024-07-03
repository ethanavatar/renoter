package main
import "core:os"
import "core:io"
import "core:time"
import "core:encoding/json"
import "core:strconv"
import "core:fmt"

Note :: struct {
    contents: string,
    timestamp: i64,
}

Dump :: struct { }
New :: struct { contents: string }
Edit :: struct { note_index: uint, new_contents: string }
Help :: struct { }
Command :: union #no_nil { Dump, New, Edit, Help }

dump_notes :: proc() {
}
new_note :: proc() {
}
edit_note :: proc() {
}

print_help :: proc() {
    fmt.println("Usage: <command> <arguments...>")
    fmt.println("Commands:")
    fmt.println("    dump                               - Dump all notes")
    fmt.println("    new    <note_contents>             - Create a new note")
    fmt.println("    edit   <note_index> <new_contents> - Edit an existing note")
    fmt.println("    retire <note_index>                - Retire an existing note")
    fmt.println("    random                             - Print a random note")
    fmt.println("    help                               - Print this help message")
}

main :: proc() {
    args := os.args
    command := parse_command(args)

    switch _ in command {
    case Dump: dump_notes()
    case New: new_note()
    case Edit: edit_note()
    case Help: print_help()
    }
}

parse_command :: proc(arguments: []string) -> Command {
    if len(arguments) < 2 {
        fmt.println("Usage: <command> <arguments...>")
        return Help{}
    }

    program_name := arguments[0]
    command_name := arguments[1]

    switch command_name {
    case "dump": return Dump{}
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
