
class apb_subscriber extends uvm_subscriber#(apb_transaction);
  
  `uvm_component_utils(apb_subscriber)
 
  
  
  bit [31:0] addr;
  bit [31:0] data;
  bit pwrite;
  bit pslverr;

  
  covergroup cover_bus;
    option.per_instance = 1;

    coverpoint addr {
      bins a[16] = {[0:255]};  // Covers address space from 0 to 255
    }
    
    /*
    coverpoint data {
      bins d[16] = {[0:255]};  // Covers data space from 0 to 255
    }
    */
    
    coverpoint pwrite {
      bins write = {1};
      bins read  = {0};
    }
    
    coverpoint pslverr {
      bins ok    = {0};
      bins error = {1};
    }
    
    
    cross pwrite, addr;
    cross pwrite, pslverr;
    cross addr, pslverr;

  endgroup
  
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    cover_bus=new;
  endfunction
  
  function void write(apb_transaction t);
    `uvm_info("APB_SUBSCRIBER", $psprintf("Subscriber received tx %s", t.convert2string()), UVM_NONE);
   
    addr    = t.addr;
    data    = t.data;
    pwrite  = t.pwrite;
    pslverr = t.pslverr;
    cover_bus.sample();
  endfunction
  
endclass
