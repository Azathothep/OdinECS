package odinecs

import "core:fmt"
import "core:mem"

Position :: struct {
    x: f32,
    y: f32
}

main :: proc() {
    world := new_world();
    
    register_component(Position, world);

    for i := 0; i < 100; i += 1 {
        pos := Position{f32(i), f32(i) * 2};
        add_component(Position, &pos, world);
    }

    pos_components := get_components(Position, world);
    
    for i := 0; i < 100; i += 1 {    
        fmt.println("Position ", i, " = ", pos_components[i]);
    }

    destroy_world(world);
}