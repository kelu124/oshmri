//!
//! \file       main.c
//! \author     Abdelrahman Ali
//! \date       2024-01-20
//!
//! \brief      adc dac vga main entry.
//!

//---------------------------------------------------------------------------
// INCLUDES
//--------------------------------------------------------------------------
#include "adc/adc.h"

//---------------------------------------------------------------------------
// MAIN FUNCTION
//---------------------------------------------------------------------------

int main()
{
    stdio_init_all();
    pio_lo_init();
    pico_adc_init();
    adc_max_gpio_init();
    while (true)
    {
        adc();
        sleep_ms(1000);
    }
}
