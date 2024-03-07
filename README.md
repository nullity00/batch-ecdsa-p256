# batch-ecdsa-p256
Implementation of batch ECDSA signatures in circom for the P-256 curve for the Nova proof system using Nova-Scotia.

> These circuits are not audited, and this is not intended to be used as a library for production-grade applications.

## Overview

This repository provides proof-of-concept implementations of ECDSA operations on the P-256 curve in circom using [Nova-Scotia](https://github.com/nalinbhardwaj/Nova-Scotia). These implementations are for demonstration purposes only. 

- `circuits` : Contains the signature aggregation circuit which is in accordance with [Nova-Scotia](https://github.com/nalinbhardwaj/Nova-Scotia)'s syntax. The `ECDSAVerifyNoPubkeyCheck(n,k)` function is imported from [circom-ecdsa-p256](https://github.com/privacy-scaling-explorations/circom-ecdsa-p256) submodule.
- `scripts` : Contains `generateSampleSignature.ts` which generates `p256` signatures, converts the bigint values to `6` `43-bit` register arrays and dumps it into `src/data/batch.json`.
- `src` : Includes the `main.rs` file to generate & verify proofs using Nova proof system

## Information 

Due to P256 curve having no cycles, and the nature of Ethereum precompiles, we use BigInt arithmetic from the original circom-ecdsa implementation instead of the efficient circom-ecdsa to take advantage of Nova's `BN254/grumpkin` cycle.

## Prerequisites

Make sure you have the following dependencies pre-installed

- circom
- yarn
- ts-node
- cargo

## Installing dependencies

- Run `git submodule update --init --recursive`
- Run `yarn` at the top level to install npm dependencies
- Run `yarn` inside of `circuits/circom-ecdsa-p256` to install npm dependencies for the `circom-ecdsa-p256` library.
- Run `yarn` inside of `circuits/circom-ecdsa-p256/circuits/circom-pairing` to install npm dependencies for the `circom-pairing` library.

## Generating & Verifying proofs

1. Compile the circuits and generate the relevant `r1cs` & `wasm` files
```bash
circom circuits/batch_ecdsa.circom --r1cs --sym --wasm
```
<!-- Should show something like this 
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
``` -->

2. Move the `batch_ecdsa.r1cs` file from the root to `src/data/`
```bash
mv batch_ecdsa.r1cs src/data
```

3. Move the `batch_ecdsa.wasm` file from `batch_ecdsa_js` to `src/data`
```bash
mv batch_ecdsa_js/batch_ecdsa.wasm src/data/
```

4. Make sure you've generated the signatures using the script. The signatures are populated in `src/data/batch.json`
```bash
ts-node scripts/generateSampleSignature.ts
```

5. Now to generate & verify a recursive proof, simply do ``cargo run``

