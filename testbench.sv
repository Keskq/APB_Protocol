 import uvm_pkg::*;
`include "uvm_macros.svh"

 //Include all files
`include "apb_types_pkg.sv"
`include "apb_transaction.sv"
`include "apb_sequence.sv"
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_scoreboard.sv"
`include "apb_subscriber.sv"
`include "apb_env.sv"
`include "apb_test.sv"

//`include "apb_coverage.sv"


//--------------------------------------------------------
//Top level module that instantiates  just a physical apb interface
//No real DUT or APB slave as of now
//--------------------------------------------------------
module test;

   logic pclk;
   logic rst_n;
   logic [31:0] paddr;
   logic        psel;
   logic        penable;
   logic        pwrite;
   logic [31:0] prdata;
   logic [31:0] pwdata;
   logic        pslverr;
  
   dut_if apb_if();
  
   apb_slave dut(.dif(apb_if));
  
  
   always @(posedge apb_if.pclk) begin
     $display("Time: %0t | DUT State: %0d", $time, dut.state);
   end
  
  
   always @(posedge apb_if.pclk) begin
     $display("Time: %0t | DUT pslverr: %0d", $time, apb_if.pslverr);
   end
  
   initial begin
      apb_if.pclk=0;
   end

    //Generate a clock
   always begin
      #10 apb_if.pclk = ~apb_if.pclk;
   end
 
  initial begin
    apb_if.rst_n=0;
    repeat (1) @(posedge apb_if.pclk);
    apb_if.rst_n=1;
  end
  
  covergroup st_cg @(posedge apb_if.pclk);
  option.per_instance=1;

  coverpoint dut.state {
    bins S1_S2 = (dut.IDLE => dut.SETUP) ;
    bins S1_S3 = (dut.SETUP => dut.READ_ACCESS) ;
    bins S2_S1 = (dut.WRITE_ACCESS => dut.SETUP) ;
    bins S3_S1 = (dut.WRITE_ACCESS => dut.SETUP) ;
  }
  endgroup

  st_cg stcg; 

  initial begin
    stcg = new(); 
  end

  initial begin
    uvm_config_db#(virtual dut_if)::set( null, "uvm_test_top", "vif", apb_if);
    run_test("apb_base_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule

