class apb_sequence extends uvm_sequence#(apb_transaction);
  
  `uvm_object_utils(apb_sequence)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  task body();
    apb_transaction rw_trans;
    int unsigned seed = 20;
    //create 10 random APB read/write transaction and send to driver
    repeat (20) begin
      //rw_trans=new();
      rw_trans = apb_transaction::type_id::create(.name("rw_trans"), .contxt(get_full_name()));

      start_item(rw_trans);
      assert(rw_trans.randomize());
      rw_trans.data = $dist_uniform(seed, 30, 100);
      finish_item(rw_trans);
    end
  endtask
endclass
