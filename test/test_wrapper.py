import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

from pong.test.encoder import Encoder

@cocotb.test()
async def test_wrapper(dut):

    def assert_7seg0():
        assert(dut.io_out[13] == 1)
        assert(dut.io_out[14] == 1)
        assert(dut.io_out[15] == 1)
        assert(dut.io_out[16] == 1)
        assert(dut.io_out[17] == 1)
        assert(dut.io_out[18] == 1)
        assert(dut.io_out[19] == 0)

    clock = Clock(dut.wb_clk_i, 83, units="ns")
    cocotb.fork(clock.start())

    clocks_per_phase = 5
    player1 = Encoder(dut.wb_clk_i, dut.io_in[9], dut.io_in[10], clocks_per_phase = clocks_per_phase, noise_cycles = 0)
    player2 = Encoder(dut.wb_clk_i, dut.io_in[11], dut.io_in[12], clocks_per_phase = clocks_per_phase, noise_cycles = 0)

    dut.active <= 0
    dut.wb_rst_i <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.wb_rst_i <= 0
    dut.la_data_in <= 0

    # count up with encoder with project inactive
    for _ in range(clocks_per_phase * 2 * 24):
        await player1.update(1)
        await player2.update(1)

    # pause
    await ClockCycles(dut.wb_clk_i, 100)

    # activate project
    dut.active <= 1

    # reset it
    dut.la_data_in <= 1 << 0
    await ClockCycles(dut.wb_clk_i, 1)
    dut.la_data_in <= 0 << 0
    await ClockCycles(dut.wb_clk_i, 1)

    assert_7seg0()

    # count up with encoder while project is active
    for _ in range(clocks_per_phase * 2 * 24):
        await player1.update(1)
        await player2.update(1)

    await ClockCycles(dut.wb_clk_i, 2000)
