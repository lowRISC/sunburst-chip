// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
//==================================================
// This file contains the Excluded objects
// Generated By User: miguelosorio
// Format Version: 2
// Date: Fri Aug 16 10:27:09 2024
// ExclMode: default
//==================================================
CHECKSUM: "2757273034 17324466"
INSTANCE: tb.dut.u_reg
ANNOTATION: "VC_COV_UNR"
Condition 35 "2498391236" "(aon_wdog_ctrl_we & aon_wdog_ctrl_regwen) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 36 "4196994620" "(aon_wdog_bark_thold_we & aon_wdog_bark_thold_regwen) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 37 "3675220916" "(aon_wdog_bite_thold_we & aon_wdog_bite_thold_regwen) 1 -1" (1 "01")
CHECKSUM: "530940107 4102526809"
INSTANCE: tb.dut
ANNOTATION: "VC_COV_UNR"
Condition 4 "594611319" "(reg2hw.intr_test.wkup_timer_expired.qe | reg2hw.intr_test.wdog_timer_bark.qe) 1 -1" (2 "01")
ANNOTATION: "VC_COV_UNR"
Condition 4 "594611319" "(reg2hw.intr_test.wkup_timer_expired.qe | reg2hw.intr_test.wdog_timer_bark.qe) 1 -1" (3 "10")
CHECKSUM: "74367784 3785313510"
INSTANCE: tb.dut.u_reg.u_reg_if
ANNOTATION: "VC_COV_UNR"
Condition 18 "3340270436" "(addr_align_err | malformed_meta_err | tl_err | instr_error | intg_error) 1 -1" (5 "01000")
CHECKSUM: "2815520955 4109606122"
INSTANCE: tb.dut.u_reg.u_wkup_count_hi_cdc.u_arb
ANNOTATION: "VC_COV_UNR"
Condition 5 "593451913" "(((!gen_wr_req.dst_req)) && gen_wr_req.dst_lat_d) 1 -1" (1 "01")
CHECKSUM: "2815520955 4109606122"
INSTANCE: tb.dut.u_reg.u_wkup_count_lo_cdc.u_arb
ANNOTATION: "VC_COV_UNR"
Condition 5 "593451913" "(((!gen_wr_req.dst_req)) && gen_wr_req.dst_lat_d) 1 -1" (1 "01")
CHECKSUM: "2815520955 4109606122"
INSTANCE: tb.dut.u_reg.u_wdog_count_cdc.u_arb
ANNOTATION: "VC_COV_UNR"
Condition 5 "593451913" "(((!gen_wr_req.dst_req)) && gen_wr_req.dst_lat_d) 1 -1" (1 "01")
CHECKSUM: "2815520955 4109606122"
INSTANCE: tb.dut.u_reg.u_wkup_cause_cdc.u_arb
ANNOTATION: "VC_COV_UNR"
Condition 5 "593451913" "(((!gen_wr_req.dst_req)) && gen_wr_req.dst_lat_d) 1 -1" (1 "01")
CHECKSUM: "3643792208 1147758610"
INSTANCE: tb.dut.u_reg.u_wkup_count_hi_cdc.u_arb.gen_wr_req.u_dst_update_sync
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (2 "10")
CHECKSUM: "3643792208 1147758610"
INSTANCE: tb.dut.u_reg.u_wkup_count_lo_cdc.u_arb.gen_wr_req.u_dst_update_sync
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (2 "10")
CHECKSUM: "3643792208 1147758610"
INSTANCE: tb.dut.u_reg.u_wdog_count_cdc.u_arb.gen_wr_req.u_dst_update_sync
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (2 "10")
CHECKSUM: "3643792208 1147758610"
INSTANCE: tb.dut.u_reg.u_wkup_cause_cdc.u_arb.gen_wr_req.u_dst_update_sync
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (1 "01")
ANNOTATION: "VC_COV_UNR"
Condition 2 "700807773" "(dst_req_o & dst_ack_i) 1 -1" (2 "10")
