package mac_pkg;
    // Clase Base: Generador Random
    class random_gen;
        rand bit signed [`DATA_WIDTH-1:0] a, b;
        constraint data_range { 
            a inside {[`MAX_NEG : `MAX_POS]}; 
            b inside {[`MAX_NEG : `MAX_POS]}; 
        }
    endclass
    
    // Clase para Sanity (Test 1, 2, 3)
    class random_gen_small extends random_gen;
        constraint data_range { 
            a inside {[`THRESH_N : `THRESH_P]}; 
            b inside {[`THRESH_N : `THRESH_P]}; 
        }
    endclass

    // Clase para Corners (Test 4, 5) Distribución Ponderada
    class random_gen_corners extends random_gen;
        constraint c_zeros { 
            a dist {
                0                          := 10, // Cero
                `MAX_POS                   := 10, // Límite positivo
                `MAX_NEG                   := 10, // Límite negativo
                `THRESH_P                  := 10, // Justo el borde de "small" positivo
                `THRESH_N                  := 10, // Justo el borde de "small" negativo
                [1 : `THRESH_P-1]          :/ 10, // Rango pos_small
                [`THRESH_P+1 : `MAX_POS-1] :/ 10, // Rango pos_large
                [`THRESH_N+1 : -1]         :/ 15, // neg_small
                [`MAX_NEG+1 : `THRESH_N-1] :/ 15  // neg_large
            };

            b dist {
                0                          := 10,
                `MAX_POS                   := 10,
                `MAX_NEG                   := 10,
                `THRESH_P                  := 10,
                `THRESH_N                  := 10,
                [1 : `THRESH_P-1]          :/ 10,
                [`THRESH_P+1 : `MAX_POS-1] :/ 10,
                [`THRESH_N+1 : -1]         :/ 15,
                [`MAX_NEG+1 : `THRESH_N-1] :/ 15
            };
	    // := le da el peso total al valor
        // :/ reparte el peso entre todo el rango
        }
    endclass
endpackage
