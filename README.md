# Laser_Triangulation
Code files for Laser Triangulation Measurement based on Xilinx XC6SLX16-CSG324 EVM board

File description:

Written in Verilog format.

Overall function: Drive the laser with current control  based on SPI DAC & Drive the image sensor and catch image data captured by ADS807 & Transmit the image data to PC on UART for further analysis.

UART_TOP.v: top module file.

SYS_RST.v: to generate system reset signal and adc clock signal.

CMOS_DRIVE_LFL1402.v: to generate clock signals for linear image sensor LFL1402.

my_uart_rx.v: to receive signals from UART port, from PC.

UART_CLOCK.v: to generate UART RX&TX clock signals.

UART_PC.v: to transmit signals through UART port, to send image data to PC.

UART_APPLY.v: to address the asynchronous problem between ADC output speed and UART transmit speed.

SPI_Master_User.v: to generate SPI output signals to DAC to drive the laser.

UART.ucf: user pin constraint file.

Laser_Triangulation.xise: project file.

Update by Lu on 3.20.2017.
