cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/../pico-sdk/pico_sdk_init.cmake)

project(pio_adc)

pico_sdk_init()

add_executable(pio_adc)

pico_generate_pio_header(pio_adc ${CMAKE_CURRENT_LIST_DIR}/adc/adc.pio)

target_sources(pio_adc PRIVATE ${CMAKE_CURRENT_LIST_DIR}/main.c ${CMAKE_CURRENT_LIST_DIR}/adc/adc.h ${CMAKE_CURRENT_LIST_DIR}/adc/adc.c)

target_link_libraries(pio_adc PRIVATE pico_stdlib hardware_pio hardware_adc hardware_clocks hardware_gpio)
pico_add_extra_outputs(pio_adc)

pico_enable_stdio_usb(pio_adc 1)
pico_enable_stdio_uart(pio_adc 0)