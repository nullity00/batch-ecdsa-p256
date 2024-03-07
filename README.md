# batch-ecdsa-p-256

## Compiling the circuit

```bash
circom circuits/batch_ecdsa.circom --r1cs --sym --wasm
```
Should show something like this 
```bash
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

Move the r1cs file from the root to `src/data/`
```bash
mv batch_ecdsa.r1cs src/data
```
Move the wasm file from `batch_ecdsa_js` to `src/data`
```bash
mv batch_ecdsa_js/batch_ecdsa.wasm src/data/
```

Make sure you've generated the signatures using the script. The signatures are populated in `src/data/batch.json`
```bash
ts-node scripts/generateSampleSignature.ts
```

Now to generate a recursive proof, simply do ``cargo run``

