`ifndef MAC_DEFS_SVH
`define MAC_DEFS_SVH

`define DATA_WIDTH 32

// El acumulador crece automáticamente: (Bits de entrada * 2) + 8 de guarda
`define ACC_WIDTH  ((`DATA_WIDTH * 2) + 8) 

// Limites Calculados Dinámicamente
// 1 << (32-1) es igual a 2^31. Le restamos 1 para el máximo positivo.
`define MAX_POS    ((1 << (`DATA_WIDTH - 1)) - 1)

// El negativo es -(2^31)
`define MAX_NEG    (-(1 << (`DATA_WIDTH - 1)))

// Definimos que un número "pequeño" usa la mitad de los bits
`define SMALL_WIDTH (`DATA_WIDTH / 2) // el límite de 16 bits, 32,767

// THRESH_P = Límite positivo de la mitad de los bits
`define THRESH_P   ((1 << (`SMALL_WIDTH - 1)) - 1)

// THRESH_N = Límite negativo de la mitad de los bits
`define THRESH_N   (-(1 << (`SMALL_WIDTH - 1)))

`endif