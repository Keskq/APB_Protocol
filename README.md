# APB_Protocol

### APB Protocol Signal Description  
The following explanation describes the **APB Master** (controller) connected to a **RAM Slave** (memory component).  

#### **Inputs to the APB Master (from the system):**  
1. **PCLK (Clock):**  
   - The system clock that synchronizes the Master’s operation.  
   - Serves as the timing reference for APB operations.  

2. **PRESETn (Reset):**  
   - An active-low reset signal that initializes the system.  
   - Ensures the Master starts from a known state.  

3. **transfer:**  
   - An internal signal that indicates the start of a transfer operation (communication start).  

4. **READ_WRITE:**  
   - Determines whether the operation is a write (1) or a read (0).  

5. **apb_write_paddr[7:0]:**  
   - Target address for write operations.  
   - Width: 8 bits.  

6. **apb_write_data[7:0]:**  
   - Data to be written to the Slave.  
   - Width: 8 bits.  

7. **apb_read_paddr[7:0]:**  
   - Target address for read operations.  
   - Width: 8 bits.  

---

#### **Outputs from the APB Master (to the RAM Slave):**  
1. **paddr[7:0]:**  
   - Target address sent to the Slave.  
   - Derived from the Master’s internal signals (`apb_write_paddr` or `apb_read_paddr`).  

2. **pwdata[7:0]:**  
   - Write data sent from the Master to the Slave.  
   - Derived from `apb_write_data`.  

3. **PWRITE:**  
   - Indicates whether the operation is a write (1) or a read (0).  

4. **PENABLE:**  
   - Control signal indicating to the Slave that the request is ready for processing.  
   - Activated in the **ACCESS** state.  

---

#### **Inputs to the APB Master (from the RAM Slave):**  
1. **PREADY:**  
   - Indicates whether the Slave is ready to complete the operation.  
     - `1`: The Slave is ready to proceed.  
     - `0`: The Slave is not yet ready.  

2. **PRDATA[7:0]:**  
   - Read data sent from the Slave back to the Master.  
   - Width: 8 bits.  

---

#### **Outputs from the APB Master (to the system):**  
1. **apb_read_data_out[7:0]:**  
   - The read data received from the Slave after a read operation.  
   - Width: 8 bits.  
