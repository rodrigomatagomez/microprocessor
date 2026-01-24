    .data
x:  .word 0          # reserva una palabra en memoria

    .text
    .globl main
main:
    la   t0, x        # t0 = dirección de x
    addi t1, x0, 7    # dato = 7
    sw   t1, 0(t0)    # guarda 7 en memoria
    lw   t2, 0(t0)    # lee 7 desde memoria

finish:
    jal  x0, finish  # se queda aquí
