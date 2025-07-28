
interface dut_if;
  

  logic pclk;
  logic rst_n;
  logic [31:0] paddr;
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] pwdata;
  logic pready;
  logic [31:0] prdata;
  logic pslverr;
  //state_type state, next_state;

  // Master Clocking block - used for Drivers
  clocking master_cb @(posedge pclk);
    output paddr, psel, penable, pwrite, pwdata;
    input  prdata, pready, pslverr;
  endclocking: master_cb

  // Slave Clocking Block - used for any Slave BFMs
  clocking slave_cb @(posedge pclk);
    input  paddr, psel, penable, pwrite, pwdata;
    output prdata, pready, pslverr;
  endclocking: slave_cb

  // Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge pclk);
    input paddr, psel, penable, pwrite, prdata, pwdata, pready, pslverr;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);

endinterface
    
  
module apb_slave(dut_if dif);
  

  logic [31:0] mem [0:255]; // Updated to 255 for memory size consistency
  
  
  typedef enum logic [1:0] {
  IDLE         = 2'b00,
  SETUP        = 2'b01,
  WRITE_ACCESS = 2'b10,
  READ_ACCESS  = 2'b11
} state_type;


  
  state_type state, next_state;
  logic pslverr_next;
  

  // Initialize Memory
  initial begin
    foreach(mem[i]) mem[i] = 0;
  end

  // Synchronous Logic
  always @(posedge dif.pclk or negedge dif.rst_n) begin
    if (!dif.rst_n) begin
      state       <= IDLE;
      dif.prdata  <= 0;
      dif.pready  <= 0; // Default to not ready
      dif.pslverr <= 0;
    end else begin
      state <= next_state;
      dif.pslverr <= pslverr_next;
    end
  end

  // Combinational Logic
  always @(*) begin
    // Default values for outputs
    next_state   = state;
    dif.pready   = 0;
    //dif.pslverr  = 0;
    pslverr_next = 0;

    case (state)
      IDLE: begin
        if (dif.psel) begin
          next_state = SETUP;
        end
      end

      SETUP: begin
        if (dif.psel && !dif.penable) begin
          if (dif.pwrite && dif.paddr < 32'd256) begin
            next_state = WRITE_ACCESS;
          end else if (!dif.pwrite && dif.paddr < 32'd256) begin
            next_state = READ_ACCESS;
          end else begin
            //dif.pslverr = 1; // Address out of range
            pslverr_next = 1;
          end
        end
      end

      WRITE_ACCESS: begin
        if (dif.psel && dif.penable && dif.pwrite && dif.paddr < 32'd256) begin
          mem[dif.paddr] = dif.pwdata;
          dif.pready = 1; // Indicate transaction completed
        end else begin
          pslverr_next = 1;
        end
        next_state = (!dif.psel) ? IDLE : SETUP; // Return to IDLE or SETUP
      end

      READ_ACCESS: begin
        if (dif.psel && dif.penable && !dif.pwrite && dif.paddr < 32'd256) begin
          dif.prdata = mem[dif.paddr];
          dif.pready = 1; // Indicate transaction completed
        end else begin
          pslverr_next = 1;
        end
        next_state = (!dif.psel) ? IDLE : SETUP; // Return to IDLE or SETUP
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule

