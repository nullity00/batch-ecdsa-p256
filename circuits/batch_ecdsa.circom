pragma circom 2.1.5;

include "./circom-ecdsa-p256/circuits/ecdsa.circom";

template BatchECDSA(n, k, N_SIGS){
  var m = k*5;

  signal input step_in[m];
  signal input signatures[N_SIGS][m];
  signal output step_out[m];

  component sigsChecker[N_SIGS];

  signal step_2D_in[5][k];
  for (var i = 0; i < 5; i++) {
    for (var l = 0; l < k; l++) {
      step_2D_in[i][l] <== step_in[i*k + l];
    }
  }

  sigsChecker[0] = ECDSAVerifyNoPubkeyCheck(n,k);
  sigsChecker[0].r <== step_2D_in[0];
  sigsChecker[0].s <== step_2D_in[1];
  sigsChecker[0].msghash <== step_2D_in[2];
  sigsChecker[0].pubkey[0] <== step_2D_in[3];
  sigsChecker[0].pubkey[1] <== step_2D_in[4];
  sigsChecker[0].result === 1;

  signal signatures_3D[N_SIGS-1][5][k];
  for (var i = 1; i < N_SIGS; i++) {
    for (var j = 0; j < 5; j++) {
      for (var l = 0; l < k; l++) {
        signatures_3D[i-1][j][l] <== signatures[i][j*k + l];
      }
    }
  }

  for (var i = 1; i < N_SIGS; i++) {
    sigsChecker[i] = ECDSAVerifyNoPubkeyCheck(n,k);
    sigsChecker[i].r <== signatures_3D[i-1][0];
    sigsChecker[i].s <== signatures_3D[i-1][1];
    sigsChecker[i].msghash <== signatures_3D[i-1][2];
    sigsChecker[i].pubkey[0] <== signatures_3D[i-1][3];
    sigsChecker[i].pubkey[1] <== signatures_3D[i-1][4];
    sigsChecker[i].result === 1;
  }

  for (var i = 0; i < m; i++) {
    step_out[i] <== signatures[N_SIGS - 1][i];
  }
}

component main { public [ step_in ] } = BatchECDSA(43, 6, 10);