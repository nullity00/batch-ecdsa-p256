# batch-ecdsa-p-256

## Compiling the circuit

```bash
$ circom circuits/batch_ecdsa.circom --r1cs --sym --wasm

template instances: 67
non-linear constraints: 19729050
linear constraints: 0
public inputs: 30
public outputs: 30
private inputs: 300
private outputs: 0
wires: 19584211
labels: 26669751
Written successfully: ./batch_ecdsa.r1cs
Written successfully: ./batch_ecdsa.sym
Written successfully: ./batch_ecdsa_js/batch_ecdsa.wasm
Everything went okay, circom safe
```