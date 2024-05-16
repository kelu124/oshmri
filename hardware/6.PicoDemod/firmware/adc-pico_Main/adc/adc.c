//!
//! \file       adc.c
//! \author     Abdelrahman Ali
//! \date       2024-04-28
//!
//! \brief      adc pio.
//!

//---------------------------------------------------------------------------
// INCLUDES
//---------------------------------------------------------------------------

#include "adc.h"

#include "adc.pio.h"

//---------------------------------------------------------------------------
// GLOBAL VARIABLES
//---------------------------------------------------------------------------

PIO pio_lo;
uint sm_lo_q;
uint sm_lo_i;
uint offset_lo_q;
uint offset_lo_i;
uint8_t trigger;
uint8_t in_ch;

float adc0Buf[SAMPLE_COUNT];
float adc1Buf[SAMPLE_COUNT];
float douta[SAMPLE_COUNT];
float doutb[SAMPLE_COUNT];

//---------------------------------------------------------------------------
// LO INIT FUNCTION
//---------------------------------------------------------------------------

void pio_lo_init()
{
    pio_lo = pio0;
    sm_lo_q = pio_claim_unused_sm(pio_lo, true);
    offset_lo_q = pio_add_program(pio_lo, &lo_q_program);
    lo_q_program_init(pio_lo, sm_lo_q, offset_lo_q, LO_Q, LO_CLK);
    sm_lo_i = pio_claim_unused_sm(pio_lo, true);
    offset_lo_i = pio_add_program(pio_lo, &lo_i_program);
    lo_i_program_init(pio_lo, sm_lo_i, offset_lo_i, LO_I, LO_CLK);
    pio_enable_sm_mask_in_sync(pio_lo, ((1u << sm_lo_i) | (1u << sm_lo_q)));
}

//---------------------------------------------------------------------------
// ADC INIT FUNCTION
//---------------------------------------------------------------------------

void pico_adc_init()
{
    adc_init();
    adc_gpio_init(ADC0);
    adc_gpio_init(ADC1);
}

//---------------------------------------------------------------------------
// GPIO delays
//---------------------------------------------------------------------------
void delay_50ns()
{
    __asm volatile("nop" :);
    __asm volatile("nop" :);
    __asm volatile("nop" :);
    __asm volatile("nop" :);
    __asm volatile("nop" :);
    __asm volatile("nop" :);
}
void delay_250ns()
{
    delay_50ns();
    delay_50ns();
    delay_50ns();
    delay_50ns();
    delay_50ns();
}

//---------------------------------------------------------------------------
// ADC MAX GPIO INIT FUNCTION
//---------------------------------------------------------------------------
void adc_max_gpio_init()
{
    gpio_init(IN_CH);
    gpio_init(CS);
    gpio_init(SCLK);
    gpio_init(CHSEL);
    gpio_init(DOUTA);
    gpio_init(DOUTB);
    gpio_set_dir(IN_CH, GPIO_OUT);
    gpio_set_dir(CS, GPIO_OUT);
    gpio_set_dir(SCLK, GPIO_OUT);
    gpio_set_dir(CHSEL, GPIO_OUT);
    gpio_set_dir(DOUTA, GPIO_IN);
    gpio_set_dir(DOUTB, GPIO_IN);
    gpio_put(IN_CH, 0);
    gpio_put(CS, 1);
    gpio_put(SCLK, 0);
    gpio_put(CHSEL, 0);
}

//---------------------------------------------------------------------------
// GET ADC0 FUNCTION
//---------------------------------------------------------------------------
void get_adc0(uint16_t i)
{
    delay_250ns();
    adc_select_input(ADC_NUM0);
    uint adc_0_raw = adc_read();
    adc0Buf[i] = (float)(adc_0_raw * ADC_CONVERT);
}

//---------------------------------------------------------------------------
// GET ADC1 FUNCTION
//---------------------------------------------------------------------------
void get_adc1(uint16_t i)
{
    delay_250ns();
    adc_select_input(ADC_NUM1);
    uint adc_1_raw = adc_read();
    adc1Buf[i] = (float)(adc_1_raw * ADC_CONVERT);
}

//---------------------------------------------------------------------------
// GET DOUTA FUNCTION
//---------------------------------------------------------------------------
void get_douta(uint16_t i)
{
    uint data = 0;
    for (uint8_t k = 0; k < 12; ++k)
    {
        delay_50ns();
        gpio_put(SCLK, 1);
        delay_250ns();
        gpio_put(SCLK, 0);
        delay_50ns();
        data <<= 1;
        if (gpio_get(DOUTA))
        {
            data |= 1;
        }
    }

    douta[i] = (float)(data * ADC_CONVERT);
}

//---------------------------------------------------------------------------
// GET DOUTB FUNCTION
//---------------------------------------------------------------------------
void get_doutb(uint16_t i)
{
    uint data = 0;
    for (uint8_t k = 0; k < 12; ++k)
    {
        delay_50ns();
        gpio_put(SCLK, 1);
        delay_250ns();
        gpio_put(SCLK, 0);
        delay_50ns();
        data <<= 1;
        if (gpio_get(DOUTB))
        {
            data |= 1;
        }
    }

    doutb[i] = (float)(data * ADC_CONVERT);
}

//---------------------------------------------------------------------------
// ADC MAIN FUNCTION
//---------------------------------------------------------------------------

void adc()
{
    while (true)
    {
        printf("Choose ADC Enter 0 -> ADC MAX  1 -> ADC PICO: ");
        in_ch = getchar();
        printf("%d\n", in_ch - '0');
        if (in_ch == '0' || in_ch == '1')
        {
            break;
        }
    }

    if (in_ch == '0')
    {
        gpio_put(IN_CH, 0);
        delay_250ns();
        delay_250ns();
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            get_douta(i);
            get_doutb(i);
        }
        while (true)
        {
            printf("Enter a triggering number: ");
            trigger = getchar();
            printf("%d\n", trigger - '0');
            if (trigger == '1')
            {
                break;
            }
        }
        printf("----------Start of ACQ----------\n");
        printf("----------Start of DOUTA----------\n");
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            printf("%f,", douta[i]);
        }
        printf("\n-----------End of DOUTA-----------\n");

        printf("----------Start of DOUTB----------\n");
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            printf("%f,", doutb[i]);
        }
        printf("\n-----------End of DOUTB-----------\n");
        printf("\n-----------End of ACQ-----------\n");
    }
    else
    {
        gpio_put(IN_CH, 1);
        delay_250ns();
        delay_250ns();
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            get_adc0(i);
            get_adc1(i);
        }
        while (true)
        {
            printf("Enter a triggering number: ");
            trigger = getchar();
            printf("%d\n", trigger - '0');
            if (trigger == '1')
            {
                break;
            }
        }
        printf("----------Start of ACQ----------\n");
        printf("----------Start of ADC0----------\n");
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            printf("%f,", adc0Buf[i]);
        }
        printf("\n-----------End of ADC0-----------\n");

        printf("----------Start of ADC1----------\n");
        for (uint16_t i = 0; i < SAMPLE_COUNT; ++i)
        {
            printf("%f,", adc1Buf[i]);
        }
        printf("\n-----------End of ADC1-----------\n");
        printf("\n-----------End of ACQ-----------\n");
    }
}

//---------------------------------------------------------------------------
// END OF FILE
//---------------------------------------------------------------------------
