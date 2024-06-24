package odinecs

import "core:fmt"

World :: struct {
    tables: [dynamic]Table,
}

new_world :: proc() -> ^World {
    fmt.println("creating new world...");

    world := new(World);

    world.tables = make([dynamic]Table);

    fmt.println("new world created");

    return world;
}

destroy_world :: proc(world: ^World) {
    fmt.println("destroying world...");

    for i := 0; i < len(world.tables); i += 1 {
        free(world.tables[i].data);
    }
    
    delete(world.tables);
    free(world);

    fmt.println("world destroyed");
}