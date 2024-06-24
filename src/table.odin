package odinecs

import "core:fmt"
import "core:mem"

Table :: struct {
    type: typeid,
    count: int,
    data: rawptr,
    capacity: int
}

register_component :: proc($T: typeid, world: ^World) {
    fmt.println("registering component of type ", type_info_of(T), "...");

    table := get_table(T, world);
    if (table != nil) {
        return;
    }

    create_table(T, world);

    fmt.println("component registered");
}

create_table :: proc($T: typeid, world: ^World ) {
    fmt.println("creating table of type ", type_info_of(T), "...");
    
    new_data, err := mem.alloc(size_of(T));
    if (err != mem.Allocator_Error.None) {
        fmt.println("Couldn't create table, allocator error: ", err);
        return;
    }

    new_table := Table{T, 0, new_data, 1}

    append(&(world.tables), new_table)

    fmt.println("table created");
}

add_component :: proc($T: typeid, data: ^T, world: ^World) -> bool {
    //fmt.println("adding component of type ", type_info_of(T), "...");
    
    table := get_table(T, world);
    if (table == nil) {
        fmt.println("component couldn't be added: table does not exist");
        return false ;
    }

    add_to_table(table, data);
    //fmt.println("component data added");

    return true;
}

add_to_table :: proc(table: ^Table, data: rawptr) {
    //fmt.println("adding component data to table...");

    data_size := size_of(table.type);
    
    cur_table_size := data_size * table.count;

    if (table.count < table.capacity) {
        
        mem.copy(&(([^]byte)(table.data)[cur_table_size]), data, data_size);
        table.count += 1;
        return;
    }

    new_table_size := cur_table_size * 2;

    new_table_ptr, err := mem.alloc(new_table_size);
    if (err != mem.Allocator_Error.None) {
        fmt.println("Couldn't add to table, allocator error: ", err);
        return;
    }

    mem.copy(new_table_ptr, table.data, cur_table_size);
    mem.copy(&(([^]byte)(new_table_ptr)[cur_table_size]), data, data_size);

    if (table.data != nil) {
        free(table.data);
    }

    table.data = new_table_ptr;
    table.capacity = new_table_size / data_size;

    fmt.println("Reallocated table for capacity ", table.capacity);

    table.count += 1;
}

get_components :: proc($T: typeid, world: ^World) -> [^]T {
    table := get_table(T, world);
    if (table == nil) {
        return nil;
    }

    return ([^]T)(table.data);
}

get_table :: proc($T: typeid, world: ^World) -> ^Table {
    for i := 0; i < len(world.tables); i += 1 {
        if (world.tables[i].type == T) {
            return &(world.tables[i]);
        }
    }
    
    return nil;
}