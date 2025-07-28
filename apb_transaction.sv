
class apb_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(apb_transaction)
  
  typedef enum {READ, WRITE} access_type;
  

  rand bit   [31:0] addr;      //Address
  rand bit [31:0] data;     //Data - For write or read response
  rand access_type  pwrite;       //command type
  bit pslverr;
  state_type state;
  
  //constraint c1{addr[31:0]>=32'd270; addr[31:0] <32'd273;};
  //constraint c1{addr[31:0]>=32'd0; addr[31:0] <32'd5;};

  constraint c1{addr[31:0]>=32'd0; addr[31:0] <32'd256;};
  constraint c2{data[31:0]>=32'd0; data[31:0] <32'd256;};
  
  function new (string name = "apb_transaction");
    super.new(name);
  endfunction
  
  
  function string convert2string();
    return $psprintf("pwrite=%0d paddr=%0d data=%0d pslverr=%0d", pwrite, addr, data, pslverr);
    //return $psprintf("pwrite=%s paddr=%0h data=%0h",pwrite,addr,data);
  endfunction
  
endclass
