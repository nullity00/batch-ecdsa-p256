pragma circom 2.1.5;

include "./circom-ecdsa-p256/circuits/ecdsa.circom";

template BatchECDSA(n, k, N_SIGS){

  signal input step_in[5][k];
  signal input signatures[N_SIGS][5][k];
  signal output step_out[5][k];

  component sigsChecker[N_SIGS];

  sigsChecker[0] = ECDSAVerifyNoPubkeyCheck(43,6);

  sigsChecker[0].r <== step_in[0];
  sigsChecker[0].s <== step_in[1];
  sigsChecker[0].msghash <== step_in[2];
  sigsChecker[0].pubkey[0] <== step_in[3];
  sigsChecker[0].pubkey[1] <== step_in[4];

  for (var i = 1; i < N_SIGS; i++) {
    sigsChecker[i] = ECDSAVerifyNoPubkeyCheck(43,6);
    sigsChecker[i].r <== signatures[i-1][0];
    sigsChecker[i].s <== signatures[i-1][1];
    sigsChecker[i].msghash <== signatures[i-1][2];
    sigsChecker[i].pubkey[0] <== signatures[i-1][3];
    sigsChecker[i].pubkey[1] <== signatures[i-1][4];
  }

  for (var i = 0; i < 5; i++) {
    step_out[i] <== signatures[N_SIGS - 1][i];
  }
}

component main { public [ step_in ] } = BatchECDSA(43, 6, 10);