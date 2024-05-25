`timescale 1ns/1ps

class Transaction;

  // Memory arrays for reference and search data
  logic [7:0] R_mem[`RMEM_MAX-1:0];
  rand logic [7:0] S_mem[`SMEM_MAX-1:0];

  // Motion vectors and best distance metrics
  rand integer Expected_motionX;
  rand integer Expected_motionY;
  integer motionX;
  integer motionY;
  logic [7:0] BestDist;

  // Random index for introducing mismatches
  rand int rand_index;

  // Constraints for expected motion vectors
  constraint Expec_Motion_const { 
    Expected_motionX dist {[-7:0]:=10, [1:7]:=10};
    Expected_motionY dist {[-7:0]:=10, [1:7]:=10};
  };

  // Constraints for mismatch index distribution
  constraint mismatch_index_const {
    soft rand_index dist {[0:255] := 10, [256:511] := 10, [512:767] := 10}; 
  };

  // Constraints for search memory values
  constraint S_MEM_const {
    foreach(S_mem[i]) S_mem[i] inside {[0:`SMEM_MAX-1]};
  };

  // Display function to output transaction details
  function void display();
    $display("*---------*----------*--------* SEARCH MEMORY *--------*--------*-------*----------*----------*");
    for (int j = 0; j < `SMEM_MAX; j++) begin
      if (j % 32 == 0) $display("  ");
      $write("%h  ", S_mem[j]);
      if (j == 1023) $display("  ");
    end

    $display("*---------*----------*--------* REFERENCE MEMORY *--------*--------*-------*---------*-------*");
    for (int j = 0; j < `RMEM_MAX; j++) begin
      if (j % 16 == 0) $display("  ");
      $write("%h ", R_mem[j]);
      if (j == 255) $display("  ");
    end

    $display("\n rand_index : %0d", rand_index);     
    $display("Expected_motionX : %0d", Expected_motionX);
    $display("Expected_motionY : %0d", Expected_motionY);
  endfunction

  // Function to generate reference memory based on search memory and motion vectors
  function void gen_Rmem();
    foreach (R_mem[i]) begin
      // Generate a full match by default
      R_mem[i] = S_mem[32 * 8 + 8 + (((i / 16) + Expected_motionY) * 32) + ((i % 16) + Expected_motionX)];
      
      // Introduce a controlled mismatch at the random mismatch index
      if (i == rand_index)   
        R_mem[i] = $urandom_range(0, 255);
    end

    // Debugging statements for generated memories
    $display("Generated R_mem:");
    for (int j = 0; j < `RMEM_MAX; j++) begin
      $write("%h ", R_mem[j]);
      if (j % 16 == 15) $display();
    end

    $display("Generated S_mem:");
    for (int j = 0; j < `SMEM_MAX; j++) begin
      $write("%h ", S_mem[j]);
      if (j % 32 == 31) $display();
    end
  endfunction

endclass
