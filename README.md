# Relógio de Xadrez em VHDL

Este projeto implementa um relógio de xadrez utilizando a linguagem VHDL. O sistema gerencia o tempo de jogo de dois jogadores e exibe os tempos restantes em um display.

## Funcionalidades

- **Gerenciamento de tempo**: Cada jogador possui um contador independente que decremente o tempo restante.
- **Máquina de estados finitos (FSM)**: Controla as transições entre os estados de inatividade, turno de cada jogador e estados de vitória.
- **Detecção de borda**: Utilizada para identificar quando um jogador pressiona seu botão para alternar a vez.
- **Display de 7 segmentos**: Exibe os minutos e segundos restantes para cada jogador.

## Estrutura do Código

- **`relogio_xadrez.vhd`**: Define a lógica principal do relógio de xadrez, incluindo a FSM e a interface com os temporizadores e o display.
- **`temporizador.vhd`**: Implementa um contador que decremente o tempo de cada jogador e fornece a separação de minutos e segundos para exibição.

## Como Usar

Este projeto pode ser sintetizado e testado em uma FPGA, como a Nexys A7, utilizando ferramentas como Xilinx Vivado. Certifique-se de mapear corretamente os botões e o display conforme o hardware disponível.

## Dependências

- Biblioteca IEEE (`std_logic_1164` e `numeric_std`)
- FPGA compatível com displays de 7 segmentos
